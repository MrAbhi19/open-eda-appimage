---
layout: default
title: OpenSTA
nav_order: 4
---

# OpenSTA
{: .no_toc }

**OpenSTA** — a gate-level static timing verifier.
{: .fs-6 .fw-300 }

<details open markdown="block">
  <summary>Table of contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## About OpenSTA

OpenSTA is a gate-level static timing analyzer (STA). It reads a netlist,
Liberty timing libraries, SDC constraints and parasitics (SPEF/DSPF), and
reports whether a design meets its timing constraints, without needing
simulation vectors. It is scripted through a Tcl interpreter, supports
multiple corners and modes, and is the timing engine behind several
open-source physical design flows such as OpenROAD. Having a standalone
`sta` binary is handy for checking a synthesized netlist (for example one
produced by Yosys) without installing a full place-and-route flow.

- **Upstream project:** [parallaxsw/OpenSTA](https://github.com/parallaxsw/OpenSTA)
- **License:** GNU GPL v3 (see
  [LICENSE-OpenSTA](https://github.com/opensiliconhub/open-eda-appimage/blob/main/LICENSE-OpenSTA))
  — copyright Parallax Software, Inc.

> This is an **unofficial** repackaging. OpenSTA is developed by Parallax
> Software, Inc. and contributors. Bugs in OpenSTA itself should be reported
> upstream; packaging problems belong in this repository's
> [issue tracker](https://github.com/opensiliconhub/open-eda-appimage/issues).

---

## How to download

OpenSTA follows a **rolling** release model, like ABC. There is one release
tag, `opensta-appimage`, and every build overwrites the previous assets.
Files are named:

```
opensta-<arch>.AppImage
opensta-<arch>.AppImage.sha256
```

where `<arch>` is `x86_64` or `aarch64`. There is no version number in the
filename. The release title and notes state the OpenSTA version (read from
upstream's `CMakeLists.txt`) and the exact upstream commit the binary was
built from. That commit is also the corresponding source for the GPL (see
[License](#license)).

### x86_64

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/opensta-appimage/opensta-x86_64.AppImage
chmod +x opensta-x86_64.AppImage
./opensta-x86_64.AppImage -version
```

### aarch64 (ARM64)

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/opensta-appimage/opensta-aarch64.AppImage
chmod +x opensta-aarch64.AppImage
./opensta-aarch64.AppImage -version
```

Run `./opensta-x86_64.AppImage` with no arguments to start the interactive
Tcl shell, or pass a Tcl script as an argument to run it.

### Verify the download

Download the `.sha256` file from the same release into the same directory, then:

```sh
sha256sum -c opensta-x86_64.AppImage.sha256
```

Because the release is rolling, always download the AppImage and its checksum
at the same time.

### Requirements

- Linux x86_64 or aarch64
- glibc 2.35 or newer (Ubuntu 22.04+, Debian 12+, Fedora 36+, or equivalent)
- **Tcl 8.6 is bundled** inside the AppImage; you don't need Tcl installed
- FUSE 2 for direct execution (`libfuse2` on Debian/Ubuntu, `fuse2` on
  Fedora). Without FUSE, run with `--appimage-extract-and-run`.

---

## How it is built

Everything happens in the
[`build-opensta-appimage.yml`](https://github.com/opensiliconhub/open-eda-appimage/blob/main/.github/workflows/build-opensta-appimage.yml)
workflow on GitHub-hosted runners. No step is performed by hand.

### Triggers

| Trigger | Details |
|---|---|
| Schedule | Cron `0 6 1 * *`: 06:00 UTC on the 1st of each month |
| Manual | `workflow_dispatch` |

Each run builds from the **latest upstream commit**, so the release tracks
upstream's default branch.

### Build matrix

Each architecture is built **natively** (no cross-compilation, no emulation):

| Architecture | Runner |
|---|---|
| x86_64 | `ubuntu-22.04` |
| aarch64 | `ubuntu-22.04-arm` |

`fail-fast` is disabled, so one architecture failing doesn't cancel the other.
Ubuntu 22.04 is used deliberately: it ships glibc 2.35, which sets the
minimum glibc for the resulting AppImage. The job timeout is 90 minutes.

### Step by step

**1. Install build dependencies**

```sh
sudo apt-get update
sudo apt-get install -y \
  gawk git make cmake gcc g++ \
  bison flex \
  libffi-dev libfl-dev libreadline-dev \
  tcl-dev zlib1g-dev \
  libeigen3-dev \
  autoconf automake libtool \
  swig \
  wget curl file desktop-file-utils \
  python3-pil \
  libfuse2
```

Notable packages: `tcl-dev` and `swig` provide the Tcl interface,
`libeigen3-dev` is a numeric dependency, and `autoconf`/`automake`/`libtool`
are needed to build CUDD. `python3-pil` is used only to generate the
placeholder icon, and `libfuse2` lets the runner execute AppImages.

**2. Build and install CUDD**

OpenSTA depends on the CUDD decision-diagram library, which is not packaged
for Ubuntu 22.04 in a suitable form, so it is built from source first. The
workflow discovers the newest `3.x.y` release tag of
[cuddorg/cudd](https://github.com/cuddorg/cudd) and builds it:

```sh
git clone --depth 1 --branch "$CUDD_TAG" https://github.com/cuddorg/cudd.git cudd-src
cd cudd-src
autoreconf -i
./configure --prefix=/usr/local --enable-shared --enable-static
make -j"$(nproc)"
sudo make install
sudo ldconfig
test -f /usr/local/include/cudd.h
```

**3. Clone the upstream source**

```sh
git clone --depth 1 https://github.com/parallaxsw/OpenSTA.git opensta-src
```

The shallow clone takes the latest commit. The full hash is recorded for the
release notes. OpenSTA hardcodes its version in `CMakeLists.txt`, for example
`project(OpenSTA VERSION 3.1.0)`, so the workflow extracts it from there and
shows it in the release title (`unknown` if it can't be parsed).

**4. Configure with CMake**

```sh
cmake -B build opensta-src \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCUDD_DIR=/usr/local
```

| Flag | Why |
|---|---|
| `CMAKE_BUILD_TYPE=Release` | Optimised build |
| `CMAKE_INSTALL_PREFIX=/usr` | Standard prefix for the AppDir layout |
| `CUDD_DIR=/usr/local` | Points OpenSTA at the CUDD installed in step 2 |

**5. Build**

```sh
cmake --build build --config Release --parallel "$(nproc)"
```

**6. Install into an AppDir**

```sh
cmake --install build --prefix AppDir/usr --strip
```

`--strip` removes debug symbols from the installed binaries. The OpenSTA
executable is named `sta`.

**7. Bundle the Tcl runtime**

OpenSTA embeds a Tcl interpreter, which needs both `libtcl8.6` **and** the Tcl
script library (`init.tcl` and friends) at runtime. linuxdeploy only copies
shared libraries, so the workflow bundles Tcl by hand:

1. Locate the `tclsh` on the runner and copy the exact `libtcl` it links
   against into `AppDir/usr/lib`.
2. Copy the matching script library from `/usr/share/tcltk/tcl8.6` into
   `AppDir/usr/lib/tcl8.6`.
3. Sanity-check that `init.tcl` requires the same Tcl patch level as the
   bundled `libtcl`, so the two can't drift apart.

**8. Create a custom AppRun**

The default AppRun doesn't know where the bundled Tcl script library lives,
so the workflow writes its own:

```sh
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
export TCL_LIBRARY="$HERE/usr/lib/tcl8.6"
export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PATH="$HERE/usr/bin${PATH:+:$PATH}"
exec "$HERE/usr/bin/sta" "$@"
```

`TCL_LIBRARY` points the interpreter at the bundled script library, so the
AppImage works on machines with no Tcl, or with a different Tcl version.

**9. Create the desktop entry and icon**

An `opensta.desktop` file is written to `AppDir/usr/share/applications/`:

```ini
[Desktop Entry]
Name=OpenSTA
Exec=sta
Icon=opensta
Type=Application
Categories=Development;Electronics;
Terminal=true
Comment=OpenSTA Static Timing Analyzer
```

AppImages require an icon, so a plain 256×256 RGBA PNG (solid red-orange,
`200,60,30`) is generated with Pillow and saved to
`AppDir/usr/share/icons/hicolor/256x256/apps/opensta.png`.

**10. Package with linuxdeploy**

| Tool | Version |
|---|---|
| linuxdeploy | `continuous` (latest rolling build, per-architecture AppImage) |
| AppImage output | linuxdeploy's built-in `appimage` output, bundled with that linuxdeploy build |
| Compression | `zstd` (`OUTPUT_APPIMAGE_COMP=zstd`) |
| Excluded libraries | `*libtcl8.6.so*;*libtk8.6.so*` (via `LINUXDEPLOY_EXCLUDE_LIBS`) |

linuxdeploy is downloaded from
`https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-<arch>.AppImage`,
where `<arch>` is `x86_64` or `aarch64`.

```sh
export OUTPUT_APPIMAGE_COMP=zstd
export LINUXDEPLOY_EXCLUDE_LIBS="*libtcl8.6.so*;*libtk8.6.so*"
./linuxdeploy-<arch>.AppImage \
  --appdir AppDir \
  --executable AppDir/usr/bin/sta \
  --custom-apprun AppRun \
  --desktop-file AppDir/usr/share/applications/opensta.desktop \
  --icon-file AppDir/usr/share/icons/hicolor/256x256/apps/opensta.png \
  --output appimage
```

A few details worth knowing:

- `--executable` points at the real `sta` ELF binary, not a wrapper script,
  so linuxdeploy can resolve its dependencies.
- `--custom-apprun` installs the Tcl-aware AppRun from the previous step.
- Tcl and Tk are excluded from linuxdeploy's automatic handling because the
  matching `libtcl` was already copied by hand in step 7, together with its
  script library. The exclusion patterns match on the library's basename,
  because the dynamic loader reports paths like `/lib/...` on Ubuntu rather
  than `/usr/lib/...`.

linuxdeploy copies the remaining shared libraries (readline, libffi, CUDD, the
C++ runtime libraries, and so on) into `AppDir/usr/lib`, then produces a
single squashfs-based AppImage. The output is renamed to
`opensta-<arch>.AppImage`, and the workflow fails if no AppImage was produced.

**11. Verify the AppImage contents**

The AppImage is extracted (`--appimage-extract`) and checked:

- **No broken symlinks** in `usr/lib` (`find ... -xtype l`). Any broken link fails the build.
- **No missing shared libraries**: `ldd` on the bundled `sta` binary must not report `not found`.

**12. Smoke test**

```sh
chmod +x opensta-<arch>.AppImage
./opensta-<arch>.AppImage -version
echo 'puts "TCL_SMOKE_OK"' | ./opensta-<arch>.AppImage 2>&1 | tee smoke.log
grep -q "TCL_SMOKE_OK" smoke.log
```

The first check confirms the binary starts and prints a version. The second
pipes a one-line Tcl script into the shell and checks the output, which
exercises the bundled Tcl runtime end to end. If `TCL_LIBRARY` or the bundled
script library were wrong, this is the step that would fail.

**13. Checksum**

```sh
sha256sum opensta-<arch>.AppImage > opensta-<arch>.AppImage.sha256
```

**14. Publish**

- The AppImage and its `.sha256` are uploaded as a workflow artifact, kept for
  14 days.
- They are attached to the rolling GitHub Release tagged `opensta-appimage`
  with `softprops/action-gh-release`, with `overwrite_files` enabled so each
  run replaces the previous assets.
- The release notes include the OpenSTA version, source commit, build date,
  and a link to the workflow run.
- The release is **not** marked as "Latest", so it doesn't displace the
  tool-version releases (such as Yosys) on the repository's front page.

---

## License

OpenSTA is **dual licensed**: it is released under the **GNU GPL v3**, and
Parallax Software separately offers commercial licenses. This project
redistributes only the GPL v3 build.

- The full GPL v3 text is in this repository as
  [LICENSE-OpenSTA](https://github.com/opensiliconhub/open-eda-appimage/blob/main/LICENSE-OpenSTA).
- The source used for each build is unmodified upstream source. The exact
  commit is linked in the release notes, so the corresponding source for any
  published binary can be obtained from there.
- The AppImage also bundles **CUDD** (BSD 3-clause, Copyright (c) 1995-2004
  Regents of the University of Colorado), see
  [LICENSE-CUDD](https://github.com/opensiliconhub/open-eda-appimage/blob/main/LICENSE-CUDD),
  plus Tcl, readline and other system libraries under their own licenses.
- If you modify OpenSTA and redistribute it, the GPL v3 applies to your
  changes too.

---

## Build summary

| Item | Value |
|---|---|
| Source | Latest commit of `parallaxsw/OpenSTA` (shallow clone) |
| Extra dependency | CUDD (latest `3.x.y` tag, built from source) |
| Build system | CMake |
| Build type | Release |
| Compiler | `gcc` / `g++` |
| Runners | `ubuntu-22.04`, `ubuntu-22.04-arm` |
| License | GPL v3 (OpenSTA), BSD (CUDD) |
| Tcl | 8.6, bundled (library + script directory, custom AppRun sets `TCL_LIBRARY`) |
| Bundler | linuxdeploy `continuous` |
| AppImage compression | zstd |
| Extra checks | Broken-symlink scan, `ldd` missing-library check, Tcl round-trip |
| Minimum glibc | 2.35 |
| Schedule | 1st of each month, 06:00 UTC |
| Release tag | `opensta-appimage` (rolling) |
| Artifacts | `opensta-<arch>.AppImage` + `.sha256` |
