# syntax=docker/dockerfile:1.9
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Basis-Tools + Asterisk (chan_sip steckt im Hauptpaket)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      asterisk \
      asterisk-dahdi \
      asterisk-dev \
      curl ca-certificates tzdata tini; \
    rm -rf /var/lib/apt/lists/*

# Laufzeitverzeichnisse (werden via Volumes persistiert)
RUN set -eux; \
    mkdir -p /var/spool/asterisk /var/log/asterisk /var/lib/asterisk; \
    chown -R asterisk:asterisk /var/spool/asterisk /var/log/asterisk /var/lib/asterisk

# Nicht-root betreiben
USER asterisk
WORKDIR /var/lib/asterisk

# Sauber im Vordergrund starten (Tini + Asterisk -f)
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["asterisk","-f","-T","-vvv"]
