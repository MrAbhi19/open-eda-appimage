# open-eda-appimages

> Portable, single-file **AppImages** for open-source EDA tools — built automatically from official upstream releases.

[![Latest release](https://img.shields.io/github/v/release/MrAbhi19/open-eda-appimage?label=latest)](../../releases/latest)
[![Build](https://github.com/MrAbhi19/open-eda-appimage/actions/workflows/build-yosys-appimage.yml/badge.svg)](../../actions/workflows/build-yosys-appimage.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

No installation. No dependencies. No container. Download one file, `chmod +x`, run.

---

## Why this repo exists

Getting up-to-date open-source EDA tools on a normal Linux system is annoying:

- **Distro packages lag behind** — apt/dnf often ship versions that are years old.
- **Building from source** means toolchains, dependencies, and time you don't want to spend.
- **Full EDA bundles** (like OSS CAD Suite) are great, but ~2 GB if you only need one tool.

This repo builds a **standalone AppImage** for each new upstream release, so you can grab one file and go. Every build runs in public GitHub Actions from the official source tarball — no patches, no forks, no hidden steps.

**New Yosys releases are typically built within 24-48 hours** of the upstream tag.

---

## Available tools

| Tool | Version | Download |
|------|---------|----------|
| [Yosys](https://github.com/YosysHQ/yosys) | 0.69 | [release page](../../releases/latest) |

*More tools incoming.*

---

## Download & run (Yosys)

Direct download with `wget`:

```bash
wget https://github.com/MrAbhi19/open-eda-appimages/releases/latest/download/yosys-0.69-x86_64.AppImage
chmod +x yosys-0.69-x86_64.AppImage
./yosys-0.69-x86_64.AppImage --version
```

Or grab it from the [**Releases page**](../../releases/latest) if you prefer a browser.

> **Note:** the `latest/download/` URL requires the exact filename. When a new Yosys version is released, the filename changes (e.g. `yosys-0.70-x86_64.AppImage`). Check the releases page for the current one.

---

## Requirements

- Linux x86_64
- glibc 2.35 or newer — Ubuntu 22.04+, Debian 12+, Fedora 36+, or equivalent

All other runtime dependencies (Clang runtime, Tcl, readline, zlib, etc.) are bundled inside the AppImage.

---

## Verify your download

Every release includes a `.sha256` checksum next to the AppImage. Verify with:

```bash
sha256sum -c yosys-0.69-x86_64.AppImage.sha256
```

Expected output:

```
yosys-0.69-x86_64.AppImage: OK
```

The same SHA256 is printed at the top of each release's notes and shown in the Releases page.

---

## How these builds are made

Every release is built automatically by **GitHub Actions** on Ubuntu 22.04:

1. Downloads the official `yosys.tar.gz` from the YosysHQ [release page](https://github.com/YosysHQ/yosys/releases/latest).
2. Builds with CMake `Release` using Clang + LLVM.
3. Bundles all shared libraries with [`linuxdeploy`](https://github.com/linuxdeploy/linuxdeploy).
4. Runs a smoke test (`yosys --version`) before publishing.
5. Uploads the AppImage and a `.sha256` checksum to the release.

`editline` and `slang` are disabled to keep the bundle small and portable — readline is used for the interactive shell instead.

Full build logs are public: [**Actions tab**](../../actions).

---

## Versions

Each release is tagged `yosys-v<version>` (matching the upstream Yosys version). Re-running the same tag **overwrites** the existing assets, so there's no drift between releases.

---

## Contributing

PRs, issues, and suggestions are welcome — bug reports, distro-testing feedback, or ideas for new tool workflows. Open an [issue](../../issues) or submit a PR.

---

## Disclaimers & notes

- This repository is **unofficial** and is **not affiliated with, endorsed by, or supported by YosysHQ** or the upstream Yosys project.
- The AppImages are repackaged binaries built from unmodified upstream source. Bugs should be reported upstream first — unless they're clearly packaging issues, in which case open an [issue](../../issues) here.
- Only **x86_64** Linux is supported. ARM64, musl (Alpine), and other configurations are not currently built.
- No warranty of any kind. Use at your own risk.
- These builds target **glibc 2.35+**. Older distributions are not supported and cannot be made to work without rebuilding.
- AppImage is a portable format — the file is self-contained, but on some systems you may need FUSE installed (`sudo apt install libfuse2` on Ubuntu 22.04).

---

## License

- **This repository's workflows and documentation** are licensed under the [MIT License](LICENSE).
- **The AppImages distributed here** are built from upstream open-source projects and are governed by their respective licenses:
  - **Yosys** — ISC License, Copyright (C) 2012–2026 Claire Xenia Wolf. See [LICENSE-Yosys](LICENSE-Yosys) or the [upstream COPYING file](https://github.com/YosysHQ/yosys/blob/main/COPYING).

Upstream projects retain all rights to their code. See each project's license for terms of use, modification, and redistribution.
