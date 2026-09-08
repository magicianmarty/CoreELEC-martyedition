# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-yabasanshiro"
PKG_VERSION="09ed8e5b2e97e7a848ea2514545c34c7b809e399"
PKG_SHA256="4ba9d98c136c34e6fc6fdf2b703103fe9cdf80c38eb2c617533b4da0b5f2f91f"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/yabause"
PKG_URL="https://github.com/libretro/yabause/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Yaba Sanshiro, a faster Saturn emulator than Yabause, for libretro."
PKG_TOOLCHAIN="make"

PKG_LIBNAME="yabasanshiro_libretro.so"
PKG_LIBPATH="yabause/src/libretro/${PKG_LIBNAME}"
PKG_LIBVAR="YABASANSHIRO_LIB"

# The branch's own target for "Amlogic G12A or Allwinner H616": 64-bit, GLES,
# and the AArch64 dynarec. Its AMLG12B target names this exact SoC but builds
# 32-bit userspace, which this image is not. It also sets HAVE_SSE=0 itself.
PKG_MAKE_OPTS_TARGET="-C yabause/src/libretro platform=arm64_cortex_a53_gles3"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" >${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
