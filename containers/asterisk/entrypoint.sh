#!/bin/sh
set -eu

# Defaults aus ENV (für DoorBird & Home Assistant)
DOORBIRD_USER="${DOORBIRD_USER:-doorbird}"
DOORBIRD_PASS="${DOORBIRD_PASS:-Caliba#355}"
HOMEASSISTANT_USER="${HOMEASSISTANT_USER:-homeassistant}"
HOMEASSISTANT_PASS="${HOMEASSISTANT_PASS:-Caliba#355}"

# Verzeichnisse sicherstellen
mkdir -p /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk
# Rechte (wir laufen bereits als User 'asterisk')
chown -R asterisk:asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk

# Runtime-Credentials als separate Includes schreiben (damit /etc/asterisk read-only bleiben kann)
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

# Asterisk im Vordergrund starten
exec /usr/sbin/asterisk -f -U asterisk -G asterisk -vvv
