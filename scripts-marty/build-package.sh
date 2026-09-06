#!/usr/bin/env bash
# Build a single package in the container, for iterating on a patch without
# rebuilding the whole image.
#
#   ./scripts-marty/build-package.sh kodi
#
# Changing a package's patches makes CoreELEC re-extract and re-patch its
# source, so this still recompiles that package from scratch.
set -euo pipefail

PKG="${1:?usage: build-package.sh <package>}"
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
  "$IMAGE" bash -lc "mkdir -p \"\$HOME\" && scripts/build $PKG"
