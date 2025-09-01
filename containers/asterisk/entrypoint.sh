#!/bin/sh
set -eu

render_tpl() {
  src="$1"; dst="$2"
  tmp="$(mktemp)"
  # einfache Variablenersetzung nur für ${VAR} Platzhalter
  sed \
    -e "s|\${HA_AMI_PASS:-[^}]*}|${HA_AMI_PASS:-Caliba#355}|g" \
    -e "s|\${HA_AMI_PERMIT:-[^}]*}|${HA_AMI_PERMIT:-192.168.2.0/24}|g" \
    > "$tmp" < "$src"
  cat "$tmp" > "$dst"
  rm -f "$tmp"
}

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

# Defaults aus ENV (DoorBird & Home Assistant)
DOORBIRD_USER="${DOORBIRD_USER:-doorbird}"
DOORBIRD_PASS="${DOORBIRD_PASS:-Caliba#355}"
HOMEASSISTANT_USER="${HOMEASSISTANT_USER:-homeassistant}"
HOMEASSISTANT_PASS="${HOMEASSISTANT_PASS:-Caliba#355}"
HA_AMI_USER="${HA_AMI_USER:=admin}"
HA_AMI_PASS="${HA_AMI_PASS:=Caliba#355}"
HA_AMI_PERMIT="${HA_AMI_PERMIT:=0.0.0.0/0}"

# Verzeichnisse sicherstellen (Asterisk erwartet Sockets/PID unter /var/run/asterisk)
mkdir -p /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk
chown -R asterisk:asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk

# Runtime-Credentials in /run/asterisk schreiben (damit /etc/asterisk read-only bleiben kann)
# chan_sip
cat > /run/asterisk/creds_sip.conf <<EOF
[${DOORBIRD_USER}]
type=friend
host=dynamic
secret=${DOORBIRD_PASS}
context=public
disallow=all
allow=ulaw,alaw,g722
directmedia=no
nat=force_rport,comedia
insecure=port,invite

[${HOMEASSISTANT_USER}]
type=friend
host=dynamic
secret=${HOMEASSISTANT_PASS}
context=public
disallow=all
allow=ulaw,alaw,g722
directmedia=no
nat=force_rport,comedia
insecure=port,invite
EOF

# PJSIP (Endpoint/AOR/Auth Triplets)
cat > /run/asterisk/creds_pjsip.conf <<EOF
[${DOORBIRD_USER}-auth]
type=auth
auth_type=userpass
username=${DOORBIRD_USER}
password=${DOORBIRD_PASS}

[${DOORBIRD_USER}-aor]
type=aor
max_contacts=1

[${DOORBIRD_USER}-endpoint]
type=endpoint
context=public
disallow=all
allow=ulaw,alaw,g722
direct_media=no
aors=${DOORBIRD_USER}-aor
auth=${DOORBIRD_USER}-auth

[${HOMEASSISTANT_USER}-auth]
type=auth
auth_type=userpass
username=${HOMEASSISTANT_USER}
password=${HOMEASSISTANT_PASS}

[${HOMEASSISTANT_USER}-aor]
type=aor
max_contacts=2

[${HOMEASSISTANT_USER}-endpoint]
type=endpoint
context=public
disallow=all
allow=ulaw,alaw,g722
direct_media=no
aors=${HOMEASSISTANT_USER}-aor
auth=${HOMEASSISTANT_USER}-auth
EOF

# manager.conf rendern
if [ -f /etc/asterisk/manager.conf ]; then
  render_tpl /etc/asterisk/manager.conf /etc/asterisk/manager.conf
fi

# Asterisk im Vordergrund starten
exec /usr/sbin/asterisk -f -U asterisk -G asterisk -vvv
