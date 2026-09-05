# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 marty

PKG_NAME="libretro-flycast"
PKG_VERSION="45bd2f4e59708a7c16a5bb1cb90a94d1b39e330d"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/flycast"
# Submodules again (libchdr and friends), so git rather than a tarball.
PKG_URL="https://github.com/libretro/flycast.git"
PKG_GIT_CLONE_SINGLE="yes"
PKG_GIT_CLONE_DEPTH="1"
PKG_GIT_SUBMODULE_DEPTH="1"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Sega Dreamcast, Naomi and Atomiswave emulator"
PKG_TOOLCHAIN="make"

PKG_LIBNAME="flycast_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="FLYCAST_LIB"

PKG_MAKE_OPTS_TARGET="platform=unix"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" HAVE_OPENGL=0 HAVE_OPENGLES=1"
fi

if [ "${ARCH}" = "aarch64" ]; then
  PKG_MAKE_OPTS_TARGET+=" WITH_DYNAREC=arm64"
fi

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" >${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
