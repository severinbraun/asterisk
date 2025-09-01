# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
# Nur für Labels – verhindern "UndefinedVar"-Lint-Fehler, falls nicht übergeben
ARG OWNER=unknown
ARG REPO=asterisk

# Basis-Pakete + Asterisk + gosu (zum Privilege-Drop im Entrypoint)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk \
      gosu \
      ca-certificates \
      tzdata \
      curl; \
    rm -rf /var/lib/apt/lists/*

# Service-User sicherstellen (Fehler vermeiden, falls schon vorhanden)
RUN id -u asterisk >/dev/null 2>&1 || adduser --disabled-password --gecos "" asterisk

# Konfig (nur das, was du überschreiben willst)
# -> modules.conf legen wir hier ab
COPY etc/asterisk/modules.conf /etc/asterisk/modules.conf

# Entrypoint (legt Laufzeit-Verzeichnisse an, chowned sie und startet Asterisk als 'asterisk')
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# OCI-Labels
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="asterisk" \
      org.opencontainers.image.description="Minimal Asterisk (Ubuntu 24.04) with gosu entrypoint"

# SIP + RTP
EXPOSE 5060/udp 5061/tcp 5061/udp 10000-20000/udp

# Optional, aber praktisch
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
  CMD /usr/sbin/asterisk -rx 'core show uptime' >/dev/null 2>&1 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
