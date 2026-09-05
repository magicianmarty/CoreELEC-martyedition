# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 marty

PKG_NAME="game.libretro.flycast"
PKG_VERSION="7.0.0.66-Omega"
PKG_SHA256="a6a99499bba93da076de6133ec5bb2c36fd4a80047ff3bb0acd1169959dc90f5"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/kodi-game/game.libretro.flycast"
PKG_URL="https://github.com/kodi-game/game.libretro.flycast/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain tinyxml ${MEDIACENTER}:host libretro-flycast"
PKG_SECTION=""
PKG_LONGDESC="game.libretro.flycast: Flycast for Kodi"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="kodi.gameclient"
