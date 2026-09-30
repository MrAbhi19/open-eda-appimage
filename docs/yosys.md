---
layout: default
title: Yosys
nav_order: 3
---

# Yosys

[Yosys](https://github.com/YosysHQ/yosys) is an open-source framework
for Verilog RTL synthesis.

## Available versions

| Version | Status |
|---|---|
| 0.69 | Current stable |
| 0.68 | Previous stable |

## Download

Replace `x86_64` with `aarch64` for ARM64.

```sh
wget https://github.com/MrAbhi19/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-x86_64.AppImage
chmod +x yosys-0.69-x86_64.AppImage
./yosys-0.69-x86_64.AppImage --version
```

## Usage

Synthesize a design:

```sh
./yosys-0.69-x86_64.AppImage -s synth.ys
```

Interactive shell:

```sh
./yosys-0.69-x86_64.AppImage
```

## Verification

Every AppImage is verified on a clean `ubuntu-22.04` runner by
synthesizing the [picorv32](https://github.com/YosysHQ/picorv32)
RISC-V CPU core. See the
[test workflow](https://github.com/MrAbhi19/open-eda-appimage/blob/main/.github/workflows/test-yosys-appimage.yml).
