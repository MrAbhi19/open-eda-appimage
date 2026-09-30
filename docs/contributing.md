---
layout: default
title: Contributing
nav_order: 4
---

# Contributing

PRs, issues, and suggestions are welcome — bug reports, distro-testing
feedback, or ideas for new tool workflows.

Use the [Discussions page](https://github.com/MrAbhi19/open-eda-appimage/discussions)
for feedback. Pull Requests are highly encouraged.

## Adding a new tool

1. Create `.github/workflows/build-<tool>-appimage.yml` modeled on an
   existing workflow.
2. Adapt the build steps to the tool's native build system.
3. Add a `.desktop` file and a 256×256 PNG icon.
4. Add a `docs/<tool>.md` page and link it from the README and `index.md`.
5. Open a PR.

## Reporting issues

Include:

- Tool name and version
- Your distro and `uname -m`
- The exact command and error output
