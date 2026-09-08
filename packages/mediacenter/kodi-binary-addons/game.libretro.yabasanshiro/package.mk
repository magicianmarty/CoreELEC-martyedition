# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="game.libretro.yabasanshiro"
PKG_VERSION="3.4.2.16-Omega"
PKG_SHA256="40a68ce0e0e351258f9f3b5272e41e75bfa62b6228978b6d3084df5fc719f75d"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/kodi-game/game.libretro.yabasanshiro"
PKG_URL="https://github.com/kodi-game/game.libretro.yabasanshiro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain tinyxml ${MEDIACENTER}:host libretro-yabasanshiro"
PKG_SECTION=""
PKG_LONGDESC="game.libretro.yabasanshiro: Yaba Sanshiro Saturn emulator for Kodi"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="kodi.gameclient"
