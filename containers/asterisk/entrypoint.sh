#!/bin/sh
set -e

# Verzeichnisse sicherstellen (falls Volumes gemountet sind)
mkdir -p /var/run/asterisk /var/log/asterisk /var/spool/asterisk
chown -R asterisk:asterisk \
  /var/run/asterisk /var/log/asterisk /var/spool/asterisk /var/lib/asterisk /etc/asterisk

# Asterisk im Vordergrund, als User/Grupppe 'asterisk'
exec /usr/sbin/asterisk -f -U asterisk -G asterisk -vvv
