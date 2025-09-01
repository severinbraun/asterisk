# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

LABEL org.opencontainers.image.description="Asterisk + FreePBX base (Ubuntu 24.04 LTS)" \
      org.opencontainers.image.licenses="MIT"

# ---- Build-time Metadata (optional) ----
ARG OWNER=${OWNER:-unknown}
ARG REPO=${REPO:-asterisk}

# ---- Paketversionen: aus deinem apt-cache policy Output gepinnt ----
ARG APACHE2_VERSION=2.4.58-1ubuntu8.8
ARG MARIADB_SERVER_VERSION=1:10.11.13-0ubuntu0.24.04.1
ARG ASTERISK_VERSION=1:20.6.0~dfsg+~cs6.13.40431414-2build5

# PHP 8.3 Kern + Extensions
ARG PHP_VERSION=2:8.3+93ubuntu2
ARG PHP_CLI_VERSION=2:8.3+93ubuntu2
ARG PHP_COMMON_VERSION=2:93ubuntu2
ARG PHP_CURL_VERSION=2:8.3+93ubuntu2
ARG PHP_MYSQL_VERSION=2:8.3+93ubuntu2
ARG PHP_XML_VERSION=2:8.3+93ubuntu2
ARG PHP_MBSTRING_VERSION=2:8.3+93ubuntu2
ARG PHP_GD_VERSION=2:8.3+93ubuntu2
ARG PHP_ZIP_VERSION=2:8.3+93ubuntu2
ARG PHP_BCMATH_VERSION=2:8.3+93ubuntu2
ARG PHP_INTL_VERSION=2:8.3+93ubuntu2

# Tools
ARG SOX_VERSION=14.4.2+git20190427-4build4
ARG LAME_VERSION=3.100-6build1
ARG TINI_VERSION=0.19.0-1
ARG TZDATA_VERSION=2025b-0ubuntu0.24.04.1
ARG CURL_VERSION=8.5.0-2ubuntu10.6
ARG CA_CERTIFICATES_VERSION=20240203

# OCI-Labels dynamisch
LABEL org.opencontainers.image.source="https://github.com/${OWNER}/${REPO}" \
      org.opencontainers.image.title="${REPO}"

# ----- Basis-System & Repos -----
ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008,DL3005
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends software-properties-common ca-certificates=${CA_CERTIFICATES_VERSION}; \
    add-apt-repository -y universe; \
    add-apt-repository -y multiverse; \
    apt-get update; \
    # Kernpakete + Asterisk + Web/PHP + Tools (gepinnt)
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
      curl=${CURL_VERSION}; \
    # Apache im Vordergrund betreiben können
    a2enmod rewrite; \
    # Verzeichnisse vorbereiten
    mkdir -p /run/asterisk /var/lib/asterisk /var/log/asterisk /var/run/mysqld; \
    chown -R asterisk:asterisk /run/asterisk /var/lib/asterisk /var/log/asterisk || true; \
    chmod 0775 /var/run/mysqld; \
    # Cleanup
    apt-get purge -y --auto-remove software-properties-common || true; \
    rm -rf /var/lib/apt/lists/*

# Unprivilegierter Nutzer für App-Dateien
RUN adduser --system --group --home /app app
WORKDIR /app

# Entrypoint-Skript hinein
COPY --chown=root:root entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# HTTP, SIP, RTP Standard-Ports (passe nach Bedarf an)
EXPOSE 80 5060/udp 5060/tcp 10000-20000/udp

# Healthcheck sehr simpel (Web lebt?)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD curl -fsS http://127.0.0.1/ || exit 1

# Tini als PID 1; entrypoint startet alle Dienste
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]
CMD ["foreground"]
