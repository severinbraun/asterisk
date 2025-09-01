#!/bin/sh
set -eu

# Laufzeit-Verzeichnisse/Ownership absichern (idempotent)
mkdir -p /run/asterisk /var/log/asterisk /var/spool/asterisk
chown -R asterisk:asterisk /run/asterisk /var/log/asterisk /var/spool/asterisk /var/lib/asterisk || true

# Asterisk im Vordergrund starten
exec /usr/sbin/asterisk -f -U asterisk -G asterisk -vvv
