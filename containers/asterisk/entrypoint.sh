#!/usr/bin/env bash
set -euo pipefail

log() { echo "[$(date -Is)] $*"; }

ensure_dirs() {
  install -d -o asterisk -g asterisk /run/asterisk /var/lib/asterisk /var/log/asterisk
}

start_asterisk_fg() {
  # -f: foreground, -U/-G: User/Group
  exec asterisk -f -U asterisk -G asterisk -C /etc/asterisk/asterisk.conf
}

case "${1:-foreground}" in
  foreground)
    log "Starting Asterisk in foreground..."
    ensure_dirs
    start_asterisk_fg
    ;;
  bash|sh)
    exec "$@"
    ;;
  *)
    # beliebiger custom Befehl
    exec "$@"
    ;;
esac
