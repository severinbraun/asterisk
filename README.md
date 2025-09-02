# Asterisk

[![Lint](https://github.com/severinbraun/asterisk/actions/workflows/lint.yml/badge.svg)](https://github.com/severinbraun/asterisk/actions/workflows/lint.yml)
[![Build & Push](https://github.com/severinbraun/asterisk/actions/workflows/build-push.yml/badge.svg)](https://github.com/severinbraun/asterisk/actions/workflows/build-push.yml)
[![Security Scan](https://github.com/severinbraun/asterisk/actions/workflows/security_scan.yml/badge.svg)](https://github.com/severinbraun/asterisk/actions/workflows/security_scan.yml)

**Image:** `ghcr.io/severinbraun/asterisk:latest`

```bash
docker pull ghcr.io/severinbraun/asterisk:latest
docker run --rm ghcr.io/severinbraun/asterisk:latest
```

## Nginx-proxy-manager

We need to setup nginx proxy manager to deliver a valid certificate to the clients.

In my case the domain is **asterisk.veenpark.de** which is pointing to my nginx-proxy-manager.
<br>After configuration you can use port 443 to connect the client via SSL/TLS to asterisk.

<img width="248" height="272" alt="Bildschirmfoto 2025-09-02 um 07 45 30" src="https://github.com/user-attachments/assets/9d644d71-24b4-4671-9cf5-f544e06a4363" />
<br>
<img width="247" height="190" alt="Bildschirmfoto 2025-09-02 um 07 45 50" src="https://github.com/user-attachments/assets/6b1b775f-979d-4c0e-b586-fa43faa503eb" />

## Connect home assistant via SIP

**HACS Dashboard plugin:** https://github.com/TECH7Fox/sip-hass-card

Needs to be configured