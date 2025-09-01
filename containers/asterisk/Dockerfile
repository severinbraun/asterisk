# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

LABEL org.opencontainers.image.title="asterisk" \
      org.opencontainers.image.description="Minimal Asterisk with chan_sip and chan_pjsip" \
      org.opencontainers.image.licenses="MIT"

# Versionen kommen idealerweise aus versions.env (per build-args aus CI)
ARG ASTERISK_VERSION=1:20.6.0~dfsg+~cs6.13.40431414-2build5
ARG TINI_VERSION=0.19.0-1
ARG TZDATA_VERSION=2025b-0ubuntu0.24.04.1
ARG CURL_VERSION=8.5.0-2ubuntu10.6
ARG CA_CERTIFICATES_VERSION=20240203

ENV DEBIAN_FRONTEND=noninteractive

# Asterisk + minimale Tools
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk=${ASTERISK_VERSION} \
      tini=${TINI_VERSION} \
      tzdata=${TZDATA_VERSION} \
      curl=${CURL_VERSION} \
      ca-certificates=${CA_CERTIFICATES_VERSION}; \
    rm -rf /var/lib/apt/lists/*

# Verzeichnisse vorbereiten & Ownership – asterisk-User kommt aus dem Paket
RUN set -eux; \
    mkdir -p /etc/asterisk /var/lib/asterisk /var/log/asterisk; \
    chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/log/asterisk

# Volumes (optional, für Persistenz/Bind-Mounts)
VOLUME ["/etc/asterisk", "/var/lib/asterisk", "/var/log/asterisk"]

# SIP/RTP
EXPOSE 5060/udp 5061/udp 10000-20000/udp

# Nicht als root laufen
USER asterisk
WORKDIR /var/lib/asterisk

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s \
  CMD /usr/sbin/asterisk -rx "core show version" >/dev/null 2>&1 || exit 1

# Tini als PID 1
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["asterisk", "-f", "-U", "asterisk"]
