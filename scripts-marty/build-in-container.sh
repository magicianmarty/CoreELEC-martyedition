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
JOBS="${JOBS:-$(nproc)}"

exec podman run --rm -it \
  -v "$PWD:/work:z" -w /work \
  -e PROJECT="$PROJECT" -e DEVICE="$DEVICE" -e ARCH="$ARCH" -e CONCURRENCY_MAKE_LEVEL="$JOBS" \
  debian:trixie bash -c '
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  bc bsdextrautils bzip2 ca-certificates cpio default-jre-headless device-tree-compiler \
  diffutils file fonts-freefont-ttf g++ gawk gcc gettext git gperf gzip \
  imagemagick libc6-dev libjson-perl libncurses-dev libparse-yapp-perl \
  libxml-parser-perl lzop make patch patchelf perl python3 python3-setuptools \
  rdfind rsync sed texinfo unzip wget xfonts-utils xsltproc xz-utils zip zstd \
  >/dev/null
# The build refuses to run as root.
useradd -m -u "$(stat -c %u /work)" builder 2>/dev/null || true
chown -R builder /work 2>/dev/null || true
su builder -c "PROJECT=$PROJECT DEVICE=$DEVICE ARCH=$ARCH make image"
'
