#!/usr/bin/env bash
# Build one Kodi binary add-on in the container, producing an installable zip
# under target/addons/. Unlike build-in-container.sh this does not rebuild the
# image, so a new emulator core costs a compile rather than a reflash.
#
#   ./scripts-marty/build-addon.sh game.libretro.yabasanshiro
set -euo pipefail

PKG="${1:?usage: build-addon.sh <addon>}"
PROJECT="${PROJECT:-Amlogic-ce}"
DEVICE="${DEVICE:-Amlogic-no}"
ARCH="${ARCH:-aarch64}"
JOBS="${JOBS:-12}"
IMAGE="coreelec-build:trixie"
HERE="$(cd "$(dirname "$0")" && pwd)"

podman image exists "$IMAGE" || podman build -t "$IMAGE" -f "$HERE/Containerfile" "$HERE"

exec podman run --rm --userns=keep-id \
  -v "$(cd "$HERE/.." && pwd):/work:z" -w /work \
  -e PROJECT="$PROJECT" -e DEVICE="$DEVICE" -e ARCH="$ARCH" \
  -e CONCURRENCY_MAKE_LEVEL="$JOBS" \
  -e HOME=/work/.buildhome \
  "$IMAGE" bash -lc "mkdir -p \"\$HOME\" && scripts/create_addon $PKG"
