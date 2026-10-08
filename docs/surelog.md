---
layout: default
title: Surelog
nav_order: 5
---

# Surelog
{: .no_toc }

**Surelog** — a SystemVerilog 2017 pre-processor, parser, elaborator and UHDM compiler.
{: .fs-6 .fw-300 }

<details open markdown="block">
  <summary>Table of contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## About Surelog

Surelog is a SystemVerilog 2017 front end. It pre-processes, parses and
elaborates SystemVerilog designs and compiles them into UHDM (Universal
Hardware Data Model), a standardised data model that other tools can consume.
It is developed under the Chips Alliance and is used as a SystemVerilog parser
in several open-source flows, for example as the front end for Yosys through
the UHDM plugin. Having a standalone `surelog` binary is handy for checking
that a design parses and elaborates cleanly, or for producing UHDM output
without building the whole toolchain yourself.

- **Upstream project:** [chipsalliance/Surelog](https://github.com/chipsalliance/Surelog)
- **Upstream releases:** [github.com/chipsalliance/Surelog/releases](https://github.com/chipsalliance/Surelog/releases)
- **License:** Apache License 2.0 (see
  [LICENSE-Surelog](https://github.com/opensiliconhub/open-eda-appimage/blob/main/LICENSE-Surelog))
  — copyright Alain Dargelas

> This is an **unofficial** repackaging. Surelog is developed by the Chips
> Alliance and its contributors. Bugs in Surelog itself should be reported
> upstream; packaging problems belong in this repository's
> [issue tracker](https://github.com/opensiliconhub/open-eda-appimage/issues).

---

## How to download

Each Surelog version is published as its own tagged release, named
`surelog-<version>`, where `<version>` is the upstream tag including the
leading `v` (for example `v1.81`). Files are named:

```
surelog-<version>-<arch>.AppImage
surelog-<version>-<arch>.AppImage.sha256
```

where `<arch>` is `x86_64` or `aarch64`.

### x86_64

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/surelog-v1.81/surelog-v1.81-x86_64.AppImage
chmod +x surelog-v1.81-x86_64.AppImage
./surelog-v1.81-x86_64.AppImage --version
```

### aarch64 (ARM64)

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/surelog-v1.81/surelog-v1.81-aarch64.AppImage
chmod +x surelog-v1.81-aarch64.AppImage
./surelog-v1.81-aarch64.AppImage --version
```

To get another version, replace `v1.81` (in both the tag and the filename)
with the version you want. All versions that have been published are listed on
the [releases page](https://github.com/opensiliconhub/open-eda-appimage/releases).

### Verify the download

Download the `.sha256` file from the same release into the same directory, then:

```sh
sha256sum -c surelog-v1.81-x86_64.AppImage.sha256
```

Expected output:

```
surelog-v1.81-x86_64.AppImage: OK
```

The SHA256 is also printed in each release's notes.

### Requirements

- Linux x86_64 or aarch64
- glibc 2.35 or newer (Ubuntu 22.04+, Debian 12+, Fedora 36+, or equivalent)
- FUSE 2 for direct execution (`libfuse2` on Debian/Ubuntu, `fuse2` on
  Fedora). Without FUSE, run with `--appimage-extract-and-run`.

---

## How it is built

Everything happens in the
[`build-surelog-appimage.yml`](https://github.com/opensiliconhub/open-eda-appimage/blob/main/.github/workflows/build-surelog-appimage.yml)
workflow on GitHub-hosted runners. No step is performed by hand.

### Trigger and inputs

The workflow is started manually (`workflow_dispatch`) with these inputs:

| Input | Purpose | Default |
|---|---|---|
| `version` | Upstream Surelog tag to build (e.g. `v1.81`) | `v1.81` |
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
minimum glibc for the resulting AppImage. The job timeout is 60 minutes.

### Step by step

**1. Check out the upstream source**

The workflow checks out
[chipsalliance/Surelog](https://github.com/chipsalliance/Surelog) directly at
the requested tag, **with all git submodules** (`submodules: recursive`).
Surelog vendors several third-party components as submodules, so a plain
checkout would not build.

**2. Install build dependencies**

```sh
sudo apt-get update
sudo apt-get install -y \
  build-essential cmake git pkg-config tclsh swig uuid-dev \
  python3 python3-orderedmultidict python3-psutil python3-dev \
  default-jre lcov zlib1g-dev wget curl file desktop-file-utils \
  python3-pil libunwind-dev
```

Notable packages: `default-jre` is needed because Surelog's parser is
generated with ANTLR (a Java tool), `swig` and `python3-dev` support the
optional Python bindings, and `uuid-dev` and `libunwind-dev` are linked into
the build. `python3-pil` is used only to generate the placeholder icon.

**3. Build**

```sh
make release_no_tcmalloc -j"$(nproc)"
```

Surelog's own Makefile wraps CMake. The `release_no_tcmalloc` target gives an
optimised release build **without tcmalloc**, which is a common source of
AppImage portability problems, so it is avoided on purpose.

**4. Install into an AppDir**

```sh
mkdir -p AppDir
make install DESTDIR="$PWD/AppDir" PREFIX=/usr
file AppDir/usr/bin/surelog | grep -q ELF
```

The result is a standard `AppDir/usr/{bin,lib,...}` layout, and the build
fails if `surelog` is not an ELF binary.

**5. Create the desktop entry, icon and custom AppRun**

A `surelog.desktop` file is written to `AppDir/usr/share/applications/`:

```ini
[Desktop Entry]
Name=Surelog
Exec=surelog
Icon=surelog
Type=Application
Categories=Development;Electronics;
Terminal=true
Comment=SystemVerilog 2017 Pre-processor, Parser, Elaborator, UHDM Compiler
```

AppImages require an icon, so a plain 256×256 RGBA PNG (solid light blue,
`50,150,250`) is generated with Pillow and saved to
`AppDir/usr/share/icons/hicolor/256x256/apps/surelog.png`.

A small custom AppRun puts the bundled libraries on the library path and
starts `surelog`:

```sh
#!/bin/bash
export LD_LIBRARY_PATH="$APPDIR/usr/lib:${LD_LIBRARY_PATH:-}"
exec "$APPDIR/usr/bin/surelog" "$@"
```

It is kept **outside** `AppDir` so linuxdeploy doesn't copy it onto itself
when `--custom-apprun` is used.

**6. Package with linuxdeploy**

| Tool | Version |
|---|---|
| linuxdeploy | `1-alpha-20251107-1` (pinned release, per-architecture AppImage) |
| AppImage output | linuxdeploy's built-in `appimage` output, bundled with that linuxdeploy release |

linuxdeploy is downloaded from
`https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20251107-1/linuxdeploy-<arch>.AppImage`,
where `<arch>` is `x86_64` or `aarch64`. Pinning the release keeps builds
reproducible.

```sh
./linuxdeploy-<arch>.AppImage \
  --appdir AppDir \
  --executable AppDir/usr/bin/surelog \
  --desktop-file AppDir/usr/share/applications/surelog.desktop \
  --icon-file AppDir/usr/share/icons/hicolor/256x256/apps/surelog.png \
  --custom-apprun AppRun-custom \
  --output appimage
```

linuxdeploy inspects `surelog`, copies the shared libraries it needs into
`AppDir/usr/lib`, then produces a single squashfs-based AppImage. The output
is renamed to `surelog-<version>-<arch>.AppImage`.

**7. Verify no unwanted host dependencies remain**

The AppImage is extracted (`--appimage-extract`) and **every ELF binary in
`usr/bin`** is audited with `ldd` (Surelog installs several binaries, not just
`surelog`). Each shared-library dependency must either:

- resolve to a copy **bundled inside the AppImage**, or
- be on a short base-system allowlist: the glibc family (`libc`, `libm`,
  `libpthread`, `libdl`, `librt`, `libresolv`, `libnsl`, `libutil`, the dynamic
  loader), plus `libstdc++`, `libgcc_s` and `libz`.

Any missing library, or any dependency that resolves to the host system and is
not on the allowlist, **fails the build**. This prevents shipping an AppImage
that only works on machines with the same development packages installed.

**8. Smoke test**

```sh
chmod +x surelog-<version>-<arch>.AppImage
./surelog-<version>-<arch>.AppImage --version
```

**9. Checksum**

```sh
sha256sum surelog-<version>-<arch>.AppImage > surelog-<version>-<arch>.AppImage.sha256
```

**10. Publish**

- The AppImage and its `.sha256` are uploaded as a workflow artifact
  (`actions/upload-artifact`).
- If `create_release` is enabled, they are attached to a GitHub Release tagged
  `surelog-<version>` using `softprops/action-gh-release`. The release notes
  include the SHA256 and quick-start instructions.
- Both architectures upload to the same release tag.

---

## License

Surelog is released under the **Apache License 2.0**, Copyright 2019 Alain
Dargelas.

- The full license text is in this repository as
  [LICENSE-Surelog](https://github.com/opensiliconhub/open-eda-appimage/blob/main/LICENSE-Surelog).
- The source used for each build is the unmodified upstream tag, including its
  git submodules.
- Surelog builds in third-party components (such as ANTLR4, UHDM and other
  submodules) that carry their own permissive licenses. See the upstream
  repository for details.
- The AppImage also bundles shared libraries from the build system under their
  own licenses.

---

## Build summary

| Item | Value |
|---|---|
| Source | Upstream git tag (`chipsalliance/Surelog`) with recursive submodules |
| Build system | Upstream `make` (CMake underneath), `release_no_tcmalloc` target |
| Compiler | `gcc` / `g++` |
| Runners | `ubuntu-22.04`, `ubuntu-22.04-arm` |
| License | Apache 2.0 |
| Bundler | linuxdeploy `1-alpha-20251107-1` |
| Extra checks | Host-dependency audit of every ELF binary in `usr/bin` |
| Minimum glibc | 2.35 |
| Release tag | `surelog-<version>` (e.g. `surelog-v1.81`) |
| Artifacts | `surelog-<version>-<arch>.AppImage` + `.sha256` |
