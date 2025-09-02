#!/bin/sh
set -eu

# --- TLS: Self-Signed Zertifikate erzeugen, wenn nicht vorhanden ---
CRT="/etc/asterisk/keys/asterisk.crt"
KEY="/etc/asterisk/keys/asterisk.key"

if [ ! -s "$CRT" ] || [ ! -s "$KEY" ]; then
  echo "[entrypoint] generating self-signed TLS certs for CN=${CERT_CN}"
  # -nodes: unencrypted key (Asterisk erwartet unverschlüsselte Keys)
  # Gültigkeit 10 Jahre
  openssl req -x509 -nodes -newkey rsa:2048 \
    -subj "/CN=${CERT_CN}" \
    -days 3650 \
    -keyout "$KEY" -out "$CRT"
  chmod 600 "$KEY"
  chown asterisk:asterisk "$CRT" "$KEY"
fi

# Verzeichnisse sicherstellen (Asterisk erwartet Sockets/PID unter /var/run/asterisk)
mkdir -p /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk
chown -R asterisk:asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk

# Asterisk im Vordergrund starten
exec /usr/sbin/asterisk -f -U asterisk -G asterisk -vvv
