---
layout: default
title: Netgen
nav_order: 6
---

# Netgen
{: .no_toc }

**Netgen** — a LVS (layout vs. schematic) netlist comparison tool.
{: .fs-6 .fw-300 }

<details open markdown="block">
  <summary>Table of contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## About Netgen

Netgen is a netlist comparison tool, most commonly used for LVS (layout vs.
schematic) checking. It compares two circuit netlists (for example, one
extracted from a layout and one derived from a schematic) and reports whether
they are equivalent, pointing out mismatched nets, devices and pins when they
are not. It is scripted through a Tcl/Tk interpreter and is a standard part of
open-source analog and digital design flows built around Magic, Xschem and the
open PDKs. Having a standalone `netgen` binary is handy for running LVS on its
own without installing Tcl/Tk, X11 development packages or a full tool suite.

- **Upstream project:** [RTimothyEdwards/netgen](https://github.com/RTimothyEdwards/netgen)
- **Upstream downloads:** [opencircuitdesign.com/netgen](http://opencircuitdesign.com/netgen/)
- **License:** GNU GPL v1 (see
  [LICENSE-Netgen](https://github.com/opensiliconhub/open-eda-appimage/blob/main/LICENSE-Netgen))

> This is an **unofficial** repackaging. Netgen is developed by Tim Edwards.
> Bugs in Netgen itself should be reported upstream; packaging problems belong
> in this repository's
> [issue tracker](https://github.com/opensiliconhub/open-eda-appimage/issues).

---

## How to download

Each Netgen version is published as its own tagged release, named
`netgen-v<version>`. Files are named:

```
netgen-<version>-<arch>.AppImage
netgen-<version>-<arch>.AppImage.sha256
```

where `<arch>` is `x86_64` or `aarch64`.

### x86_64

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/netgen-v1.5.323/netgen-1.5.323-x86_64.AppImage
chmod +x netgen-1.5.323-x86_64.AppImage
echo "quit" | ./netgen-1.5.323-x86_64.AppImage -batch
```

### aarch64 (ARM64)

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/netgen-v1.5.323/netgen-1.5.323-aarch64.AppImage
chmod +x netgen-1.5.323-aarch64.AppImage
echo "quit" | ./netgen-1.5.323-aarch64.AppImage -batch
```

To get another version, replace `1.5.323` (in both the tag and the filename)
with the version you want. All versions that have been published are listed on
the [releases page](https://github.com/opensiliconhub/open-eda-appimage/releases).

### Running Netgen

Netgen has two modes, and the AppImage's launcher script picks between them
based on the arguments:

- **Interactive:** run `./netgen-1.5.323-x86_64.AppImage` with no arguments (or
  without `-batch` / `-noconsole`) to open the Tk console (`tkcon`). This
  needs a working X11 display.
- **Batch:** pass `-batch` (or `-noconsole`) to run without the GUI console,
  for example in scripts and CI:

```sh
./netgen-1.5.323-x86_64.AppImage -batch lvs "layout.spice top" "schematic.spice top" setup.tcl
```

### Verify the download

Download the `.sha256` file from the same release into the same directory, then:

```sh
sha256sum -c netgen-1.5.323-x86_64.AppImage.sha256
```

Expected output:

```
netgen-1.5.323-x86_64.AppImage: OK
```

The SHA256 is also printed in each release's notes.

### Requirements

- Linux x86_64 or aarch64
- glibc 2.35 or newer (Ubuntu 22.04+, Debian 12+, Fedora 36+, or equivalent)
- **Tcl/Tk 8.x, zlib and the required X11 libraries are bundled** inside the
  AppImage; you don't need Tcl/Tk installed
- An X11 display for the interactive console (not needed for `-batch`)
- FUSE 2 for direct execution (`libfuse2` on Debian/Ubuntu, `fuse2` on
  Fedora). Without FUSE, run with `--appimage-extract-and-run`.

---

## How it is built

Everything happens in the
[`build-netgen-appimage.yml`](https://github.com/opensiliconhub/open-eda-appimage/blob/main/.github/workflows/build-netgen-appimage.yml)
workflow on GitHub-hosted runners. No step is performed by hand.

### Trigger and inputs

The workflow is started manually (`workflow_dispatch`) with these inputs:

| Input | Purpose | Default |
|---|---|---|
| `version` | Netgen version to build (e.g. `1.5.323`) | `1.5.323` |
| `make_latest` | Mark the release as GitHub "Latest" | `true` |
| `create_release` | Publish a GitHub Release (otherwise only a workflow artifact is produced) | `true` |

### Build matrix

Each architecture is built **natively** (no cross-compilation, no emulation):

| Architecture | Runner |
|---|---|
| x86_64 | `ubuntu-22.04` |
| aarch64 | `ubuntu-22.04-arm` |

`fail-fast` is disabled, so one architecture failing doesn't cancel the other.
Ubuntu 22.04 is used deliberately: it ships glibc 2.35, which sets the
minimum glibc for the resulting AppImage. The job timeout is 30 minutes.

### Step by step

**1. Install build dependencies**

```sh
sudo apt-get update
sudo apt-get install -y \
  build-essential autoconf automake m4 libtool \
  tcl-dev tk-dev libx11-dev libxext-dev libxpm-dev libxt-dev \
  wget curl file desktop-file-utils python3-pil
```

Notable packages: `tcl-dev` and `tk-dev` provide the Tcl/Tk interpreter that
Netgen embeds, and the `libx*-dev` packages are the X11 libraries Tk needs for
its GUI. `python3-pil` is used only to generate the placeholder icon; `file`
and `desktop-file-utils` are used by linuxdeploy.

**2. Download the official source tarball**

The workflow uses the release tarball published by the upstream author, not a
git clone, so the source is exactly what upstream released:

```sh
wget -q http://opencircuitdesign.com/netgen/archive/netgen-<version>.tgz
tar xzf netgen-<version>.tgz
test -f netgen-<version>/configure
```

**3. Configure, build and install**

```sh
cd netgen-<version>
./configure --prefix=/usr
make -j"$(nproc)"
make install DESTDIR="$PWD/../AppDir"
```

Netgen uses a standard autotools `configure` script with no custom flags other
than the prefix. Installing with `DESTDIR` places everything under `AppDir`.
The workflow then checks that `AppDir/usr/bin/netgen` is executable and that
`AppDir/usr/lib/netgen/tcl/netgenexec` is an ELF binary. `netgenexec` is the
real executable: `netgen` itself is only a wrapper script.

**4. Bundle the Tcl/Tk runtime**

`netgenexec` links `libtcl` and `libtk` dynamically, so linuxdeploy's `ldd`
scan finds the `.so` files. But the Tcl/Tk **script** libraries (`init.tcl`,
`tk.tcl` and friends) are located by path lookup, not by the dynamic linker,
so `ldd` never sees them. Without bundling them explicitly, the AppImage would
silently fall back to `/usr/share/tcltk` on the host and only work on machines
that already have Tcl/Tk installed. The workflow therefore bundles them by
hand:

1. Locate `libtcl`, `libtk` and `libz` on the runner and copy them into
   `AppDir/usr/lib`.
2. Locate the Tcl and Tk script directories (`tcl8.x`, `tk8.x`) and copy them
   into `AppDir/usr/share/netgen-tcltk/`.
3. Check that `init.tcl` and `tk.tcl` exist in the copies.

**5. Patch the `netgen` wrapper**

The wrapper script that `make install` creates assumes a fixed install
location. The workflow replaces it with one that works from inside an
AppImage and supports batch mode:

```sh
#!/bin/sh
export NETGENDIR="$APPDIR/usr/lib/netgen"
export LD_LIBRARY_PATH="$APPDIR/usr/lib:${LD_LIBRARY_PATH:-}"

for d in "$APPDIR"/usr/share/netgen-tcltk/tcl[0-9].[0-9]; do
    [ -d "$d" ] && export TCL_LIBRARY="$d"
done
for d in "$APPDIR"/usr/share/netgen-tcltk/tk[0-9].[0-9]; do
    [ -d "$d" ] && export TK_LIBRARY="$d"
done

for arg in "$@"; do
    case "$arg" in
        -batch|-noconsole)
            exec "$NETGENDIR/tcl/netgenexec" "$@"
            ;;
    esac
done

exec "$NETGENDIR/tcl/netgenexec" "$NETGENDIR/tcl/tkcon.tcl" "$@"
```

`NETGENDIR` points Netgen at its own files inside the AppImage, and
`TCL_LIBRARY` / `TK_LIBRARY` point the interpreters at the bundled script
libraries from the previous step. If `-batch` or `-noconsole` is among the
arguments, `netgenexec` is run directly; otherwise it is started with
`tkcon.tcl`, which opens the interactive Tk console.

**6. Create the desktop entry, icon and custom AppRun**

A `netgen.desktop` file is written to `AppDir/usr/share/applications/`:

```ini
[Desktop Entry]
Name=Netgen
Exec=netgen
Icon=netgen
Type=Application
Categories=Development;Electronics;
Terminal=true
Comment=Netgen LVS Tool
```

AppImages require an icon, so a plain 256×256 RGBA PNG (solid blue,
`30,100,200`) is generated with Pillow and saved to
`AppDir/usr/share/icons/hicolor/256x256/apps/netgen.png`.

A minimal custom AppRun hands over to the wrapper from step 5:

```sh
#!/bin/bash
exec "$APPDIR/usr/bin/netgen" "$@"
```

It is kept **outside** `AppDir` so linuxdeploy doesn't copy it onto itself when
`--custom-apprun` is used. The AppImage runtime sets `$APPDIR` before running it.

**7. Package with linuxdeploy**

| Tool | Version |
|---|---|
| linuxdeploy | `1-alpha-20251107-1` (pinned release, per-architecture AppImage) |
| AppImage output | linuxdeploy's built-in `appimage` output, bundled with that linuxdeploy release |
| Extra libraries | `libX11`, `libXext`, `libXpm`, `libXt` (passed with `--library`) |

linuxdeploy is downloaded from
`https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20251107-1/linuxdeploy-<arch>.AppImage`,
where `<arch>` is `x86_64` or `aarch64`. Pinning the release keeps builds
reproducible.

```sh
./linuxdeploy-<arch>.AppImage \
  --appdir AppDir \
  --executable AppDir/usr/lib/netgen/tcl/netgenexec \
  --desktop-file AppDir/usr/share/applications/netgen.desktop \
  --icon-file AppDir/usr/share/icons/hicolor/256x256/apps/netgen.png \
  --custom-apprun AppRun-custom \
  --library <libX11> --library <libXext> --library <libXpm> --library <libXt> \
  --output appimage
```

A few details worth knowing:

- `--executable` points at `netgenexec`, the real ELF binary, not the wrapper
  script, so linuxdeploy can resolve its dependencies.
- The X11 libraries are located on the runner and passed explicitly with
  `--library`, because Tk loads some of them in ways a plain `ldd` scan can
  miss.
- Tcl, Tk and zlib were already copied in step 4.

linuxdeploy copies the shared libraries into `AppDir/usr/lib`, then produces a
single squashfs-based AppImage. The output is renamed to
`netgen-<version>-<arch>.AppImage`.

**8. Verify no unwanted host dependencies remain**

The AppImage is extracted (`--appimage-extract`) and both **`netgenexec`** and
**`tclnetgen.so`** are audited with `ldd`, with the bundled `usr/lib` on the
library path. Each shared-library dependency must either:

- resolve to a copy **bundled inside the AppImage**, or
- be on a short base-system allowlist: the glibc family (`libc`, `libm`,
  `libpthread`, `libdl`, `librt`, `libresolv`, `libnsl`, `libutil`, the dynamic
  loader).

Any missing library, or any dependency that resolves to the host system and is
not on the allowlist, **fails the build**. The check also confirms that
`init.tcl` and `tk.tcl` are present in the bundled script libraries. This
prevents shipping an AppImage that only works on machines with Tcl/Tk or X11
development packages installed.

**9. Smoke test**

```sh
chmod +x netgen-<version>-<arch>.AppImage
echo "quit" | ./netgen-<version>-<arch>.AppImage -batch
```

The test starts Netgen in batch mode and feeds it `quit`. This exercises the
wrapper script, the bundled Tcl runtime and `netgenexec` end to end.

**10. Checksum**

```sh
sha256sum netgen-<version>-<arch>.AppImage > netgen-<version>-<arch>.AppImage.sha256
```

**11. Publish**

- The AppImage and its `.sha256` are uploaded as a workflow artifact
  (`actions/upload-artifact`).
- If `create_release` is enabled, they are attached to a GitHub Release tagged
  `netgen-v<version>` using `softprops/action-gh-release`. The release notes
  include the SHA256 and quick-start instructions.
- Both architectures upload to the same release tag.

---

## License

Netgen is released under the **GNU General Public License, version 1**
(February 1989).

- The full license text is in this repository as
  [LICENSE-Netgen](https://github.com/opensiliconhub/open-eda-appimage/blob/main/LICENSE-Netgen).
- The source used for each build is the unmodified upstream release tarball for
  that version, so the corresponding source for any published binary can be
  obtained from the upstream download link above.
- The AppImage also bundles Tcl, Tk, zlib, the X11 libraries and other shared
  libraries from the build system under their own licenses.
- If you modify Netgen and redistribute it, the GPL applies to your changes too.

---

## Build summary

| Item | Value |
|---|---|
| Source | Official `netgen-<version>.tgz` tarball from opencircuitdesign.com |
| Build system | Autotools (`./configure --prefix=/usr`, `make`) |
| Compiler | `gcc` / `g++` |
| Runners | `ubuntu-22.04`, `ubuntu-22.04-arm` |
| License | GPL v1 |
| Tcl/Tk | Bundled (libraries + script directories, wrapper sets `TCL_LIBRARY` and `TK_LIBRARY`) |
| X11 libraries | `libX11`, `libXext`, `libXpm`, `libXt`, bundled |
| Bundler | linuxdeploy `1-alpha-20251107-1` |
| Extra checks | Host-dependency audit of `netgenexec` and `tclnetgen.so`, Tcl/Tk script-library check |
| Minimum glibc | 2.35 |
| Release tag | `netgen-v<version>` |
| Artifacts | `netgen-<version>-<arch>.AppImage` + `.sha256` |
