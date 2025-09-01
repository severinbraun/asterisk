# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

# Keine interaktiven Prompts in CI
ARG DEBIAN_FRONTEND=noninteractive

# --- feste Paketversionen (können bei Bedarf via --build-arg überschrieben werden) ---
# Werte sind identisch zur versions.env
ARG ASTERISK_VERSION="1:20.6.0~dfsg+~cs6.13.40431414-2build5"
ARG TINI_VERSION="0.19.0-1"
ARG TZDATA_VERSION="2025b-0ubuntu0.24.04.1"
ARG CURL_VERSION="8.5.0-2ubuntu10.6"
ARG CA_CERTIFICATES_VERSION="20240203"
ARG SOX_VERSION="14.4.2+git20190427-4build4"
ARG LAME_VERSION="3.100-6build1"

# Basis-Tools + Asterisk installieren (gepinnte Versionen)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk="${ASTERISK_VERSION}" \
      tini="${TINI_VERSION}" \
      tzdata="${TZDATA_VERSION}" \
      curl="${CURL_VERSION}" \
      ca-certificates="${CA_CERTIFICATES_VERSION}" \
      sox="${SOX_VERSION}" \
      lame="${LAME_VERSION}"; \
    rm -rf /var/lib/apt/lists/*

# (Debian/Ubuntu-Paket legt i.d.R. bereits user/group "asterisk" an.)
# Verzeichnisse sicherheitshalber dem asterisk-User geben:
RUN set -eux; \
    getent passwd asterisk >/dev/null 2>&1 || useradd -r -s /usr/sbin/nologin asterisk; \
    install -d -o asterisk -g asterisk /var/{lib,log,spool}/asterisk /etc/asterisk

# Ports: SIP (UDP 5060), optional TLS (TCP 5061), RTP (10000-20000/UDP)
EXPOSE 5060/udp 5061/tcp 10000-20000/udp

# Healthcheck: fragt die Asterisk-Version ab (exit 0 wenn OK)
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD asterisk -rx 'core show version' >/dev/null 2>&1 || exit 1

# Tini als PID 1 (sauberes Signal-Handling)
ENTRYPOINT ["/usr/bin/tini","--"]

# Als nicht-root laufen
USER asterisk

# Asterisk im Vordergrund, ausführliche Logs
CMD ["asterisk","-f","-vvv"]
