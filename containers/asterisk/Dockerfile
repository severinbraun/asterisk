# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Hadolint-sicher: Defaults setzen, damit Labels nie "undefined" sind
ARG OWNER=unknown
ARG REPO=unknown

# Gepinnte Versionen (werden aus versions.env überschrieben, falls via --build-arg gesetzt)
ARG ASTERISK_VERSION=1:20.6.0~dfsg+~cs6.13.40431414-2build5
ARG TINI_VERSION=0.19.0-1
ARG TZDATA_VERSION=2025b-0ubuntu0.24.04.1
ARG CURL_VERSION=8.5.0-2ubuntu10.6
ARG CA_CERTIFICATES_VERSION=20240203

# Labels (keine undefined-vars mehr)
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.description="Minimal Asterisk (chan_sip + chan_pjsip) on Ubuntu 24.04" \
      org.opencontainers.image.url="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.vendor="${OWNER}"

# Pinned installs (DL3008-konform)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      "asterisk=${ASTERISK_VERSION}" \
      "tini=${TINI_VERSION}" \
      "tzdata=${TZDATA_VERSION}" \
      "curl=${CURL_VERSION}" \
      "ca-certificates=${CA_CERTIFICATES_VERSION}"; \
    rm -rf /var/lib/apt/lists/*

# Asterisk-User anlegen (idempotent), Verzeichnisse/Ownership
RUN set -eux; \
    if ! id -u asterisk >/dev/null 2>&1; then \
      adduser --disabled-password --gecos "" asterisk; \
    fi; \
    mkdir -p /var/lib/asterisk /etc/asterisk /var/log/asterisk /run/asterisk; \
    chown -R asterisk:asterisk /var/lib/asterisk /etc/asterisk /var/log/asterisk /run/asterisk

# Konfiguration & Entrypoint
# Keine Brace-Expansion, und direkt mit Ownership kopieren (SC3009/Best Practice)
COPY --chown=asterisk:asterisk configs/ /etc/asterisk/
COPY --chown=asterisk:asterisk entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ports: SIP (UDP 5060), optional TLS (TCP 5061), RTP
EXPOSE 5060/udp 5061/tcp 10000-20000/udp

USER asterisk
WORKDIR /var/lib/asterisk

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s \
  CMD /bin/sh -c 'asterisk -rx "core show uptime" >/dev/null 2>&1 || exit 1'

# Tini als PID 1
ENTRYPOINT ["/usr/bin/tini","--","/entrypoint.sh"]
