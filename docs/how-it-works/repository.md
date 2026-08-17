---
title: Repository layout
description: What's in the Clippy Pet repository, why the runtime tarball is small while the repo is not, and where to look for each kind of file.
---

# Repository layout

<div class="cp-bubble">It looks like you're about to clone something. Here's the map.</div>

```text
.
├── pet.json                     Manifest (id, name, spriteVersionNumber: 2)
├── spritesheet.webp             The v2 atlas: 1536×2288, 8×11 cells of 192×208
├── SHA256SUMS                   Checksums of the two runtime files
├── VERSION                      Single source of truth for the version (1.1.0)
├── source/
│   ├── frames/<state>/NN.png    Normalized per-state frames (the remixable bit)
│   └── row-strips/*.png         Selected generated source strips incl. look rows
├── qa/                          Contact sheet, look-direction sheet, GIF previews,
│                                blind/semantic/continuity/chroma JSON reports
├── scripts/
│   ├── install.sh               Bootstrap installer (checkout + curl | sh modes)
│   ├── validate.py              Contract validator (runs in CI)
│   └── build-v1-spritesheet.py  Crops the v1 (9-row) sheet for ChatGPT web upload
├── packaging/
│   ├── bin/clippy-pet           POSIX sh CLI shared by every installer
│   ├── share/                   man page, .desktop launcher, autostart, AppStream, icon
│   ├── dist/make-tarballs.sh    Reproducible runtime tarballs
│   ├── linux/                   nFPM config (deb/rpm/apk/arch), Debian copyright/changelog
│   ├── macos/                   .app/.pkg/.dmg build, postinstall, distribution.xml
│   └── keys/                    Public GPG + apk signing keys
├── docs/                        This site (MkDocs Material); docs/requirements.txt
├── mkdocs.yml · overrides/      Site config and theme overrides
├── .github/workflows/
│   ├── validate.yml             Contract validation + old-name guard
│   ├── packaging-ci.yml         Lint, build, smoke-test packages in containers + macOS
│   ├── release.yml              Tag → build, checksum, sign, attest, GitHub Release
│   └── docs.yml                 Build the site; deploy to gh-pages preserving repo paths
├── CHANGELOG.md · CITATION.cff · CONTRIBUTING.md · CODE_OF_CONDUCT.md
├── GOVERNANCE.md · SECURITY.md · SUPPORT.md · AUTHORS.md · NOTICE.md · LICENSE
└── Makefile                     validate · checksums · lint · dist · v1 · docs · docs-serve
```

## Why the tarball is 1.5 MB and the repo is 19 MB

`source/` and `qa/` are the evidence and the raw material: hundreds of PNG frames, previews, and reports. Users don't need them, so `.gitattributes` marks both `export-ignore` and every installer pulls the **runtime tarball** built by `packaging/dist/make-tarballs.sh` (CLI, payload, man page, desktop bits, licence, notice) instead of GitHub's auto-generated source archive.

## The `gh-pages` branch

This site is published to the `gh-pages` branch, which also hosts things that aren't the site: `install.sh`, `keys/`, and (planned) the `apt/`, `rpm/`, `alpine/`, `conda/`, `flatpak/` repositories. The docs workflow syncs the built site into the branch **while excluding those paths**, so a docs deploy can never delete a package repo. Details in the [packaging runbook](../project/packaging.md#docs-and-pages).

## Branches

GitFlow: `develop` is the default and integration branch; `main` holds releases only; tags `vX.Y.Z` on `main` trigger the release workflow. See [Contributing](../community/contributing.md).
