# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

# Defaults, damit Hadolint keine UndefinedVar meldet
ARG OWNER=severinbraun
ARG REPO=asterisk

# Paket-Pins (können via --build-arg aus versions.env überschrieben werden)
ARG ASTERISK_VERSION=1:20.6.0~dfsg+~cs6.13.40431414-2build5
ARG TINI_VERSION=0.19.0-1
ARG TZDATA_VERSION=2025b-0ubuntu0.24.04.1
ARG CURL_VERSION=8.5.0-2ubuntu10.6
ARG CA_CERTIFICATES_VERSION=20240203

LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive

# Alle Pakete strikt gepinnt (DL3008-konform)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk=${ASTERISK_VERSION} \
      tzdata=${TZDATA_VERSION} \
      curl=${CURL_VERSION} \
      ca-certificates=${CA_CERTIFICATES_VERSION} \
      tini=${TINI_VERSION}; \
    rm -rf /var/lib/apt/lists/*

# Asterisk-User sicherstellen & Verzeichnisse
RUN set -eux; \
    if ! id -u asterisk >/dev/null 2>&1; then \
      adduser --disabled-password --gecos "" asterisk; \
    fi; \
    mkdir -p /var/lib/asterisk /var/log/asterisk /etc/asterisk; \
    chown -R asterisk:asterisk /var/lib/asterisk /var/log/asterisk /etc/asterisk

# Konfig-Templates (mit Platzhaltern) & Entrypoint
COPY --chown=asterisk:asterisk etc/asterisk/ /etc/asterisk.tmpl/
COPY --chown=asterisk:asterisk entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Laufzeit-ENV (aus .env / compose)
ENV DOORBIRD_USER=doorbird \
    DOORBIRD_PASS=Caliba#355 \
    HA_USER=homeassistant \
    HA_PASS=Caliba#355 \
    RTP_START=10000 \
    RTP_END=20000 \
    ASTERISK_LOG_LEVEL=notice

# Letzter User: NICHT root (DL3002)
USER asterisk
WORKDIR /var/lib/asterisk

# Tini als sauberes Init; Asterisk im Vordergrund (-f via CMD)
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]
CMD ["-f"]
