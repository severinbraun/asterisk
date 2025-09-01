# Asterisk

[![Lint](https://github.com/${{ github.repository }}/actions/workflows/lint.yml/badge.svg)](https://github.com/${{ github.repository }}/actions/workflows/lint.yml)
[![Build & Push](https://github.com/${{ github.repository }}/actions/workflows/build-push.yml/badge.svg)](https://github.com/${{ github.repository }}/actions/workflows/build-push.yml)
[![Security Scan](https://github.com/${{ github.repository }}/actions/workflows/security_scan.yml/badge.svg)](https://github.com/${{ github.repository }}/actions/workflows/security_scan.yml)

**Image:** `ghcr.io/${{ github.repository }}:latest`

```bash
docker pull ghcr.io/${{ github.repository }}:latest
docker run --rm ghcr.io/${{ github.repository }}:latest
