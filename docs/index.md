---
layout: default
title: Home
nav_order: 1
---

# Open EDA AppImages

Portable, single-file **AppImages** for open-source EDA tools. No
installation. No package manager. No container. Download one file,
`chmod +x`, run.

Built automatically from official upstream sources, so you always get
a clean, reproducible binary.

---

## Why this exists

- EDA tools move fast. `apt install <your-tool>` gives you whatever
  your distro froze 1–2 years ago.

- Building them from source is painful. Multiple dependencies, fiddly
  configure steps, and one small mistake sends you back through the
  whole process again. After you're done, your system is littered with
  build tooling you'll probably never use again. Removing all of that
  cleanly later is another manual chore.

An AppImage solves both problems: one file, no installation, no
residue.

---

## How to trust this

Don't trust the repo. Don't trust the maintainer. **Audit the workflows
yourself and trust what you see.**

Everything is public:

- The [build workflows](https://github.com/MrAbhi19/open-eda-appimage/tree/main/.github/workflows)
  are readable YAML.
- The [build logs](https://github.com/MrAbhi19/open-eda-appimage/actions)
  are public for every release.
- Every release ships with a SHA256 checksum.

There is no human intervention between source and release. Every step —
fetching the upstream source, building, bundling dependencies,
verifying the AppImage, computing the checksum, and publishing the
release — runs on GitHub-hosted runners via GitHub Actions. The
maintainer doesn't touch the binaries. Neither should you have to.

Transparency is the whole point. You can verify every step.

---

## Requirements

Even packaging has its limits:

- **glibc 2.35 or newer** — Ubuntu 22.04+, Debian 12+, Fedora 36+.
  We are actively working on lowering this.
- **FUSE 2** — needed only for direct execution. Most distros ship it;
  if yours doesn't, install `libfuse2`/`fuse2`, or run with
  `--appimage-extract-and-run` and skip FUSE entirely.
- **Architecture** — x86_64 and aarch64 only. More to come.

---

## Available tools

| Tool | Versions | Architectures | Source | Release channel | Details |
|---|---|---|---|---|---|
| **ABC** | Rolling | x86_64, aarch64 | [berkeley-abc/abc](https://github.com/berkeley-abc/abc) | Updated every ~10 days (rolling tag `abc-appimage`) | [ABC page →](abc.html) |
| **Yosys** | 0.68 and newer | x86_64, aarch64 | [YosysHQ/yosys](https://github.com/YosysHQ/yosys) | Tagged per version (`yosys-v<version>`) | [Yosys page →](yosys.html) |
| **OpenSTA** | Rolling | x86_64, aarch64 | [parallaxsw/OpenSTA](https://github.com/parallaxsw/OpenSTA) | Updated monthly (rolling tag `opensta-appimage`) | [OpenSTA page →](opensta.html) |
| **Surelog** | v1.81 and newer | x86_64, aarch64 | [chipsalliance/Surelog](https://github.com/chipsalliance/Surelog) | Tagged per version (`surelog-v<version>`) | [Surelog page →](surelog.html) |
| **Netgen** | 1.5.323 and newer | x86_64, aarch64 | [RTimothyEdwards/netgen](https://github.com/RTimothyEdwards/netgen) | Tagged per version (`netgen-v<version>`) | [Netgen page →](netgen.html) |

Each tool has a dedicated page covering what the tool is, how to download
it, and exactly how it is built and packaged: source, build flags, bundler
versions, and checks.

- [ABC →](abc.html) — logic synthesis and formal verification
- [Yosys →](yosys.html) — RTL synthesis framework
- [OpenSTA →](opensta.html) — gate-level static timing analysis
- [Surelog →](surelog.html) — SystemVerilog 2017 parser, elaborator and UHDM compiler
- [Netgen →](netgen.html) — LVS (layout vs. schematic) netlist comparison

Follow the [releases page](https://github.com/MrAbhi19/open-eda-appimage/releases)
or the [Discussions](https://github.com/MrAbhi19/open-eda-appimage/discussions)
for updates.

---

## Quick start

Pick the tool and version you want, then go to its
[release page](https://github.com/MrAbhi19/open-eda-appimage/releases)
and download the AppImage for your architecture.

**Yosys**

```sh
# Download
wget https://github.com/MrAbhi19/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-x86_64.AppImage

# Make executable and run
chmod +x yosys-0.69-x86_64.AppImage
./yosys-0.69-x86_64.AppImage --version

# Verify the download
sha256sum -c yosys-0.69-x86_64.AppImage.sha256
```

**ABC**

```sh
# Download
wget https://github.com/MrAbhi19/open-eda-appimage/releases/download/abc-appimage/abc-x86_64.AppImage

# Make executable and run
chmod +x abc-x86_64.AppImage
./abc-x86_64.AppImage

# Verify the download
sha256sum -c abc-x86_64.AppImage.sha256
```

**OpenSTA**

```sh
# Download
wget https://github.com/MrAbhi19/open-eda-appimage/releases/download/opensta-appimage/opensta-x86_64.AppImage

# Make executable and run
chmod +x opensta-x86_64.AppImage
./opensta-x86_64.AppImage -version

# Verify the download
sha256sum -c opensta-x86_64.AppImage.sha256
```

**Surelog**

```sh
# Download
wget https://github.com/MrAbhi19/open-eda-appimage/releases/download/surelog-v1.81/surelog-v1.81-x86_64.AppImage

# Make executable and run
chmod +x surelog-v1.81-x86_64.AppImage
./surelog-v1.81-x86_64.AppImage --version

# Verify the download
sha256sum -c surelog-v1.81-x86_64.AppImage.sha256
```

**Netgen**

```sh
# Download
wget https://github.com/MrAbhi19/open-eda-appimage/releases/download/netgen-v1.5.323/netgen-1.5.323-x86_64.AppImage

# Make executable and run (batch mode; omit -batch for the Tk console)
chmod +x netgen-1.5.323-x86_64.AppImage
echo "quit" | ./netgen-1.5.323-x86_64.AppImage -batch

# Verify the download
sha256sum -c netgen-1.5.323-x86_64.AppImage.sha256
```

For ARM64 devices, replace `x86_64` with `aarch64` in the filenames.
See the [ABC](abc.html), [Yosys](yosys.html), [OpenSTA](opensta.html),
[Surelog](surelog.html) and [Netgen](netgen.html) pages for details.

---

## How releases work

Each tool has its own workflow under
[`.github/workflows/`](https://github.com/MrAbhi19/open-eda-appimage/tree/main/.github/workflows).

Each workflow:

1. Fetches the upstream source: the official release tarball for Yosys and
   Netgen, the tagged release (with git submodules) for Surelog, and the
   latest commit for ABC and OpenSTA
2. Builds natively on Ubuntu 22.04 (x86_64) and Ubuntu 22.04 ARM (aarch64)
3. Bundles dependencies with
   [linuxdeploy](https://github.com/linuxdeploy/linuxdeploy) and packs the
   AppImage (zstd-compressed for Yosys, ABC and OpenSTA)
4. Smoke tests the AppImage. Beyond that:
   - ABC and OpenSTA also check for broken symlinks and missing shared
     libraries, and OpenSTA additionally runs a Tcl round-trip to exercise
     its bundled Tcl runtime.
   - Surelog and Netgen audit the ELF binaries inside the AppImage and fail
     the build if any shared library leaks in from the host instead of being
     bundled (only glibc and a short base-system allowlist are permitted).
     Netgen also checks that the bundled Tcl/Tk script libraries are present
     and starts in batch mode to exercise them.
5. Publishes to GitHub Releases with a SHA256 checksum

Yosys additionally has a
[test workflow](https://github.com/MrAbhi19/open-eda-appimage/blob/main/.github/workflows/test-yosys-appimage.yml)
that downloads the published AppImage and synthesizes the picorv32 RISC-V
core with it.

Build logs are public in the
[Actions tab](https://github.com/MrAbhi19/open-eda-appimage/actions).

The exact build flags, dependency lists, and bundling decisions for each
tool are documented on its dedicated page — see
[ABC](abc.html), [Yosys](yosys.html), [OpenSTA](opensta.html),
[Surelog](surelog.html) and [Netgen](netgen.html).

---

## Unofficial

These are **unofficial** repackagings. Each tool retains its upstream
license and is maintained by its own team.

- Bug in the tool itself? Report it upstream.
- Bug in the packaging? [Open an issue here](https://github.com/MrAbhi19/open-eda-appimage/issues).
