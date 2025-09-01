# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

# Environment für non-interactive APT
ENV DEBIAN_FRONTEND=noninteractive

# Versions aus versions.env (kann per --build-arg überschrieben werden)
ARG ASTERISK_VERSION=1:20.6.0~dfsg+~cs6.13.40431414-2build5
ARG TINI_VERSION=0.19.0-1
ARG TZDATA_VERSION=2025b-0ubuntu0.24.04.1
ARG CURL_VERSION=8.5.0-2ubuntu10.6
ARG CA_CERTIFICATES_VERSION=20240203

# Labels für OCI-Konformität
LABEL org.opencontainers.image.title="asterisk" \
      org.opencontainers.image.description="Minimal Asterisk container (Ubuntu 24.04 LTS)" \
      org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.licenses="MIT"

# Pakete installieren (fixierte Versionen)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk=${ASTERISK_VERSION} \
      tini=${TINI_VERSION} \
      tzdata=${TZDATA_VERSION} \
      curl=${CURL_VERSION} \
      ca-certificates=${CA_CERTIFICATES_VERSION}; \
    rm -rf /var/lib/apt/lists/lock /var/lib/apt/lists/partial /var/lib/apt/lists/* /tmp/* /var/tmp/*

# User & Arbeitsverzeichnis
RUN adduser --disabled-password --gecos "" asterisk && \
    mkdir -p /var/lib/asterisk && chown -R asterisk:asterisk /var/lib/asterisk

USER asterisk
WORKDIR /var/lib/asterisk

# Healthcheck (Dummy – prüft ob Asterisk läuft)
HEALTHCHECK --interval=30s --timeout=5s CMD pgrep asterisk || exit 1

# Start mit tini als init, Asterisk im Vordergrund
ENTRYPOINT ["/usr/bin/tini", "--", "asterisk", "-f", "-U", "asterisk", "-G", "asterisk"]
