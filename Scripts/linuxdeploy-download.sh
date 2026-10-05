#!/usr/bin/env bash
# linuxdeploy-download.sh — single source of truth for linuxdeploy download
# Usage: ./linuxdeploy-download.sh <arch>
#   arch = x86_64 | aarch64
set -euo pipefail

ARCH="${1:?usage: $0 <x86_64|aarch64>}"

LINUXDEPLOY_TAG="1-alpha-20251107-1"
LINUXDEPLOY_BASE="https://github.com/linuxdeploy/linuxdeploy/releases/download"
# -----------------------------------------------------------

BIN="linuxdeploy-${ARCH}.AppImage"
URL="${LINUXDEPLOY_BASE}/${LINUXDEPLOY_TAG}/${BIN}"

echo "Downloading linuxdeploy ${LINUXDEPLOY_TAG} for ${ARCH}"
echo "  URL: ${URL}"
wget -c "${URL}"
chmod +x "${BIN}"
echo "linuxdeploy ready: ${BIN}"
