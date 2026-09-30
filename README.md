# open-eda-appimage

> Portable, single-file **AppImages** for open-source EDA tools (**Yosys**, **ABC**) — built automatically from official upstream sources.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

No installation. No dependencies. No container. Download one file, `chmod +x`, run.

**Tools:** [Yosys](https://github.com/YosysHQ/yosys) (tagged per version) and [ABC](https://github.com/berkeley-abc/abc) (rolling, rebuilt every ~10 days) — each for Linux x86_64 and aarch64.

**Downloads, requirements, checksums, and full build details** for every tool live on the documentation site: **<https://mrabhi19.github.io/open-eda-appimage/>**
Grab the AppImages from the [**Releases page**](../../releases).

---

## Contributing

PRs, issues, and suggestions are welcome — bug reports, distro-testing feedback, or ideas for new tool workflows. We encourage using the [Discussions page](../../discussions) for feedback and other issues. Pull Requests (PRs) are highly encouraged!

---

## Disclaimers & notes

- This repository is **unofficial** and is **not affiliated with, endorsed by, or supported by** YosysHQ, the Berkeley Logic Synthesis and Verification Group / UC Berkeley, or the upstream Yosys and ABC projects.
- The AppImages are repackaged binaries built from unmodified upstream source. Bugs should be reported upstream first — unless they're clearly packaging issues, in which case open an [issue](../../issues) here.
- **Yosys** is built from the official release tarball of each tagged version.
- **ABC** has no versioned releases. It is built from the **latest upstream commit** on a schedule (1st, 11th and 21st of each month) and published under a single rolling tag, `abc-appimage`. Each run overwrites the previous asset, so the binary can change between downloads; the release notes state the exact upstream commit.
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
- Each AppImage also bundles shared libraries (for example readline, Tcl, libffi, and zlib) that are governed by their own licenses.

Upstream projects retain all rights to their code. See each project's license for terms of use, modification, and redistribution.
