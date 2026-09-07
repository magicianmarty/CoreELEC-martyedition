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
# No PKG_GIT_CLONE_DEPTH: get_git verifies the pin with `git log | grep`, and a
# depth-1 clone only contains the branch tip, so a pinned older commit is
# unreachable and the build aborts. Submodules are still shallow.
PKG_GIT_SUBMODULE_DEPTH="1"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="PSP emulator"
# PPSSPP's libretro target is CMake, not a libretro/Makefile: libretro/ holds a
# CMakeLists.txt that the top-level build pulls in behind -DLIBRETRO=ON.
PKG_TOOLCHAIN="cmake"

PKG_LIBNAME="ppsspp_libretro.so"
# CMake puts it in lib/ inside the build dir, unlike the make-based cores
PKG_LIBPATH="lib/${PKG_LIBNAME}"
PKG_LIBVAR="PPSSPP_LIB"

# HEADLESS and UNITTEST are separate binaries we have no use for. The X11 and
# Wayland switches matter more than they look: PPSSPP defaults USING_X11_VULKAN
# to ON, and the configure then fails on X11_Xlib_INCLUDE_PATH-NOTFOUND for
# every target in the tree, libretro included. This box has neither X11 nor
# Wayland - Kodi is on GBM/DRM.
PKG_CMAKE_OPTS_TARGET="-DLIBRETRO=ON -DHEADLESS=OFF -DUNITTEST=OFF \
                       -DUSING_X11_VULKAN=OFF -DUSE_WAYLAND_WSI=OFF"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_GLES2=ON -DUSING_EGL=ON"
fi

# Without this the core loads and then dies the moment it runs a game:
#
#   kodi.bin: symbol lookup error: game.libretro.ppsspp.so:
#             undefined symbol: __aarch64_cas8_acq_rel
#
# GCC's -moutline-atomics (on by default for aarch64) turns atomics into calls
# to __aarch64_cas*/__aarch64_ldadd* helpers, which live in the static libgcc.a
# and not in the libgcc_s.so.1 on the box. They bind lazily, so the core links,
# loads, boots the game's EBOOT and initialises the kernel before the first
# atomic in the emulation loop kills the whole of Kodi with exit 127. None of
# the other cores here reference them.
# The references are not in PPSSPP's own code - they are in the prebuilt
# ffmpeg static libraries it ships in ffmpeg/linux/aarch64/lib, which were
# compiled elsewhere with outline atomics - so no compiler flag on this build
# can remove them. libgcc.a defines both; libgcc_s.so.1 does not, and the
# linker prefers the shared one and is happy to leave the symbols undefined
# because that is legal in a shared object. Forcing the static libgcc resolves
# them at link time instead of failing at the first atomic at run time.
TARGET_LDFLAGS+=" -static-libgcc"

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" >${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
