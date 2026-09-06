# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 marty

PKG_NAME="libretro-flycast"
PKG_VERSION="45bd2f4e59708a7c16a5bb1cb90a94d1b39e330d"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/flycast"
PKG_SHA256="5ebf68c4548e5ba0521478f5172abd7f2ca5a3e15060cb78da011e3b03f3fb10"
PKG_URL="https://github.com/libretro/flycast/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Sega Dreamcast, Naomi and Atomiswave emulator"
PKG_TOOLCHAIN="make"

PKG_LIBNAME="flycast_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="FLYCAST_LIB"

# HAVE_OPENMP=0: the cross toolchain ships no libgomp, and flycast defaults it
# on, so core/rend/TexCache.cpp fails on a missing omp.h. Setting it to 0 makes
# the source take its own TARGET_NO_OPENMP path.
PKG_MAKE_OPTS_TARGET="platform=unix HAVE_OPENMP=0"

# FORCE_GLES, not HAVE_OPENGLES: the latter is a define the Makefile derives
# from GLES, so setting it directly leaves GL_LIB at -lGL and the build pulls
# in GL/gl.h, which the target sysroot does not have.
# HAVE_GL2 pairs with FORCE_GLES. platform=unix otherwise defaults HAVE_GL3=1,
# and glsm then calls glGenVertexArrays/glBindVertexArray, which do not exist in
# the GLES 2.0 headers FORCE_GLES selects.
if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=1 HAVE_GL2=1"
fi

# platform=unix turns Vulkan on by default. There is no Vulkan driver for the
# S922X Mali here, and the core negotiates Vulkan before GLES.
PKG_MAKE_OPTS_TARGET+=" HAVE_VULKAN=0"


# HAVE_GENERIC_JIT defaults to 1 and every platform with a real dynarec turns it
# off - but platform=unix only does so for x86, so aarch64 built both the
# generic C++ recompiler and the arm64 one and the link failed on nine
# duplicate ngen_* symbols. Leaving it on would also have meant TARGET_NO_JIT,
# i.e. an interpreter, which is not going to run Dreamcast on this box.
#
# LDFLAGS_END lands after the objects on the link line, which is where libgcc
# has to be: the aarch64 build needs its outline-atomics helpers
# (__aarch64_ldadd4_acq_rel and friends) and nothing else pulls them in. Its
# only other use is a Windows branch, and it is a single token, so it survives
# scripts/build expanding PKG_MAKE_OPTS_TARGET unquoted.
if [ "${ARCH}" = "aarch64" ]; then
  PKG_MAKE_OPTS_TARGET+=" WITH_DYNAREC=arm64 HAVE_GENERIC_JIT=0 LDFLAGS_END=-lgcc"
fi

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" >${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
