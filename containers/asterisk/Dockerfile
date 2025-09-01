# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
# Diese ARGs kommen aus der CI (build-args) – hier nur Defaults, damit lokale Builds gehen.
ARG OWNER="local"
ARG REPO="asterisk"

# Labels ohne undefined-var Warnungen
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.licenses="MIT"

# asterisk + minimal tools
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk tzdata ca-certificates dumb-init; \
    rm -rf /var/lib/apt/lists/*

# Nutzer nur anlegen, wenn nicht vorhanden (Ubuntu bringt oft 'asterisk' schon mit)
RUN set -eux; \
    if ! id -u asterisk >/dev/null 2>&1; then \
      adduser --system --group --home /var/lib/asterisk asterisk; \
    fi

# Runtime/Log/Spool vorbereiten
RUN set -eux; \
    mkdir -p /var/run/asterisk /var/log/asterisk /var/spool/asterisk; \
    chown -R asterisk:asterisk /var/run/asterisk /var/log/asterisk /var/spool/asterisk /var/lib/asterisk

# Minimale, funktionierende Configs einspielen
COPY etc/asterisk/ /etc/asterisk/
RUN set -eux; chown -R asterisk:asterisk /etc/asterisk

# kleiner Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
  CMD asterisk -rx 'core show uptime' >/dev/null 2>&1 || exit 1

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5060/udp 5060/tcp 5061/tcp 10000-10100/udp

ENTRYPOINT ["/usr/bin/dumb-init","--"]
CMD ["/entrypoint.sh"]
