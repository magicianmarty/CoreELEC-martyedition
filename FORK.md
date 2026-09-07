# marty-22 — a CoreELEC fork

Tracks `coreelec-22`. Everything here exists to run emulators inside the Kodi
interface rather than beside it.

## Why a fork at all

Kodi's RetroPlayer refuses hardware rendering — `CGameClientStreams::EnableHardwareRendering()`
logs *"Hardware rendering not implemented"* and returns false. Any core that
needs a GL context therefore cannot start. Checked across all 75 game clients in
the repo, exactly two are blocked by this today (`requires_opengl=true` in their
`addon.xml`): **mupen64plus-nx** and **vecx**. PSP and Dreamcast are not blocked
so much as absent — no core is packaged at all.

Nothing about this is specific to Kodi's renderer being incapable. RetroArch
runs the same cores on the same SoC; it simply hands them a context.

## What is ours

**This is not a fork of Kodi.** CoreELEC builds stock Kodi from an xbmc release
tarball and applies numbered patches from `packages/mediacenter/kodi/patches/`.
Upstream owns `1001`–`1015`. Ours start at **`1016`**, which keeps every change
reviewable, independently revertible and — the point — independently
upstreamable.

New emulators are *additions* under `packages/emulation/` and
`packages/mediacenter/kodi-binary-addons/`, so they never conflict on rebase.

| Ours | What |
|---|---|
| `packages/emulation/libretro-ppsspp` | PSP core (git + submodules; the GitHub tarball has none) |
| `packages/emulation/libretro-flycast` | Dreamcast core (likewise) |
| `packages/mediacenter/kodi-binary-addons/game.libretro.ppsspp` | Kodi game client for the above |
| `packages/mediacenter/kodi-binary-addons/game.libretro.flycast` | Kodi game client for the above |

⚠️ **The four packages above have never been built.** Their metadata is
verified — upstream repos exist, commit SHAs and tarball hashes were computed,
and both `kodi-game` wrapper repos are real with current tags — but the make
flags are modelled on `libretro-pcsx-rearmed` and will need adjusting on the
first build. Treat them as a starting point, not a working port.

## Rebasing onto upstream

Rebase, never merge — the patch series has to stay a series.

```sh
git fetch upstream
git rebase upstream/coreelec-22
```

Watch `packages/mediacenter/kodi/package.mk`: `PKG_VERSION` is the Kodi pin.
It moved to `22.0b2-Piers` (Game ABI **8.0.0**, up from 6.0.0 in b1), which is
why a plain rebuild retires the hand-built ABI-6 `game.libretro` wrapper.

## Building

**Build in the container.** `scripts-marty/` already wraps this:

```sh
./scripts-marty/build-in-container.sh       # the whole image
./scripts-marty/build-package.sh kodi       # one package, for patch iteration
```

Not merely because `scripts/checkdeps` wants packages installed as root -
**a host build actively damages the tree.** The toolchain wrappers under
`build.*/toolchain/bin` have `/work` baked in as an absolute path, so the build
dies at the first `host-gcc` call with

    /work/.../ccache: No such file or directory

and on the way down leaves files in the build tree labelled `user_tmp_t`, moved
in from the host's `/tmp`. The container then cannot unlink its own package
cache:

    mv: unable to remove target: Permission denied

The `:z` on the volume mount is what keeps that recoverable - it relabels the
tree shared on every run. A mount without it gets per-container SELinux MCS
categories, and then each build is unable to delete what the last one wrote.

The environment those scripts set is not a guess: `PROJECT=Amlogic-ce`,
`DEVICE=Amlogic-no`, `ARCH=aarch64` are what the running box reports in
`/etc/os-release`. Building `Amlogic/AMLGX` instead produces an image for
different hardware. `JOBS` is capped at 12 on purpose; see the binutils note in
`scripts-marty/build-in-container.sh`.

Output is a `.tar` under `target/`, installed by dropping it in
`/storage/.update/` and rebooting. That is CoreELEC's supported update path;
the root filesystem is a read-only squashfs, so a patched `kodi.bin` cannot
simply be copied onto a running box.

**Recovery matters more than the build.** Keep a stock CoreELEC image on SD and
confirm the box boots from it *before* installing anything from here.
