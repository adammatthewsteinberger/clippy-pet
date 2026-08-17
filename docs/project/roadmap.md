---
title: Roadmap
description: What's shipped in Clippy Pet, what's building, and what's waiting on accounts and reviews, kept honest.
---

# Roadmap

<div class="cp-bubble">It looks like you're wondering when your package manager gets a paperclip. Here's the real board.</div>

This is the maintainer's working list, in public. Items move only when the thing actually exists.

## Done

- [x] v2 pet: nine animations, sixteen look directions, validator, QA reports
- [x] Rename to Clippy Pet / `clippy-pet` with legacy-directory migration
- [x] POSIX `clippy-pet` CLI (install / uninstall / status / sync / path / autostart), man page
- [x] One-line `install.sh` (checkout + remote mode, checksum-verified)
- [x] Reproducible runtime tarballs (`.tar.gz` `.tgz` `.tar.bz2` `.tar.xz` `.zip`)
- [x] `.deb` `.rpm` `.apk` `.pkg.tar.zst` via nFPM, container smoke tests, lintian/rpmlint clean
- [x] macOS `Install Clippy Pet.app`, `.pkg` (console-user seeding), `.dmg`
- [x] Release workflow: guard → build → checksums → cosign → attestations → GitHub Release
- [x] GPG + apk signing keys generated and published; AUR key generated
- [x] Homebrew tap repository created; GitHub Pages enabled
- [x] Documentation site (this), README engagement pass, social preview
- [x] v1 (9-row) sheet build for ChatGPT web upload

## Next (CI can do it once the first release exists)

- [ ] Tag **v1.1.0** (first packaged release); one-liner goes live end-to-end
- [ ] Homebrew formula published to the tap
- [ ] AppImage (x86_64, aarch64), Flatpak bundle, Snap
- [ ] Self-hosted apt / rpm-md / alpine repos on Pages (keys already published)
- [ ] `flake.nix` + Home Manager module
- [ ] AUR `clippy-pet`, PKGBUILD-built `.pkg.tar.xz`
- [ ] Apple-signed, notarized macOS builds

## Waiting on a human (accounts, reviews, upstream queues)

- [ ] Apple Developer ID enrolment (unlocks notarization)
- [ ] AUR account · Launchpad PPA · COPR · OBS · Snap Store name + `personal-files` request
- [ ] MacPorts, nixpkgs, aports, GURU, conda-forge, Flathub submissions
- [ ] Debian ITP, Fedora review, openSUSE Factory, homebrew-core (notability threshold)
- [ ] vcpkg / conan recipes (data-only; upstream may decline; in-repo registry regardless)

## Ideas, no promises

- A 32 px "tiny" variant for cramped terminals
- More expressive `waiting`; better shallow-diagonal look cues
- Additional variants (palette / costume) under `variants/`
- Windows: `install.ps1`, Scoop, winget (out of scope for the "every Unix" release)

Want to move an item? [Discussions](https://github.com/adammatthewsteinberger/clippy-pet/discussions) for questions, [Issues](https://github.com/adammatthewsteinberger/clippy-pet/issues) for concrete work, and the [packaging runbook](packaging.md) for how each row gets built.
