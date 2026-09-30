---
layout: default
title: ABC
nav_order: 2
---

# ABC

[ABC](https://github.com/berkeley-abc/abc) is a system for sequential
logic synthesis and formal verification, developed by the Berkeley Logic
Synthesis Group.

## Download

Latest builds: [Releases → abc-appimage](https://github.com/MrAbhi19/open-eda-appimage/releases/tag/abc-appimage)

| File | Architecture |
|---|---|
| `abc-x86_64.AppImage` | x86_64 |
| `abc-aarch64.AppImage` | aarch64 (ARM64) |

## Usage

Interactive shell:

```sh
./abc-x86_64.AppImage
```

Batch mode:

```sh
./abc-x86_64.AppImage -c "read design.blif; strash; balance; write_aiger out.aig; quit"
```

## Features

- Readline interactive shell
- pthreads
- CUDD BDD package
- SAT solvers (kissat, cadical, glucose, etc.)

## Notes

ABC does **not** ship Tcl support — the upstream Makefile has no Tcl
bindings. Any external documentation suggesting otherwise is out of date.
