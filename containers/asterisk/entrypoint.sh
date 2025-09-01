#!/bin/sh
set -e

# Verzeichnisse sicherstellen (insb. bei Volumes)
mkdir -p /var/run/asterisk /var/log/asterisk /var/spool/asterisk
chown -R asterisk:asterisk \
  /var/run/asterisk /var/log/asterisk /var/spool/asterisk /var/lib/asterisk /etc/asterisk

# Im Vordergrund starten, damit der Container lebt
exec /usr/sbin/asterisk -f -U asterisk -G asterisk -vvv
