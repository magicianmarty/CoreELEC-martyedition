#!/usr/bin/env bash
# Clean one package in the container so the next build rebuilds it from source.
# VICTORY reboots under us; an interrupted build leaves half-written objects and
# stamps, which surface later as SIGILL or an internal compiler error in code
# that has nothing to do with the change being made.
set -euo pipefail
PKG="${1:?usage: clean-package.sh <package>}"
PROJECT="${PROJECT:-Amlogic-ce}"; DEVICE="${DEVICE:-Amlogic-no}"; ARCH="${ARCH:-aarch64}"
IMAGE="coreelec-build:trixie"; HERE="$(cd "$(dirname "$0")" && pwd)"
exec podman run --rm --userns=keep-id -v "$(cd "$HERE/.." && pwd):/work:z" -w /work \
  -e PROJECT="$PROJECT" -e DEVICE="$DEVICE" -e ARCH="$ARCH" -e HOME=/work/.buildhome \
  "$IMAGE" bash -lc "mkdir -p \"\$HOME\" && scripts/clean $PKG"
