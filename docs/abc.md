---
layout: default
title: ABC
nav_order: 2
---

# ABC
{: .no_toc }

**ABC: System for Sequential Logic Synthesis and Formal Verification.**
{: .fs-6 .fw-300 }

<details open markdown="block">
  <summary>Table of contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## About ABC

ABC is a program from the Berkeley Logic Synthesis and Verification Group at
UC Berkeley. It combines logic synthesis (optimisation and technology mapping
of combinational and sequential circuits) with formal verification
(equivalence checking, model checking) in one interactive, scriptable
command-line tool. ABC is used as a back end by many EDA flows, most notably
Yosys, which calls it for logic optimisation and mapping to LUTs or standard
cells. Having a standalone `abc` binary is handy for running it directly on
BLIF/AIGER files or debugging a flow.

- **Upstream project:** [berkeley-abc/abc](https://github.com/berkeley-abc/abc)
- **License:** permissive UC Berkeley license (see the upstream repository for the
  exact terms)

> This is an **unofficial** repackaging. ABC is developed by the Berkeley
> Logic Synthesis Group. Bugs in ABC itself should be reported upstream;
> packaging problems belong in this repository's
> [issue tracker](https://github.com/opensiliconhub/open-eda-appimage/issues).

---

## How to download

ABC follows a **rolling** release model. There is one release tag,
`abc-appimage`, and every build overwrites the previous assets. Files are named:

```
abc-<arch>.AppImage
abc-<arch>.AppImage.sha256
```

where `<arch>` is `x86_64` or `aarch64`. There is no version number in the
filename. The release notes state the upstream commit the binary was built
from.

### x86_64

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/abc-appimage/abc-x86_64.AppImage
chmod +x abc-x86_64.AppImage
echo "quit" | ./abc-x86_64.AppImage
```

### aarch64 (ARM64)

```sh
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/abc-appimage/abc-aarch64.AppImage
chmod +x abc-aarch64.AppImage
echo "quit" | ./abc-aarch64.AppImage
```

Run `./abc-x86_64.AppImage` with no input to start the interactive ABC shell.

### Verify the download

Download the `.sha256` file from the same release into the same directory, then:

```sh
sha256sum -c abc-x86_64.AppImage.sha256
```

Because the release is rolling, always download the AppImage and its checksum
at the same time.

### Requirements

- Linux x86_64 or aarch64
- glibc 2.35 or newer (Ubuntu 22.04+, Debian 12+, Fedora 36+, or equivalent)
- FUSE 2 for direct execution (`libfuse2` on Debian/Ubuntu, `fuse2` on
  Fedora). Without FUSE, run with `--appimage-extract-and-run`.

---

## How it is built

Everything happens in the
[`build-abc-appimage.yml`](https://github.com/opensiliconhub/open-eda-appimage/blob/main/.github/workflows/build-abc-appimage.yml)
workflow on GitHub-hosted runners. No step is performed by hand.

### Triggers

| Trigger | Details |
|---|---|
| Schedule | Cron `0 6 1,11,21 * *`: 06:00 UTC on the 1st, 11th and 21st of each month (roughly every 10 days) |
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
minimum glibc for the resulting AppImage. The job timeout is 45 minutes.

### Step by step

**1. Install build dependencies**

```sh
sudo apt-get update
sudo apt-get install -y \
  git make gcc g++ \
  libreadline-dev zlib1g-dev \
  wget curl file desktop-file-utils \
  python3-pil libfuse2
```

`python3-pil` is used only to generate the placeholder icon. `libfuse2` lets
the runner execute AppImages (linuxdeploy and the final test).

**2. Clone the upstream source**

```sh
git clone --depth 1 https://github.com/berkeley-abc/abc.git abc-src
```

The shallow clone takes the latest commit. The full hash is recorded and
written into the release notes, so every binary can be traced back to an
exact upstream commit.

**3. Build**

```sh
cd abc-src
make -j"$(nproc)"
test -f abc
file abc
ldd abc
```

ABC uses its own Makefile, so there is no CMake step and no custom flags:
the upstream defaults are used, which build with readline and pthreads
support (hence `libreadline-dev` and `zlib1g-dev`). The resulting `abc`
executable is a single binary; `ldd` output is logged for reference.

**4. Install into an AppDir**

```sh
mkdir -p AppDir/usr/bin
cp abc-src/abc AppDir/usr/bin/
chmod +x AppDir/usr/bin/abc
```

**5. Create the desktop entry and icon**

An `abc.desktop` file is written to `AppDir/usr/share/applications/`:

```ini
[Desktop Entry]
Name=ABC
Exec=abc
Icon=abc
Type=Application
Categories=Development;Electronics;
Terminal=true
Comment=ABC Logic Synthesis and Formal Verification
```

AppImages require an icon, so a plain 256×256 RGBA PNG (solid blue,
`30,80,180`) is generated with Pillow and saved to
`AppDir/usr/share/icons/hicolor/256x256/apps/abc.png`.

**6. Package with linuxdeploy**

| Tool | Version |
|---|---|
| linuxdeploy | `continuous` (latest rolling build, per-architecture AppImage) |
| AppImage output | linuxdeploy's built-in `appimage` output, bundled with that linuxdeploy build |
| Compression | `zstd` (`OUTPUT_APPIMAGE_COMP=zstd`) |

linuxdeploy is downloaded from
`https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-<arch>.AppImage`,
where `<arch>` is `x86_64` or `aarch64`.

```sh
export OUTPUT_APPIMAGE_COMP=zstd
./linuxdeploy-<arch>.AppImage \
  --appdir AppDir \
  --executable AppDir/usr/bin/abc \
  --desktop-file AppDir/usr/share/applications/abc.desktop \
  --icon-file AppDir/usr/share/icons/hicolor/256x256/apps/abc.png \
  --output appimage
```

linuxdeploy inspects `abc`, copies its shared libraries (readline, terminal
libraries, and so on) into `AppDir/usr/lib`, then produces a single
squashfs-based AppImage. The output is renamed to `abc-<arch>.AppImage`, and
the workflow fails if no AppImage was produced.

**7. Verify the AppImage contents**

The AppImage is extracted (`--appimage-extract`) and checked:

- **No broken symlinks** in `usr/lib` (`find ... -xtype l`). Any broken link fails the build.
- **No missing shared libraries**: `ldd` on the bundled binary must not report `not found`.

**8. Smoke test**

```sh
chmod +x abc-<arch>.AppImage
echo "quit" | ./abc-<arch>.AppImage 2>&1 | tee smoke.log
grep -qi "UC Berkeley" smoke.log
grep -qi "ABC" smoke.log
```

The test starts ABC, feeds it `quit`, and checks that the startup banner
appears.

**9. Checksum**

```sh
sha256sum abc-<arch>.AppImage > abc-<arch>.AppImage.sha256
```

**10. Publish**

- The AppImage and its `.sha256` are uploaded as a workflow artifact, kept for
  14 days.
- They are attached to the rolling GitHub Release tagged `abc-appimage` with
  `softprops/action-gh-release`, with `overwrite_files` enabled so each run
  replaces the previous assets.
- The release is **not** marked as "Latest", so it doesn't displace the
  tool-version releases (such as Yosys) on the repository's front page.

---

## Build summary

| Item | Value |
|---|---|
| Source | Latest commit of `berkeley-abc/abc` (shallow clone) |
| Build system | Upstream `make` (readline + pthreads) |
| Compiler | `gcc` / `g++` |
| Runners | `ubuntu-22.04`, `ubuntu-22.04-arm` |
| Bundler | linuxdeploy `continuous` |
| AppImage compression | zstd |
| Extra checks | Broken-symlink scan, `ldd` missing-library check |
| Minimum glibc | 2.35 |
| Schedule | 1st, 11th, 21st of each month, 06:00 UTC |
| Release tag | `abc-appimage` (rolling) |
| Artifacts | `abc-<arch>.AppImage` + `.sha256` |
