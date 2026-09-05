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
