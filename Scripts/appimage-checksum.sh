#!/usr/bin/env bash
# appimage-checksum.sh — compute SHA256 of an AppImage and write a .sha256 file
#
# Usage: ./appimage-checksum.sh <path-to-AppImage>
#
# Writes:
#   <AppImage>.sha256          (in the same directory, standard `sha256sum` format)
#   hash=<hex>                 to $GITHUB_OUTPUT (when running in GitHub Actions)
#
# Exits non-zero if:
#   - no argument supplied
#   - the AppImage does not exist
#   - sha256sum fails

set -euo pipefail

APPIMAGE="${1:?usage: $0 <path-to-AppImage>}"

if [ ! -f "$APPIMAGE" ]; then
    echo "❌ Not a file: $APPIMAGE" >&2
    exit 1
fi

# --- Compute hash -----------------------------------------------------------
HASH=$(sha256sum "$APPIMAGE" | awk '{print $1}')
if [ -z "$HASH" ]; then
    echo "❌ sha256sum produced no output for $APPIMAGE" >&2
    exit 1
fi
echo "SHA256: $HASH"

# --- Write the checksum file ------------------------------------------------
# Format matches `sha256sum <file>` so users can run:
#     sha256sum -c <AppImage>.sha256
sha256sum "$APPIMAGE" > "${APPIMAGE}.sha256"
cat "${APPIMAGE}.sha256"

# --- Emit to $GITHUB_OUTPUT if we're in Actions -----------------------------
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "hash=$HASH" >> "$GITHUB_OUTPUT"
fi
