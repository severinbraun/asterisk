# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

# hadolint wants versions pinned -> wir verwenden Build-ARGs, die aus versions.env kommen
ARG DEBIAN_FRONTEND=noninteractive

# Kernpakete
ARG APACHE2_VERSION
ARG MARIADB_SERVER_VERSION
ARG ASTERISK_VERSION

# PHP
ARG PHP_VERSION
ARG PHP_CLI_VERSION
ARG PHP_COMMON_VERSION
ARG PHP_CURL_VERSION
ARG PHP_MYSQL_VERSION
ARG PHP_XML_VERSION
ARG PHP_MBSTRING_VERSION
ARG PHP_GD_VERSION
ARG PHP_ZIP_VERSION
ARG PHP_BCMATH_VERSION
ARG PHP_INTL_VERSION

# Tools
ARG SOX_VERSION
ARG LAME_VERSION
ARG TINI_VERSION
ARG TZDATA_VERSION
ARG CURL_VERSION
ARG CA_CERTIFICATES_VERSION

# OCI Labels (optional)
ARG OWNER
ARG REPO
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}" \
      org.opencontainers.image.licenses="MIT"

# Basis-Tuning + strikt gepinnte Installationen
RUN --mount=type=cache,target=/var/cache/apt \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      apache2=${APACHE2_VERSION} \
      mariadb-server=${MARIADB_SERVER_VERSION} \
      asterisk=${ASTERISK_VERSION} \
      php=${PHP_VERSION} \
      php-cli=${PHP_CLI_VERSION} \
      php-common=${PHP_COMMON_VERSION} \
      php-curl=${PHP_CURL_VERSION} \
      php-mysql=${PHP_MYSQL_VERSION} \
      php-xml=${PHP_XML_VERSION} \
      php-mbstring=${PHP_MBSTRING_VERSION} \
      php-gd=${PHP_GD_VERSION} \
      php-zip=${PHP_ZIP_VERSION} \
      php-bcmath=${PHP_BCMATH_VERSION} \
      php-intl=${PHP_INTL_VERSION} \
      sox=${SOX_VERSION} \
      lame=${LAME_VERSION} \
      tini=${TINI_VERSION} \
      tzdata=${TZDATA_VERSION} \
      curl=${CURL_VERSION} \
      ca-certificates=${CA_CERTIFICATES_VERSION}; \
    rm -rf /var/lib/apt/lists/*

# App-User
RUN adduser --disabled-password --gecos "" app
USER app
WORKDIR /app

# Deine Files
COPY --chown=app:app entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# (Optional) Apache/PHP Configs reinkopieren
# COPY --chown=app:app apache-vhost.conf /etc/apache2/sites-available/000-default.conf
# COPY --chown=app:app php.ini /etc/php/*/apache2/conf.d/zzz-custom.ini

USER root
EXPOSE 80 443 5060/udp 5060/tcp 5160/udp 5160/tcp 18000-20000/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD ["bash","-c","pgrep -x asterisk >/dev/null && curl -fsS http://127.0.0.1/ || exit 1"]

ENTRYPOINT ["/usr/bin/tini","--","/app/entrypoint.sh"]
