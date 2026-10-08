# open-eda-appimage

> Portable, single-file **AppImages** for open-source EDA tools (**Yosys**, **ABC**, **OpenSTA**, **Surelog**, **Netgen**) — built automatically from official upstream sources.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[![Build Yosys AppImage](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-yosys-appimage.yml/badge.svg)](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-yosys-appimage.yml)
[![Build ABC AppImage](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-abc-appimage.yml/badge.svg)](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-abc-appimage.yml)
[![Build OpenSTA AppImage](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-opensta-appimage.yml/badge.svg)](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-opensta-appimage.yml)
[![Build Surelog AppImage](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-surelog-appimage.yml/badge.svg)](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-surelog-appimage.yml)
[![Build Netgen AppImage](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-netgen-appimage.yml/badge.svg)](https://github.com/opensiliconhub/open-eda-appimage/actions/workflows/build-netgen-appimage.yml)

No installation. No dependencies. No container. Download one file, `chmod +x`, run.

**Tools:** [Yosys](https://github.com/YosysHQ/yosys) (tagged per version), [ABC](https://github.com/berkeley-abc/abc) (rolling, rebuilt every ~10 days), [OpenSTA](https://github.com/parallaxsw/OpenSTA) (rolling, rebuilt monthly), [Surelog](https://github.com/chipsalliance/Surelog) (tagged per version) and [Netgen](https://github.com/RTimothyEdwards/netgen) (tagged per version) — each for Linux x86_64 and aarch64.

**Downloads, requirements, checksums, and full build details** for Yosys, ABC, OpenSTA, Surelog and Netgen live on the documentation site: **<https://opensiliconhub.github.io/open-eda-appimage/>**
Grab the AppImages from the [**Releases page**](../../releases).

---

## Community Partners

Seeking community partners - open a thread on the [Discussions page](../../discussions)

---

## Contributing

PRs, issues, and suggestions are welcome — bug reports, distro-testing feedback, or ideas for new tool workflows. We encourage using the [Discussions page](../../discussions) for feedback and other issues. Pull Requests (PRs) are highly encouraged!

---

## Disclaimers & notes

- This repository is **unofficial** and is **not affiliated with, endorsed by, or supported by** YosysHQ, the Berkeley Logic Synthesis and Verification Group / UC Berkeley, Parallax Software, the Chips Alliance, Tim Edwards / Open Circuit Design, or the upstream Yosys, ABC, OpenSTA, Surelog and Netgen projects.
- The AppImages are repackaged binaries built from unmodified upstream source. Bugs should be reported upstream first — unless they're clearly packaging issues, in which case open an [issue](../../issues) here.
- **Yosys** is built from the official release tarball of each tagged version.
- **ABC** has no versioned releases. It is built from the **latest upstream commit** on a schedule (1st, 11th and 21st of each month) and published under a single rolling tag, `abc-appimage`. Each run overwrites the previous asset, so the binary can change between downloads; the release notes state the exact upstream commit.
- **OpenSTA** also has no versioned releases. It is built from the **latest upstream commit** on the 1st of each month and published under a single rolling tag, `opensta-appimage`. Each run overwrites the previous asset; the release notes state the OpenSTA version and exact upstream commit. It depends on CUDD, which is built from source during the workflow, and it bundles its own Tcl 8.6 runtime.
- **Surelog** is built manually (`workflow_dispatch`) from the upstream git tag you specify (including submodules), using the `release_no_tcmalloc` target to avoid bundling tcmalloc. Each version is published under its own tag, `surelog-<version>` (e.g. `surelog-v1.81`).
- **Netgen** is built manually (`workflow_dispatch`) from the official release tarball of the version you specify, published by Open Circuit Design. Each version is published under its own tag, `netgen-v<version>` (e.g. `netgen-v1.5.323`). Tcl/Tk and the required X11 libraries are bundled, so no host Tcl/Tk is needed.
- Yosys `0.67` is reserved for verification and experimentation of new packaging methods. Please do not install it for regular use.
- Built for **x86_64** and **aarch64** (ARM64) Linux. musl (Alpine) and other configurations are not currently built.
- These builds target **glibc 2.35+** (Ubuntu 22.04+, Debian 12+, Fedora 36+, or equivalent). Older distributions are not supported and cannot be made to work without rebuilding.
- AppImage is a portable format — the file is self-contained, but on some systems you may need FUSE 2 installed (`sudo apt install libfuse2` on Ubuntu 22.04), or you can run with `--appimage-extract-and-run`.
- No warranty of any kind. Use at your own risk.

---

## License

- **This repository's workflows and documentation** are licensed under the [MIT License](LICENSE).
- **The AppImages distributed here** are built from upstream open-source projects and are governed by their respective licenses:
  - **Yosys** — ISC License, Copyright (C) 2012–2026 Claire Xenia Wolf. See [LICENSE-Yosys](LICENSE-Yosys) or the [upstream COPYING file](https://github.com/YosysHQ/yosys/blob/main/COPYING).
  - **ABC** — permissive license, Copyright (c) The Regents of the University of California. See [LICENSE-ABC](LICENSE-ABC) or the [upstream copyright.txt](https://github.com/berkeley-abc/abc/blob/master/copyright.txt).
  - **OpenSTA** — GNU GPL v3 (dual-licensed upstream), Copyright (c) Parallax Software, Inc. See [LICENSE-OpenSTA](LICENSE-OpenSTA) or the [upstream LICENSE](https://github.com/parallaxsw/OpenSTA/blob/master/LICENSE). The corresponding source of each build is the commit linked in its release notes.
  - **CUDD** (bundled with OpenSTA) — BSD 3-clause, Copyright (c) 1995-2004 Regents of the University of Colorado. See [LICENSE-CUDD](LICENSE-CUDD).
  - **Surelog** — Apache License 2.0, Copyright (c) the Surelog authors. See [LICENSE-Surelog](LICENSE-Surelog) or the [upstream LICENSE](https://github.com/chipsalliance/Surelog/blob/master/LICENSE). Surelog also builds in third-party components (such as ANTLR4, UHDM, and others included as git submodules) that carry their own permissive licenses; see the upstream repository for details.
  - **Netgen** — GNU GPL v1 (or, at your option, any later version), Copyright (C) Massimo Sivilotti, Tim Edwards and contributors. See [LICENSE-Netgen](LICENSE-Netgen) or the [upstream Copying file](https://github.com/RTimothyEdwards/netgen/blob/master/Copying). The corresponding source of each build is the official release tarball for the version named in its release notes, available from [opencircuitdesign.com/netgen](http://opencircuitdesign.com/netgen/) and the [upstream repository](https://github.com/RTimothyEdwards/netgen).
- Each AppImage also bundles shared libraries (for example readline, Tcl/Tk, X11 libraries, libffi, and zlib) that are governed by their own licenses.

Upstream projects retain all rights to their code. See each project's license for terms of use, modification, and redistribution.
