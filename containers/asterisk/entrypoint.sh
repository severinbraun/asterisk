#!/bin/sh
# POSIX sh: rendert Templates aus /etc/asterisk.tmpl nach /etc/asterisk
set -eu

tmpl_dir="/etc/asterisk.tmpl"
dst_dir="/etc/asterisk"

if [ ! -d "$dst_dir" ]; then
  mkdir -p "$dst_dir"
fi

# Dateien rendern (Platzhalter: __FOO__)
for f in asterisk.conf extensions.conf logger.conf modules.conf pjsip.conf rtp.conf sip.conf; do
  src="$tmpl_dir/$f"
  dst="$dst_dir/$f"
  if [ -f "$src" ]; then
    sed \
      -e "s|__DOORBIRD_USER__|${DOORBIRD_USER}|g" \
      -e "s|__DOORBIRD_PASS__|${DOORBIRD_PASS}|g" \
      -e "s|__HA_USER__|${HA_USER}|g" \
      -e "s|__HA_PASS__|${HA_PASS}|g" \
      -e "s|__RTP_START__|${RTP_START}|g" \
      -e "s|__RTP_END__|${RTP_END}|g" \
      -e "s|__LOG_LEVEL__|${ASTERISK_LOG_LEVEL}|g" \
      "$src" > "$dst"
  fi
done

# Log-Verzeichnis sicherstellen
if [ ! -d /var/log/asterisk ]; then
  mkdir -p /var/log/asterisk
fi

# Asterisk starten; CMD-Args (z.B. "-f") werden durchgereicht
exec /usr/sbin/asterisk "$@"
