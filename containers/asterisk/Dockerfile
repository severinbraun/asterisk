# syntax=docker/dockerfile:1.9

# Ziel: Ubuntu LTS (24.04), minimal installierte Pakete, alles in einem Container
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG OWNER
ARG REPO
ARG FREEPBX_VERSION=16        # 16 (LTS) ist üblich; Installation passiert beim 1. Start

# OCI-Metadaten
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.licenses="MIT"

# Basispakete + Dienste ohne Recommends
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates curl tzdata tini \
      apache2 \
      mariadb-server \
      asterisk asterisk-pjsip asterisk-opus asterisk-moh-opsound-wav asterisk-core-sounds-en \
      php php-cli php-curl php-mysql php-xml php-mbstring php-gd php-zip php-bcmath php-intl \
      sox lame procps net-tools; \
    # Apache minimal härten + Rewrite
    a2dismod status || true; a2enmod rewrite headers ssl; \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

# Apache-Konfig, PHP-Tuning, Entrypoint
COPY --chown=root:root apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY --chown=root:root php.ini            /etc/php/*/apache2/conf.d/99-freepbx.ini
COPY --chown=root:root entrypoint.sh      /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Verzeichnisse für Persistenz (werden via Volumes gemountet)
VOLUME ["/var/lib/mysql", "/var/lib/asterisk", "/etc/asterisk", "/var/spool/asterisk", "/var/log/asterisk", "/var/www/html"]

# Ports: SIP/PJSIP + RTP + WebUI
EXPOSE 5060/udp 5160/udp 5061/tcp 80 443 10000-20000/udp

# Healthcheck: prüft Asterisk-Uptime (nach dem Start)
HEALTHCHECK --interval=30s --timeout=5s CMD bash -lc "asterisk -rx 'core show uptime' >/dev/null 2>&1 || exit 1"

# Tini als PID 1, damit Prozesse sauber gehandhabt werden
ENTRYPOINT ["/usr/bin/tini","--","/entrypoint.sh"]
