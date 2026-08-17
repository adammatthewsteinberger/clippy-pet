---
date: 2026-08-17
authors: [adam]
categories: [Releases]
slug: clippy-pet-1-1-one-line-install
description: Clippy Pet 1.1 brings a one-line install on every Unix, native macOS and Linux installers, verifiable releases, a v1 build for ChatGPT web, and this documentation site.
---

# Clippy Pet 1.1: one-line install on every Unix

Clippy Pet started as two files in a repository and a ten-line script that copied them into `~/.codex/pets/`. Version 1.1 keeps the two files exactly as they were and changes everything around them: how you get them, how you check them, and how you find out what they are. Here's what's in the release, and, in keeping with house style, what isn't yet.

## The one-liner

```sh
curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh
```

`install.sh` resolves the latest GitHub Release, downloads a 1.5 MB runtime tarball plus `SHA256SUMS`, verifies the checksum, and runs the bundled `clippy-pet install`. No `sudo`, no writes outside a temp dir and the pet directory, and the whole script is [readable in a minute](../../packages/curl.md). It also works offline from a checkout.

## Native installers

- **macOS**: a `.dmg` containing **Install Clippy Pet.app** (no admin; installs for you) and a `.pkg` (admin; installs the CLI system-wide and seeds the logged-in user's pet). Signing and notarization are wired but wait on Apple credentials, so for now Gatekeeper needs a right-click → Open. [Details](../../packages/macos.md).
- **Linux**: `.deb`, `.rpm`, `.apk`, and Arch `.pkg.tar.zst`, all `noarch`, built from one nFPM config and smoke-tested in Debian, Fedora, Alpine, and Arch containers on every push. Each installs a `clippy-pet` command, a man page, an app-menu launcher, AppStream metadata, and an opt-out login-time `sync`. [Details](../../packages/linux.md).

## The `clippy-pet` command

One POSIX shell script, shared by every installer, tested under dash, bash, BusyBox ash, and macOS `/bin/sh`:

```text
clippy-pet [install] [--codex-home DIR] [--link] [--force] [--if-missing] [--migrate] [--quiet] [--gui]
clippy-pet uninstall | status | sync | path | autostart enable|disable|status | version
```

`status` exits 0/1/2 for current/missing/outdated by comparing bytes, so scripts and the autostart entry can be idempotent.

## Verifiable releases

Every release ships `SHA256SUMS`, a cosign keyless signature bundle on it, and a GitHub artifact attestation per asset. The GPG and apk repository keys are already published under `packaging/keys/` for the self-hosted repos that come next. [Verify downloads](../../packages/verify.md).

## A v1 sheet for ChatGPT on the web

ChatGPT's web pet uploader accepts the older nine-row v1 layout. Since v1 is a strict prefix of v2, `scripts/build-v1-spritesheet.py` crops the top 1872 pixels losslessly, re-checks occupancy, and the result ships as `spritesheet-v1.webp` on each release. All nine animations; no pointer tracking (that's a v2 feature). [Pick it in ChatGPT & Codex](../../get-started/select.md).

## This site

The documentation moved from two Markdown files to a full site: per-OS install tabs, an honest [installers matrix](../../packages/index.md) with live / on-each-release / planned chips, the [nine animations](../../meet/animations.md) as GIFs, the [look-direction QA](../../meet/look-directions.md), the [receipts](../../how-it-works/qa.md), a [make-your-own guide](../../make/index.md), and a [paperclip history](../../meet/history.md) that leads with the disclaimer.

## What's not in 1.1

Homebrew, MacPorts, Nix, AUR, apt/rpm/apk repos, COPR, OBS, Snap, Flatpak, AppImage, conda-forge, vcpkg, conan. Recipes are drafted and the [roadmap](../../project/roadmap.md) says which are one CI run away and which wait on an account or an upstream review. When a row goes live, the install page will say so; until then it won't.

Also renamed: the project was briefly *Clipster*. `clippy-pet install --migrate` cleans up the old directory.

Install it, break it, [tell us](https://github.com/adammatthewsteinberger/clippy-pet/issues/new/choose).
