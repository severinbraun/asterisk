# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk \
      asterisk-dev \
      curl ca-certificates tzdata tini; \
    rm -rf /var/lib/apt/lists/*

# Laufzeitverzeichnisse
RUN set -eux; \
    mkdir -p /var/spool/asterisk /var/log/asterisk /var/lib/asterisk; \
    chown -R asterisk:asterisk /var/spool/asterisk /var/log/asterisk /var/lib/asterisk

# Nicht-root
USER asterisk
WORKDIR /var/lib/asterisk

# Sauber im Vordergrund starten
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["asterisk","-f","-T","-vvv"]
