# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 marty

PKG_NAME="libretro-ppsspp"
PKG_VERSION="fefdf21db531ececa6baf8b45094697db8944779"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/hrydgard/ppsspp"
# Cloned rather than fetched as a tarball: PPSSPP carries its dependencies as
# submodules and a GitHub archive contains none of them.
PKG_URL="https://github.com/hrydgard/ppsspp.git"
PKG_GIT_CLONE_SINGLE="yes"
PKG_GIT_CLONE_DEPTH="1"
PKG_GIT_SUBMODULE_DEPTH="1"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="PSP emulator"
PKG_TOOLCHAIN="make"

PKG_LIBNAME="ppsspp_libretro.so"
PKG_LIBPATH="libretro/${PKG_LIBNAME}"
PKG_LIBVAR="PPSSPP_LIB"

PKG_MAKE_OPTS_TARGET="-C libretro platform=unix"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" GLES=1 FORCE_GLES=1"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" >${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
