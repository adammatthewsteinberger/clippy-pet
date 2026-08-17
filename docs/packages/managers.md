---
title: Package managers
description: The publication path Clippy Pet follows for every major package manager (Homebrew, MacPorts, Nix, apt, dnf, zypper, pacman, apk, Snap, Flatpak, conda, vcpkg, conan) and how far along each is.
---

# Package managers

<div class="cp-bubble">It looks like you have a favourite package manager. Here's where yours stands, and why it's not "just publish it".</div>

Each ecosystem has its own author path, its own review, and its own timeline. We're following the normal one for each rather than side-loading, which means most rows are still <span class="cp-chip cp-chip--planned">planned</span> as of this writing. This table is the source of truth; when a row goes live, its command will be added to the [Install page](../get-started/install.md).

| Manager | Command (once live) | Channel we're using | Status |
|---|---|---|---|
| Homebrew | `brew install adammatthewsteinberger/tap/clippy-pet` | Tap `adammatthewsteinberger/homebrew-tap` (repo exists, formula written); homebrew-core once notable | <span class="cp-chip cp-chip--planned">planned</span> |
| MacPorts | `sudo port install clippy-pet` | PR to `macports-ports` (`sysutils/clippy-pet`, noarch) | <span class="cp-chip cp-chip--planned">planned</span> |
| Nix | `nix profile install github:adammatthewsteinberger/clippy-pet` | `flake.nix` in-repo + Home Manager module; nixpkgs `pkgs/by-name` PR | <span class="cp-chip cp-chip--planned">planned</span> |
| apt (Debian, Ubuntu, …) | `deb [signed-by=…] https://adammatthewsteinberger.github.io/clippy-pet/apt stable main` | Signed static repo on GitHub Pages (GPG key [published](verify.md#gpg-and-apk-keys)); Launchpad PPA; Debian ITP long-term | <span class="cp-chip cp-chip--planned">planned</span> |
| dnf (Fedora, RHEL) | `dnf copr enable adammatthewsteinberger/clippy-pet` | COPR; Pages rpm-md repo; Fedora review long-term | <span class="cp-chip cp-chip--planned">planned</span> |
| zypper (openSUSE) | via OBS `home:adammatthewsteinberger:clippy-pet` | OBS; Factory later | <span class="cp-chip cp-chip--planned">planned</span> |
| pacman (Arch) | `yay -S clippy-pet` | AUR (`arch=any`, source = release tarball) | <span class="cp-chip cp-chip--planned">planned</span> |
| apk (Alpine) | Pages apk repo; `testing/clippy-pet` in aports | Self-hosted signed repo + aports MR | <span class="cp-chip cp-chip--planned">planned</span> |
| Snap | `sudo snap install clippy-pet` | Snap Store, `edge` → `stable`; needs `personal-files` approval | <span class="cp-chip cp-chip--planned">planned</span> |
| Flatpak | `flatpak install clippy-pet.flatpakref` | Self-hosted OSTree repo on Pages; Flathub PR attempted | <span class="cp-chip cp-chip--planned">planned</span> |
| conda / mamba | `conda install -c conda-forge clippy-pet` | conda-forge staged-recipes (`noarch: generic`); interim Pages channel | <span class="cp-chip cp-chip--planned">planned</span> |
| Gentoo | `emerge app-misc/clippy-pet` | GURU overlay | <span class="cp-chip cp-chip--planned">planned</span> |
| vcpkg | `vcpkg install clippy-pet --overlay-ports=…` | In-repo registry; upstream PR likely declined (data-only) | <span class="cp-chip cp-chip--planned">planned</span> |
| conan | `conan create .` | `conanfile.py`; conan-center likely declines (data-only) | <span class="cp-chip cp-chip--planned">planned</span> |

## Why so many, and why so honest

Two reasons. First, the whole point of a pet is that it's *there*: if you're on NixOS you shouldn't have to `curl | sh`. Second, this table doubles as the project's own to-do list, and lying to ourselves on it doesn't help anyone. Each row is one PR, account, or review queue away, and each has a maintainer runbook entry in [Packaging](../project/packaging.md).

If you maintain packages for one of these ecosystems and want to help land a row, [open a discussion](https://github.com/adammatthewsteinberger/clippy-pet/discussions); the recipes are drafted and we'd love a second pair of eyes.

[Verify downloads :material-arrow-right:](verify.md){ .md-button }
