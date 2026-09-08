# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 marty

PKG_NAME="game.libretro.ppsspp"
PKG_VERSION="0.0.1.30-Omega"
PKG_SHA256="3951ef32455223c69975a0f381061e38bd771b894bb42bc0a71ae9a937bf5921"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/kodi-game/game.libretro.ppsspp"
PKG_URL="https://github.com/kodi-game/game.libretro.ppsspp/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain tinyxml ${MEDIACENTER}:host libretro-ppsspp"
PKG_SECTION=""
PKG_LONGDESC="game.libretro.ppsspp: PPSSPP for Kodi"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="kodi.gameclient"

addon() {
  install_binary_addon ${PKG_ADDON_ID}

  # PPSSPP's VFPU lookup tables. The wrapper add-on ships its own copy of
  # PPSSPP's assets and that copy has no vfpu/ at all, so the core logged
  #
  #   [CPU] Error loading 'vfpu/vfpu_asin_lut65536.dat' (size=0, expected: 1536)
  #
  # once per game and fell back to computing those functions instead of looking
  # them up. They come from the core's own source, so they always match it.
  local vfpu="$(get_build_dir libretro-ppsspp)/assets/vfpu"
  if [ -d "${vfpu}" ]; then
    mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/resources/system/PPSSPP/vfpu
    cp -a ${vfpu}/. ${ADDON_BUILD}/${PKG_ADDON_ID}/resources/system/PPSSPP/vfpu/
  fi
}
