---
layout: default
title: Symlinks and AppImage Management
nav_order: 7
---

# Symlinks and AppImage Management
{: .no_toc }

**Keep all your AppImages in one place, and expose them on your `PATH`
with symlinks — the clean way to install portable tools.**
{: .fs-6 .fw-300 }

<details open markdown="block">
  <summary>Table of contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## The idea

An AppImage is a single executable file. There is no installer, no
package manager, no `/opt` tree, no registry. It just runs wherever you
put it.

That freedom becomes a mess if you drop every AppImage into `~/Downloads`
or scatter them across random folders. A simple convention fixes it:

1. **Keep every AppImage in one directory** — `~/AppImages`.
2. **Symlink the ones you want to use from `~/.local/bin/`.**

That way:

- Your home directory stays clean — one folder holds every portable tool.
- Your shell finds the tools by name (`yosys`, `abc`, `sta`, …) because
  `~/.local/bin` is usually already on `PATH`.
- Updating a tool means **replacing one file** — the symlink keeps
  working, because it points at the path, not the file contents.

---

## Why `~/.local/bin`?

`~/.local/bin` is the standard per-user equivalent of `/usr/local/bin`.
Most distributions already add it to `PATH` for interactive shells (if it
exists). You can check with:

```sh
echo "$PATH" | tr ':' '\n' | grep -F "$HOME/.local/bin"
```

If nothing comes back, add it to your shell's startup file. For Bash:

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

For Zsh, replace `~/.bashrc` with `~/.zshrc`. For Fish:

```sh
fish_add_path ~/.local/bin
```

After that, anything you symlink into `~/.local/bin` is callable by name
from any new shell.

---

## The workflow

### 1. Create the AppImage directory

```sh
mkdir -p ~/AppImages
```

### 2. Download the AppImage into it

Example with **Yosys 0.69**:

```sh
cd ~/AppImages

wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-x86_64.AppImage
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-x86_64.AppImage.sha256

chmod +x yosys-0.69-x86_64.AppImage
sha256sum -c yosys-0.69-x86_64.AppImage.sha256
```

Everything lives in `~/AppImages` — one file, one checksum, no unpacking.

### 3. Symlink it into `~/.local/bin`

```sh
mkdir -p ~/.local/bin
ln -s ~/AppImages/yosys-0.69-x86_64.AppImage ~/.local/bin/yosys
```

Use an **absolute path** for the symlink target (`~/AppImages/...`), or a
relative one you can reason about. Absolute is the least surprising.

Now run it from anywhere:

```sh
yosys --version
```

The shell resolves `yosys` → `~/.local/bin/yosys` → `~/AppImages/yosys-0.69-x86_64.AppImage`
and executes it.

### 4. Repeat for every tool

```sh
ln -s ~/AppImages/abc-x86_64.AppImage      ~/.local/bin/abc
ln -s ~/AppImages/opensta-x86_64.AppImage  ~/.local/bin/sta
ln -s ~/AppImages/surelog-v1.81-x86_64.AppImage ~/.local/bin/surelog
ln -s ~/AppImages/netgen-1.5.323-x86_64.AppImage ~/.local/bin/netgen
```

You now have a personal `~/AppImages` "toolbox" and a `~/.local/bin`
"launcher" for it.

---

## Full demo: Yosys, end to end

Below is a complete, copy-pasteable walkthrough for Yosys on x86_64.

```sh
# 1. Create the AppImage directory and make sure ~/.local/bin exists
mkdir -p ~/AppImages ~/.local/bin

# 2. Move into it and download the AppImage + checksum
cd ~/AppImages
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-x86_64.AppImage
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/yosys-v0.69/yosys-0.69-x86_64.AppImage.sha256

# 3. Make it executable and verify the checksum
chmod +x yosys-0.69-x86_64.AppImage
sha256sum -c yosys-0.69-x86_64.AppImage.sha256
# → yosys-0.69-x86_64.AppImage: OK

# 4. Symlink it into ~/.local/bin under a short name
ln -s ~/AppImages/yosys-0.69-x86_64.AppImage ~/.local/bin/yosys

# 5. Confirm the symlink and its target
ls -l ~/.local/bin/yosys
# → ... yosys -> /home/you/AppImages/yosys-0.69-x86_64.AppImage

readlink -f ~/.local/bin/yosys
# → /home/you/AppImages/yosys-0.69-x86_64.AppImage

# 6. Run it from anywhere
cd ~
yosys --version
```

Synthesise something with it (the picorv32 RISC-V core, the same design
our test workflow uses):

```sh
cd ~/AppImages
git clone --depth 1 https://github.com/YosysHQ/picorv32.git
cd picorv32

yosys -p "read_verilog picorv32.v; synth -top picorv32; stat"
```

You should see Yosys print a full synthesis log and a cell/resource
summary. All of that ran from the single AppImage in `~/AppImages`,
launched through the symlink in `~/.local/bin`.

---

## Upgrading: replace the file, keep the symlink

This is the part that makes symlinks worth it.

Say Yosys 0.70 is released. You **replace the target file**:

```sh
cd ~/AppImages

# Download the new release (same base name, new version number)
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/yosys-v0.70/yosys-0.70-x86_64.AppImage
wget https://github.com/opensiliconhub/open-eda-appimage/releases/download/yosys-v0.70/yosys-0.70-x86_64.AppImage.sha256
chmod +x yosys-0.70-x86_64.AppImage
sha256sum -c yosys-0.70-x86_64.AppImage.sha256

# Repoint the symlink at the new file (overwrite the old link)
ln -sfn ~/AppImages/yosys-0.70-x86_64.AppImage ~/.local/bin/yosys

# Optional: remove the old AppImage file
rm yosys-0.69-x86_64.AppImage yosys-0.69-x86_64.AppImage.sha256
```

- `ln -sf` — `-s` for symbolic, `-f` to replace an existing link.
- `-n` treats an existing symlink-to-a-directory as a link, not a
  directory, so it never tries to create the link *inside* it. Always
  include it when re-pointing a link.
- The **link name stays the same** (`yosys`), so nothing else on your
  system needs to change. Only the target moved.

The same pattern applies to any tool: replace the file, re-run `ln -sfn`,
optionally delete the old version.

### What happens if you delete the AppImage without re-pointing the link?

The symlink becomes **dangling**: `~/.local/bin/yosys` still exists as a
link, but its target no longer does. Running `yosys` gives something like:

```
bash: /home/you/.local/bin/yosys: No such file or directory
```

Nothing is broken on disk, and nothing was "uninstalled" — a symlink
doesn't own the file it points at. To fix it, either put a new AppImage
at the path the link points to, or re-point the link:

```sh
ln -sfn ~/AppImages/<new-file>.AppImage ~/.local/bin/yosys
```

### What happens if you replace the AppImage in place?

If you download the **same filename** over the old one (for example, a
rolling release where the filename has no version number), the symlink
keeps working with **zero changes** — it points at the path
`~/AppImages/abc-x86_64.AppImage`, and that path still exists:

```sh
cd ~/AppImages
wget -O abc-x86_64.AppImage https://github.com/opensiliconhub/open-eda-appimage/releases/download/abc-appimage/abc-x86_64.AppImage
wget -O abc-x86_64.AppImage.sha256 https://github.com/opensiliconhub/open-eda-appimage/releases/download/abc-appimage/abc-x86_64.AppImage.sha256
chmod +x abc-x86_64.AppImage
sha256sum -c abc-x86_64.AppImage.sha256
```

`~/.local/bin/abc` now runs the new binary. The symlink is untouched.

So:

| Situation | What happens to the symlink |
|---|---|
| New file, different name | Re-point with `ln -sfn` |
| Same filename, overwritten in place | Nothing to do — still works |
| AppImage deleted, link left behind | Dangling link; `yosys` stops working until re-pointed |
| AppImage deleted and link removed | Clean — nothing left over |

---

## Removing a symlink

A symlink is just a directory entry, so you remove it with `rm`. **Do not
add a trailing slash** — `rm ~/.local/bin/yosys/` would try to descend
into the target.

```sh
# Remove just the link
rm ~/.local/bin/yosys
```

The AppImage file itself is untouched and still in `~/AppImages`.

To remove the whole tool — link **and** AppImage:

```sh
rm ~/.local/bin/yosys
rm ~/AppImages/yosys-0.69-x86_64.AppImage
rm ~/AppImages/yosys-0.69-x86_64.AppImage.sha256
```

That is the entire uninstall procedure. No package manager, no leftover
files, no dependencies touched.

### Checking before you remove

A useful habit: confirm the file you're about to delete is actually a
symlink, not a real executable that happens to live in `~/.local/bin`:

```sh
# List what each link points at
ls -l ~/.local/bin | grep '\->'

# Resolve one link's target
readlink -f ~/.local/bin/yosys
```

`rm` does **not** follow symlinks, so `rm ~/.local/bin/yosys` deletes the
link and leaves the target in `~/AppImages` intact. That is exactly what
you want.

### Removing every link at once

If you want to detach every AppImage symlink from `~/.local/bin` but keep
the AppImages themselves:

```sh
# Find links in ~/.local/bin that point into ~/AppImages, and remove only those
find ~/.local/bin -maxdepth 1 -type l \
  -lname "$HOME/AppImages/*" \
  -print -delete
```

`-type l` matches only symlinks, and `-lname "$HOME/AppImages/*"` matches
only links whose target starts with your AppImage directory. `-print
-delete` shows each one as it's removed. Nothing outside `~/AppImages` is
affected.

---

## Optional: a tiny script to keep it tidy

If you end up with several tools, a two-line helper makes upgrades
painless. Save it as `~/AppImages/link.sh`:

```sh
#!/bin/sh
# link.sh <appimage-filename> <short-name>
# Example: ./link.sh yosys-0.70-x86_64.AppImage yosys
set -eu

appdir="$HOME/AppImages"
bindir="$HOME/.local/bin"
src="$appdir/$1"
dst="$bindir/$2"

[ -x "$src" ] || { echo "not executable: $src" >&2; exit 1; }
mkdir -p "$bindir"
ln -sfn "$src" "$dst"
echo "$dst -> $src"
```

Then, for any tool:

```sh
chmod +x ~/AppImages/link.sh
~/AppImages/link.sh yosys-0.70-x86_64.AppImage yosys
~/AppImages/link.sh abc-x86_64.AppImage abc
~/AppImages/link.sh opensta-x86_64.AppImage sta
```

That is the entire "installation" for each tool: one file, one link.

---

## Summary

| Task | Command |
|---|---|
| Create the AppImage directory | `mkdir -p ~/AppImages` |
| Download an AppImage | `wget <url> -P ~/AppImages` |
| Make it executable | `chmod +x ~/AppImages/<file>.AppImage` |
| Verify the download | `sha256sum -c ~/AppImages/<file>.AppImage.sha256` |
| Create a symlink | `ln -s ~/AppImages/<file>.AppImage ~/.local/bin/<name>` |
| Upgrade (new filename) | `ln -sfn ~/AppImages/<new-file>.AppImage ~/.local/bin/<name>` |
| Upgrade (same filename) | Overwrite the file — nothing else to do |
| Remove just the link | `rm ~/.local/bin/<name>` |
| Remove link + AppImage | `rm ~/.local/bin/<name> ~/AppImages/<file>.AppImage*` |
| List link targets | `ls -l ~/.local/bin \| grep '\->'` |
| Resolve one link | `readlink -f ~/.local/bin/<name>` |

One directory for the files, one directory for the names, one `ln` per
tool. That's the whole workflow.
