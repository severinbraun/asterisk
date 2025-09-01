#!/usr/bin/env bash
set -euo pipefail

# ---- Defaults / ENV ----
: "${TZ:=Europe/Berlin}"

# MariaDB / FreePBX DB Settings (alles-in-einem-Container)
: "${DB_HOST:=127.0.0.1}"
: "${DB_PORT:=3306}"
: "${DB_ROOT_PASSWORD:=rootpass}"          # ändere per .env / Secrets!
: "${DB_APP_USER:=freepbx}"
: "${DB_APP_PASSWORD:=freepbxpass}"        # ändere per .env / Secrets!
: "${DB_AST_DB:=asterisk}"
: "${DB_CDR_DB:=asteriskcdrdb}"

# RTP-Ports
: "${RTP_START:=10000}"
: "${RTP_FINISH:=20000}"

# FreePBX
: "${FREEPBX_VERSION:=16}"

# ---- Zeit & PHP ----
echo "$TZ" > /etc/timezone
ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime || true

# ---- Asterisk: RTP Range setzen (idempotent) ----
mkdir -p /etc/asterisk
if ! grep -q '^rtpstart=' /etc/asterisk/rtp.conf 2>/dev/null; then
cat > /etc/asterisk/rtp.conf <<EOF
[general]
rtpstart=${RTP_START}
rtpend=${RTP_FINISH}
EOF
fi

# ---- MariaDB initialisieren (wenn leer) ----
if [ ! -d /var/lib/mysql/mysql ]; then
  echo ">> Initialisiere MariaDB Datenverzeichnis"
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql --basedir=/usr --skip-test-db >/dev/null
fi

# MariaDB starten (Foreground in Subshell)
echo ">> Starte MariaDB"
mysqld_safe --datadir=/var/lib/mysql --bind-address=127.0.0.1 >/var/log/mysql.log 2>&1 &
MYSQL_PID=$!

# Warten bis DB bereit ist
echo ">> Warte auf MariaDB..."
for i in {1..60}; do
  if mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" --silent; then
    break
  fi
  sleep 1
done

# Root-Passwort & DBs/Users setzen (idempotent)
echo ">> Richte Datenbanken & Benutzer ein"
mysql -u root <<SQL || true
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${DB_AST_DB}\`;
CREATE DATABASE IF NOT EXISTS \`${DB_CDR_DB}\`;
CREATE USER IF NOT EXISTS '${DB_APP_USER}'@'localhost' IDENTIFIED BY '${DB_APP_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_AST_DB}\`.* TO '${DB_APP_USER}'@'localhost';
GRANT ALL PRIVILEGES ON \`${DB_CDR_DB}\`.* TO '${DB_APP_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

# ---- Apache vorbereiten ----
a2ensite 000-default >/dev/null || true
service apache2 stop || true
echo ">> Starte Apache"
apachectl -D FOREGROUND &
APACHE_PID=$!

# ---- Asterisk starten ----
# Ubuntu-Paket nutzt den User 'asterisk'; sicherstellen, dass Verzeichnisse passen
chown -R asterisk:asterisk /var/lib/asterisk /var/spool/asterisk /var/log/asterisk || true
echo ">> Starte Asterisk"
su -s /bin/bash -c "asterisk -f -U asterisk -G asterisk" asterisk &
AST_PID=$!

# ---- FreePBX Install beim ersten Start (leichtgewichtig, per Web/CLI) ----
if [ ! -f /var/www/html/admin/modules/framework/module.xml ]; then
  echo ">> FreePBX ist nicht installiert – lade & installiere Framework ${FREEPBX_VERSION}"
  cd /usr/src
  # Download – offizielle Mirrors variieren; hier zwei Versuche (still → klein)
  curl -fsSLo freepbx.tgz "https://downloads.freepbx.org/releases/${FREEPBX_VERSION}/freepbx-${FREEPBX_VERSION}.tgz" \
    || curl -fsSLo freepbx.tgz "https://mirror.freepbx.org/freepbx/freepbx-${FREEPBX_VERSION}.tgz"

  mkdir -p freepbx-src && tar -xzf freepbx.tgz -C freepbx-src --strip-components=1
  cd freepbx-src

  # Minimal-Install ohne Interaktion:
  # Asterisk muss laufen, DB ist vorbereitet
  ./start_asterisk start || true

  # fwconsole / install nutzen:
  # -n (non-interactive), --dbengine mariadb setzt Engine
  ./install -n --dbengine=mysql --dbname="$DB_AST_DB" --cdrdbname="$DB_CDR_DB" \
    --dbuser="$DB_APP_USER" --dbpass="$DB_APP_PASSWORD" || true

  # Rechte für Apache/FreePBX
  chown -R www-data:www-data /var/www/html
  # Optional: Alle empfohlenen Module
  if command -v fwconsole >/dev/null 2>&1; then
    fwconsole ma installall || true
    fwconsole chown || true
    fwconsole reload || true
  fi
fi

echo ">> Dienste laufen: Asterisk PID=$AST_PID, Apache PID=$APACHE_PID, MariaDB PID=$MYSQL_PID"
# Warte, bis einer der Prozesse stirbt
wait -n "$APACHE_PID" "$AST_PID" "$MYSQL_PID"
exit $?
