# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

LABEL org.opencontainers.image.title="asterisk"
LABEL org.opencontainers.image.description="Minimal Asterisk on Ubuntu 24.04 (Noble)"
LABEL org.opencontainers.image.licenses="MIT"

# Für Labels/Metadaten (optional)
ARG OWNER=${OWNER:-unknown}
ARG REPO=${REPO:-asterisk}
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}"

# ── Versionen (aus deinem apt-cache policy) ─────────────────────────────────────
ARG ASTERISK_VERSION=1:20.6.0~dfsg+~cs6.13.40431414-2build5
ARG TINI_VERSION=0.19.0-1
ARG TZDATA_VERSION=2025b-0ubuntu0.24.04.1
ARG CURL_VERSION=8.5.0-2ubuntu10.6
ARG CA_CERTIFICATES_VERSION=20240203

ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008,DL3005
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      software-properties-common \
      ca-certificates=${CA_CERTIFICATES_VERSION}; \
    add-apt-repository -y universe; \
    add-apt-repository -y multiverse; \
    apt-get update; \
    # Kritisch gepinnt: Asterisk und Basis-Tools
    apt-get install -y --no-install-recommends \
      asterisk=${ASTERISK_VERSION} \
      tini=${TINI_VERSION} \
      tzdata=${TZDATA_VERSION} \
      curl=${CURL_VERSION}; \
    # Optionale Sounds/MOH (unpinned → weniger streng; kann auf Wunsch gepinnt werden)
    # hadolint ignore=DL3008
    apt-get install -y --no-install-recommends \
      asterisk-core-sounds-en-wav \
      asterisk-moh-opsound-wav; \
    # Verzeichnisse & Rechte (Ubuntu-Paket legt user/group 'asterisk' an)
    install -d -o asterisk -g asterisk /run/asterisk /var/lib/asterisk /var/log/asterisk; \
    # Aufräumen
    apt-get purge -y --auto-remove software-properties-common || true; \
    rm -rf /var/lib/apt/lists/*

# Sinnvolle Volumes für Persistenz (Config/Logs/Spool)
VOLUME ["/etc/asterisk", "/var/lib/asterisk", "/var/spool/asterisk", "/var/log/asterisk"]

# SIP/RTP Standard-Ports
EXPOSE 5060/udp 5060/tcp 10000-20000/udp

# Healthcheck: schlägt fehl, wenn Asterisk nicht antwortet
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD asterisk -rx 'core show uptime seconds' >/dev/null 2>&1 || exit 1

# Entrypoint
COPY --chown=root:root entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Tini als PID1, Asterisk läuft im Vordergrund
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]
CMD ["foreground"]
