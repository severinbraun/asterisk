#!/bin/sh
set -eu

# Verzeichnisse anlegen + Eigentümer setzen (Docker verliert /var/run beim Neustart)
mkdir -p /var/run/asterisk /var/log/asterisk /var/spool/asterisk /var/lib/asterisk
chown -R asterisk:asterisk /var/run/asterisk /var/log/asterisk /var/spool/asterisk /var/lib/asterisk

# Sicherstellen, dass das Modulverzeichnis existiert (kommt mit dem Paket 'asterisk')
if [ ! -d /usr/lib/asterisk/modules ]; then
  echo "ERROR: /usr/lib/asterisk/modules fehlt – ist das Paket 'asterisk' installiert?"
  ls -la /usr/lib/asterisk || true
  exit 1
fi

# Als 'asterisk' starten (kein root zur Laufzeit)
exec su-exec asterisk:asterisk /usr/sbin/asterisk -f -U asterisk -G asterisk -C /etc/asterisk/asterisk.conf -vvv
