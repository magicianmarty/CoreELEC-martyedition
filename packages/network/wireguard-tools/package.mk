# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wireguard-tools"
PKG_VERSION="1.0.20260223"
PKG_SHA256="859f8af03702db5e5c43f8ece77f5ebef40a2f4627c3e03997a031d4940ea9bc"
PKG_LICENSE="GPL-2.0-only OR MIT"
PKG_SITE="https://www.wireguard.com"
# git.zx2c4.com's cgit snapshot endpoint serves an HTML error page for this
# tag, not a tarball, and CoreELEC's own mirror 404s - so the build could not
# fetch it at all. GitHub's tag archive is a real tarball, is byte-stable, and
# extracts to wireguard-tools-${PKG_VERSION} exactly as unpack expects.
PKG_URL="https://github.com/WireGuard/wireguard-tools/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="WireGuard VPN userspace tools"
PKG_TOOLCHAIN="manual"

make_target() {
  make -C src wg
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  cp -R ${PKG_DIR}/config ${INSTALL}/usr

  cp ${PKG_BUILD}/src/wg ${INSTALL}/usr/bin
}

post_install() {
  # install service for wg0.conf configuration file
  ln -s ../wg-quick@.service \
    ${INSTALL}/usr/lib/systemd/system/multi-user.target.wants/wg-quick@wg0.service
}
