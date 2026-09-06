#!/usr/bin/env bash
# Build a CoreELEC image without touching the host.
#
# scripts/checkdeps wants a dozen distro packages installed as root; doing that
# on the dev machine is both intrusive and unreproducible, and it is the same
# reason the game.libretro wrapper is built this way.
#
#   ./scripts-marty/build-in-container.sh
#
# Output lands in target/ exactly as a host build would.
set -euo pipefail

PROJECT="${PROJECT:-Amlogic-ce}"
DEVICE="${DEVICE:-Amlogic-no}"
ARCH="${ARCH:-aarch64}"
# Capped deliberately. binutils 2.47 has a parallel-build race that surfaces as
# undefined references to symbols defined in its own tree; it failed at 32-way
# on this machine and built clean at -j1. Raise it only if you are willing to
# re-diagnose that failure.
JOBS="${JOBS:-12}"
IMAGE="coreelec-build:trixie"
HERE="$(cd "$(dirname "$0")" && pwd)"

podman image exists "$IMAGE" || podman build -t "$IMAGE" -f "$HERE/Containerfile" "$HERE"

# --userns=keep-id: the build refuses to run as root, and without this the host
# user is mapped to root inside and owns nothing it can build with.
exec podman run --rm --userns=keep-id \
  -v "$(cd "$HERE/.." && pwd):/work:z" -w /work \
  -e PROJECT="$PROJECT" -e DEVICE="$DEVICE" -e ARCH="$ARCH" \
  -e CONCURRENCY_MAKE_LEVEL="$JOBS" \
  -e HOME=/work/.buildhome \
  "$IMAGE" bash -lc 'mkdir -p "$HOME" && make image'
