---
title: Installers & packages
description: "Every way to install Clippy Pet, with honest status for each: live now, attached to each release, or still planned."
---

# Installers & packages

<div class="cp-bubble">It looks like you want to know what's real. Here's the whole matrix, with nothing rounded up.</div>

Clippy Pet ships as **one payload wrapped many ways**: the same two files, the same POSIX `clippy-pet` command, packaged for whatever installs things on your system. Every row below is one of three things:

- <span class="cp-chip cp-chip--live">live</span> works today from this site or the repository.
- <span class="cp-chip cp-chip--release">on each release</span> built by CI and attached to every [GitHub Release](https://github.com/adammatthewsteinberger/clippy-pet/releases) from v1.1.0 on.
- <span class="cp-chip cp-chip--planned">planned</span> designed and often scaffolded, but **not published yet**. We won't list a command that doesn't work.

| How | Command / file | Status |
|---|---|---|
| One-line install | `curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh` piped to `sh` | <span class="cp-chip cp-chip--live">live</span> |
| From a checkout | `./scripts/install.sh` | <span class="cp-chip cp-chip--live">live</span> |
| Runtime tarballs | `clippy-pet-<v>.tar.gz` / `.tgz` / `.tar.bz2` / `.tar.xz` / `.zip` | <span class="cp-chip cp-chip--release">on each release</span> |
| macOS disk image | `Clippy-Pet-<v>.dmg` (contains the `.app` and `.pkg`) | <span class="cp-chip cp-chip--release">on each release</span> |
| macOS installer package | `Clippy-Pet-<v>.pkg` | <span class="cp-chip cp-chip--release">on each release</span> |
| macOS app | `Install Clippy Pet.app` | <span class="cp-chip cp-chip--release">on each release</span> |
| Debian / Ubuntu | `clippy-pet_<v>_all.deb` | <span class="cp-chip cp-chip--release">on each release</span> |
| Fedora / RHEL / openSUSE | `clippy-pet-<v>-1.noarch.rpm` | <span class="cp-chip cp-chip--release">on each release</span> |
| Alpine | `clippy-pet_<v>_noarch.apk` | <span class="cp-chip cp-chip--release">on each release</span> |
| Arch | `clippy-pet-<v>-1-any.pkg.tar.zst` | <span class="cp-chip cp-chip--release">on each release</span> |
| Web (v1) sheet | `spritesheet-v1.webp` for ChatGPT web upload | <span class="cp-chip cp-chip--release">on each release</span> |
| Arch `.pkg.tar.xz` via `makepkg` | AUR-style PKGBUILD | <span class="cp-chip cp-chip--planned">planned</span> |
| AppImage | `Clippy-Pet-<v>-x86_64.AppImage` / `-aarch64` | <span class="cp-chip cp-chip--planned">planned</span> |
| Flatpak bundle | `Clippy-Pet-<v>.flatpak` | <span class="cp-chip cp-chip--planned">planned</span> |
| Snap | `clippy-pet_<v>_all.snap` | <span class="cp-chip cp-chip--planned">planned</span> |
| Gentoo ebuild | GURU overlay | <span class="cp-chip cp-chip--planned">planned</span> |
| Package managers | Homebrew, MacPorts, Nix, apt repo, COPR, OBS, AUR, aports, Snap Store, Flathub, conda-forge, vcpkg, conan | <span class="cp-chip cp-chip--planned">planned</span> ([details](managers.md)) |

!!! info "About that first release"

    Rows marked *on each release* depend on a tagged release existing. v1.1.0 is the first packaged release; if the [releases page](https://github.com/adammatthewsteinberger/clippy-pet/releases) is still empty when you read this, the one-liner will politely tell you so and the from-checkout path still works.

## Pages in this section

- **[One-line install & tarballs](curl.md)**: what `install.sh` does, line by line, and the tarball layout.
- **[macOS](macos.md)**: `.dmg`, `.pkg`, `.app`, signing/notarization status, Homebrew and MacPorts plans.
- **[Linux](linux.md)**: `.deb`, `.rpm`, `.apk`, Arch, and what each package puts where; AppImage/Flatpak/Snap/Nix plans.
- **[Package managers](managers.md)**: the per-ecosystem publication path we're following and how far along each is.
- **[Verify downloads](verify.md)**: `SHA256SUMS`, cosign, GitHub attestations, GPG and apk keys.

## Design in one paragraph

Pets are per-user (`~/.codex/pets/`), and no system package manager is allowed to write into your home directory. So every system package installs the payload under `<prefix>/share/clippy-pet/` plus a 400-line POSIX-sh CLI, and the CLI copies the payload into your home when you (or a login autostart entry you opt into) run it. GUI installers and the one-liner talk to your home directly. Same files, same checksums, everywhere. The [packaging runbook](../project/packaging.md) has the whole rationale.
