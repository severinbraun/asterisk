#!/usr/bin/env bash
set -euo pipefail
VERSION="${1:?usage: ./scripts/release.sh v1.0.0}"
git tag -a "$VERSION" -m "release $VERSION"
git push origin "$VERSION"
echo "Tagged $VERSION"
