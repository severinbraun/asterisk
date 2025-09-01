#!/usr/bin/env bash
set -euo pipefail

log() { echo "[$(date -Is)] $*"; }

# MariaDB vorbereiten
prepare_mariadb() {
  log "Preparing MariaDB datadir..."
  mkdir -p /var/run/mysqld
  chmod 0775 /var/run/mysqld
  chown -R mysql:mysql /var/lib/mysql /var/run/mysqld || true

  # Falls noch nicht initialisiert
  if [ ! -d /var/lib/mysql/mysql ]; then
    log "Initializing MariaDB..."
    mysqld --user=mysql --basedir=/usr --datadir=/var/lib/mysql --skip-networking=0 --initialize-insecure
  fi
}

start_mariadb() {
  log "Starting MariaDB..."
  mysqld --user=mysql --bind-address=127.0.0.1 --datadir=/var/lib/mysql --skip-name-resolve &
  MDB_PID=$!
}

start_asterisk() {
  log "Starting Asterisk (foreground=false)..."
  # -f wäre "foreground"; wir starten im Hintergrund und lassen Apache im Vordergrund laufen
  # Asterisk soll eigene User/Gruppe nutzen, falls vorhanden
  if id asterisk >/dev/null 2>&1; then
    AUSER=asterisk
  else
    AUSER=root
  fi
  asterisk -U "${AUSER}" -G "${AUSER}" -C /etc/asterisk/asterisk.conf &
  AST_PID=$!
}

start_apache() {
  log "Starting Apache (foreground)..."
  # Sicherstellen, dass Apache nicht mit alten PIDs kollidiert
  rm -f /var/run/apache2/apache2.pid || true
  exec apache2ctl -D FOREGROUND
}

# Optional: minimaler PHP/Apache Check
php_ready() {
  php -v >/dev/null 2>&1 || true
}

case "${1:-foreground}" in
  foreground)
    prepare_mariadb
    start_mariadb
    php_ready
    start_asterisk
    # Apache im Vordergrund → PID 1 (unter tini) bekommt Signale sauber
    start_apache
    ;;
  bash|sh)
    exec "$@"
    ;;
  *)
    # Benutzerdefinierter Befehl
    exec "$@"
    ;;
esac
