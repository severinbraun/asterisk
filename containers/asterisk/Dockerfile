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

# hadolint ignore=DL3008
# System + Asterisk (alle Versionen streng gepinnt; openssl bewusst ungepinnt)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      tzdata=${TZDATA_VERSION} \
      ca-certificates=${CA_CERTIFICATES_VERSION} \
      curl=${CURL_VERSION} \
      openssl \
      tini=${TINI_VERSION} \
      asterisk=${ASTERISK_VERSION}; \
    rm -rf /var/lib/apt/lists/*

# CN/SAN steuerbar (Defaults passen für LAN/WSS-Tests)
ARG ASTERISK_CN=asterisk.veenpark.de
ARG ASTERISK_SAN=DNS:asterisk.veenpark.de,IP:192.168.2.48

# Verzeichnisse & Rechte + Self-signed Zertifikat/Key erstellen (ohne Heredoc)
RUN set -eux; \
    mkdir -p /etc/asterisk/keys /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk; \
    chown -R asterisk:asterisk /etc/asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk /run/asterisk; \
    umask 077; \
    { \
      echo '[req]'; \
      echo 'distinguished_name = req'; \
      echo 'x509_extensions = v3_req'; \
      echo 'prompt = no'; \
      echo '[req_distinguished_name]'; \
      echo "CN = ${ASTERISK_CN}"; \
      echo '[v3_req]'; \
      echo "subjectAltName = ${ASTERISK_SAN}"; \
    } > /tmp/openssl.cnf; \
    openssl req -x509 -newkey rsa:2048 -sha256 -days 825 -nodes \
      -keyout /etc/asterisk/keys/asterisk.key \
      -out    /etc/asterisk/keys/asterisk.crt \
      -config /tmp/openssl.cnf -subj "/CN=${ASTERISK_CN}"; \
    chown asterisk:asterisk /etc/asterisk/keys/asterisk.*; \
    chmod 600 /etc/asterisk/keys/asterisk.key; \
    chmod 644 /etc/asterisk/keys/asterisk.crt; \
    rm -f /tmp/openssl.cnf

# Wichtig: Build-Kontext = containers/asterisk → keine Präfixe nötig
COPY --chown=asterisk:asterisk entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=asterisk:asterisk etc/asterisk/ /etc/asterisk/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 5060/udp 5061/udp
EXPOSE 8088/tcp 8089/tcp
EXPOSE 10000-20000/udp

STOPSIGNAL SIGTERM
USER asterisk
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]
