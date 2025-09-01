# Ubuntu 24.04, alle Pakete gepinnt, POSIX-only, letzter USER ≠ root
FROM ubuntu:24.04

# ---- Defaults, damit Hadolint keine UndefinedVar meldet ----
ARG OWNER=severinbraun
ARG REPO=asterisk
ARG TAG=latest

# ---- Gepinnte Paketversionen (können per --build-arg übersteuert werden) ----
ARG ASTERISK_VERSION=1:20.6.0~dfsg+~cs6.13.40431414-2build5
ARG TINI_VERSION=0.19.0-1
ARG TZDATA_VERSION=2025b-0ubuntu0.24.04.1
ARG CURL_VERSION=8.5.0-2ubuntu10.6
ARG CA_CERTIFICATES_VERSION=20240203

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Berlin

# OCI Labels
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.url="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.description="Asterisk on Ubuntu 24.04 with pinned package versions"

# System + Asterisk (alle Versionen streng gepinnt)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      tzdata=${TZDATA_VERSION} \
      ca-certificates=${CA_CERTIFICATES_VERSION} \
      curl=${CURL_VERSION} \
      tini=${TINI_VERSION} \
      asterisk=${ASTERISK_VERSION}; \
    rm -rf /var/lib/apt/lists/*

# Verzeichnisse & Rechte
RUN set -eux; \
    mkdir -p /etc/asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk; \
    chown -R asterisk:asterisk /etc/asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk

# Wichtig: da Build-Kontext = containers/asterisk ist,
# brauchen wir KEIN "containers/asterisk/" im Pfad!
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY etc/asterisk/ /etc/asterisk/

RUN chmod +x /usr/local/bin/entrypoint.sh && chown asterisk:asterisk /usr/local/bin/entrypoint.sh

EXPOSE 5060/udp 5061/udp
EXPOSE 10000-10100/udp

STOPSIGNAL SIGTERM

USER asterisk

ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]
