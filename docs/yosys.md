---
layout: default
title: Yosys
nav_order: 3
---

# Yosys
{: .no_toc }

**Yosys Open SYnthesis Suite** — a framework for RTL synthesis tools.
{: .fs-6 .fw-300 }

<details open markdown="block">
  <summary>Table of contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## About Yosys

Yosys is an open-source framework for RTL (register-transfer level) synthesis.
It has extensive Verilog-2005 support and provides a set of synthesis
algorithms for a range of application domains, from FPGA flows to ASIC
flows. It is also commonly used together with other tools such as ABC (for
logic optimisation and technology mapping) and open-source place-and-route
tools.

- **Upstream project:** [YosysHQ/yosys](https://github.com/YosysHQ/yosys)
- **Upstream releases:** [github.com/YosysHQ/yosys/releases](https://github.com/YosysHQ/yosys/releases)
- **License:** ISC (see [LICENSE-Yosys](https://github.com/opensiliconhub/open-eda-appimage/blob/main/LICENSE-Yosys))

> This is an **unofficial** repackaging. Yosys is developed by YosysHQ and its
> contributors. Bugs in Yosys itself should be reported upstream; packaging
> problems belong in this repository's
> [issue tracker](https://github.com/opensiliconhub/open-eda-appimage/issues).

---

## How to download

Each Yosys version is published as its own tagged release, named
`yosys-v<version>`. Files are named:

```
yosys-<version>-<arch>.AppImage
yosys-<version>-<arch>.AppImage.sha256
```

where `<arch>` is `x86_64` or `aarch64`.

### x86_64

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-x86_64.AppImage
chmod +x yosys-0.69-x86_64.AppImage
./yosys-0.69-x86_64.AppImage --version
```

### aarch64 (ARM64)

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-aarch64.AppImage
chmod +x yosys-0.69-aarch64.AppImage
./yosys-0.69-aarch64.AppImage --version
```

To get another version, replace `0.69` (in both the tag and the filename)
with the version you want. All versions are listed on the
[releases page](https://github.com/opensiliconhub/open-eda-appimage/releases).

### Verify the download

Download the `.sha256` file from the same release into the same directory, then:

```sh
sha256sum -c yosys-0.69-x86_64.AppImage.sha256
```

Expected output:

```
yosys-0.69-x86_64.AppImage: OK
```

The SHA256 is also printed in each release's notes.

### Requirements

- Linux x86_64 or aarch64
- glibc 2.35 or newer (Ubuntu 22.04+, Debian 12+, Fedora 36+, or equivalent)
- FUSE 2 for direct execution (`libfuse2` on Debian/Ubuntu, `fuse2` on
  Fedora). Without FUSE, run with `--appimage-extract-and-run`.

> **Note:** Yosys `0.67` is reserved for verification and experimentation
> with new packaging methods. Please don't install it for regular use.

---

## How it is built

Everything happens in the
[`build-yosys-appimage.yml`](https://github.com/opensiliconhub/open-eda-appimage/blob/main/.github/workflows/build-yosys-appimage.yml)
workflow on GitHub-hosted runners. No step is performed by hand.

### Trigger and inputs

The workflow is started manually (`workflow_dispatch`) with these inputs:

| Input | Purpose | Default |
|---|---|---|
| `version` | Yosys version to build (e.g. `0.69`) | `0.69` |
| `make_latest` | Mark the release as GitHub "Latest" | `true` |
| `create_release` | Publish a GitHub Release (otherwise only a workflow artifact is produced) | `true` |

### Build matrix

Each architecture is built **natively** (no cross-compilation, no emulation):

| Architecture | Runner |
|---|---|
| x86_64 | `ubuntu-22.04` |
| aarch64 | `ubuntu-22.04-arm` |

Ubuntu 22.04 is used deliberately: it ships glibc 2.35, which sets the
minimum glibc for the resulting AppImage. The job timeout is 30 minutes.

### Step by step

**1. Install build dependencies**

```sh
sudo apt-get update
sudo apt-get install -y \
  cmake ninja-build gawk git make python3 lld bison clang flex \
  libffi-dev libfl-dev libreadline-dev pkg-config \
  tcl-dev zlib1g-dev graphviz xdot \
  wget curl file desktop-file-utils \
  python3-pil
```

`python3-pil` is used only to generate the placeholder icon; `file` and
`desktop-file-utils` are used by linuxdeploy.

**2. Download the official source tarball**

The workflow uses the release tarball published by YosysHQ, not a git clone,
so the source is exactly what upstream released:

```sh
wget -q https://github.com/YosysHQ/yosys/releases/download/v<version>/yosys.tar.gz
tar xf yosys.tar.gz
test -f CMakeLists.txt && echo "Source looks good"
```

**3. Configure with CMake + Ninja**

```sh
cmake -B build -G Ninja . \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DYOSYS_WITHOUT_EDITLINE=ON \
  -DYOSYS_WITHOUT_SLANG=ON
```

| Flag | Why |
|---|---|
| `-G Ninja` | Fast parallel build backend |
| `CMAKE_BUILD_TYPE=Release` | Optimised build |
| `CMAKE_INTERPROCEDURAL_OPTIMIZATION=ON` | Enables link-time optimisation |
| `CMAKE_INSTALL_PREFIX=/usr` | Standard prefix, so Yosys finds its share files (`/usr/share/yosys`) relative to the binary inside the AppImage |
| `YOSYS_WITHOUT_EDITLINE=ON` | Drops the editline dependency; the interactive shell uses **readline** instead |
| `YOSYS_WITHOUT_SLANG=ON` | Drops the optional Slang SystemVerilog frontend to keep the bundle small and portable |

**4. Build**

```sh
cmake --build build --config Release --parallel $(nproc)
```

**5. Install into an AppDir**

```sh
cmake --install build --prefix AppDir/usr --strip
```

`--strip` removes debug symbols from the installed binaries. The result is a
standard `AppDir/usr/{bin,share,...}` layout.

**6. Create the desktop entry and icon**

A `yosys.desktop` file is written to `AppDir/usr/share/applications/`:

```ini
[Desktop Entry]
Name=Yosys
Exec=yosys
Icon=yosys
Type=Application
Categories=Development;Electronics;
Terminal=true
Comment=Yosys Open SYnthesis Suite
```

AppImages require an icon, so a plain 256×256 RGBA PNG (solid blue,
`30,100,200`) is generated with Pillow and saved to
`AppDir/usr/share/icons/hicolor/256x256/apps/yosys.png`.

**7. Package with linuxdeploy**

| Tool | Version |
|---|---|
| linuxdeploy | `1-alpha-20251107-1` (pinned release, per-architecture AppImage) |
| AppImage output | linuxdeploy's built-in `appimage` output, bundled with that linuxdeploy release |
| Compression | `zstd` (`OUTPUT_APPIMAGE_COMP=zstd`) |

linuxdeploy is downloaded from
`https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20251107-1/linuxdeploy-<arch>.AppImage`,
where `<arch>` is `x86_64` or `aarch64`. Pinning the release keeps builds
reproducible.

```sh
export OUTPUT_APPIMAGE_COMP=zstd
./linuxdeploy-<arch>.AppImage \
  --appdir AppDir \
  --executable AppDir/usr/bin/yosys \
  --desktop-file AppDir/usr/share/applications/yosys.desktop \
  --icon-file AppDir/usr/share/icons/hicolor/256x256/apps/yosys.png \
  --output appimage
```

linuxdeploy inspects `yosys`, copies every shared library it depends on
(Tcl, readline, libffi, zlib, the C++ runtime libraries, and so on) into
`AppDir/usr/lib`, then produces a single squashfs-based AppImage. The output
is renamed to `yosys-<version>-<arch>.AppImage`.

**8. Smoke test**

```sh
chmod +x yosys-<version>-<arch>.AppImage
./yosys-<version>-<arch>.AppImage --version
```

**9. Checksum**

```sh
sha256sum yosys-<version>-<arch>.AppImage > yosys-<version>-<arch>.AppImage.sha256
```

**10. Publish**

- The AppImage and its `.sha256` are uploaded as a workflow artifact
  (`actions/upload-artifact`).
- If `create_release` is enabled, they are attached to a GitHub Release tagged
  `yosys-v<version>` using `softprops/action-gh-release`. The release notes
  include the SHA256 and quick-start instructions.
- Both architectures upload to the same release tag.

### Testing

A separate workflow,
[`test-yosys-appimage.yml`](https://github.com/opensiliconhub/open-eda-appimage/blob/main/.github/workflows/test-yosys-appimage.yml),
downloads the **published** AppImage on clean `ubuntu-22.04` (x86_64) and
`ubuntu-22.04-arm` (aarch64) runners. It fetches the
[picorv32](https://github.com/YosysHQ/picorv32) RISC-V core and runs:

```
read_verilog picorv32.v
synth -top picorv32
stat
```

This exercises the full `read_verilog` → `synth` → `stat` flow using only the
AppImage. It is run manually and takes the Yosys version as an input.

---

## Build summary

| Item | Value |
|---|---|
| Source | Official `yosys.tar.gz` release tarball |
| Build system | CMake + Ninja |
| Build type | Release, with LTO |
| Disabled features | editline, Slang |
| Runners | `ubuntu-22.04`, `ubuntu-22.04-arm` |
| Bundler | linuxdeploy `1-alpha-20251107-1` |
| AppImage compression | zstd |
| Minimum glibc | 2.35 |
| Release tag | `yosys-v<version>` |
| Artifacts | `yosys-<version>-<arch>.AppImage` + `.sha256` |
