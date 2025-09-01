# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
# Diese ARGs kommen aus CI (build-args). Defaults erlauben lokalen Build.
ARG OWNER="local"
ARG REPO="asterisk"

LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.licenses="MIT"

# Basis: Asterisk + minimal Tools
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk tzdata ca-certificates dumb-init; \
    rm -rf /var/lib/apt/lists/*

# User/Dirs vorbereiten (User existiert in Ubuntu meist bereits)
RUN set -eux; \
    if ! id -u asterisk >/dev/null 2>&1; then \
      adduser --system --group --home /var/lib/asterisk asterisk; \
    fi; \
    mkdir -p /var/run/asterisk /var/log/asterisk /var/spool/asterisk; \
    chown -R asterisk:asterisk \
      /var/run/asterisk /var/log/asterisk /var/spool/asterisk /var/lib/asterisk

# Minimale Configs
COPY etc/asterisk/ /etc/asterisk/
RUN set -eux; chown -R asterisk:asterisk /etc/asterisk

# Healthcheck – Container gilt als healthy, wenn Asterisk läuft
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
  CMD asterisk -rx 'core show uptime' >/dev/null 2>&1 || exit 1

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ports: SIP (UDP/TCP) + TLS (optional) + RTP
EXPOSE 5060/udp 5060/tcp 5061/tcp 10000-10100/udp

ENTRYPOINT ["/usr/bin/dumb-init","--"]
CMD ["/entrypoint.sh"]
