---
layout: default
title: Home
nav_order: 1
---

# Open EDA AppImages

Portable, single-file **AppImages** for open-source EDA tools — built
automatically from official upstream releases. No installation. No
dependencies. No container. Download one file, `chmod +x`, run.

---

## Available tools

| Tool | Versions | Architectures |
|---|---|---|
| [ABC](abc.html) | Rolling | x86_64, aarch64 |
| [Yosys](yosys.html) | 0.69, 0.68 | x86_64, aarch64 |

---

## Requirements

- Linux **x86_64** or **aarch64** (ARM64)
- glibc 2.35 or newer — Ubuntu 22.04+, Debian 12+, Fedora 36+
- FUSE 2 *(optional, only for direct execution)*

All other runtime dependencies are bundled inside the AppImage.

---

## Quick start

```sh
wget https://github.com/MrAbhi19/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-x86_64.AppImage
chmod +x yosys-0.69-x86_64.AppImage
./yosys-0.69-x86_64.AppImage --version
```

If FUSE is unavailable:

```sh
./yosys-0.69-x86_64.AppImage --appimage-extract-and-run
```
