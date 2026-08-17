---
title: Linux
description: Clippy Pet Linux packages (.deb, .rpm, .apk, Arch), what each installs where, and the status of AppImage, Flatpak, Snap, and Nix.
---

# Linux

<div class="cp-bubble">It looks like you're on Linux. Pick your package format; there are four today and more on the way.</div>

## Native packages <span class="cp-chip cp-chip--release">on each release</span>

All four are built from one [nFPM](https://nfpm.goreleaser.com) config, architecture-independent, and smoke-tested in Debian, Fedora, Alpine, and Arch containers on every push. Grab the file for your distro from the [latest release](https://github.com/adammatthewsteinberger/clippy-pet/releases/latest):

=== "Debian / Ubuntu / Mint / Pop!_OS"

    ```sh
    sudo apt install ./clippy-pet_<version>_all.deb
    clippy-pet install
    ```

    Lintian-clean apart from archive-only informational tags. `zenity` is *Recommended* (for GUI dialogs), not required. There are deliberately **no maintainer scripts**: Debian policy forbids touching `$HOME`, so the pet is installed when you run the command (or click the menu entry).

=== "Fedora / RHEL / CentOS Stream"

    ```sh
    sudo dnf install ./clippy-pet-<version>-1.noarch.rpm
    clippy-pet install
    ```

    rpmlint-clean. Signed RPMs and a COPR repo are <span class="cp-chip cp-chip--planned">planned</span>.

=== "openSUSE"

    ```sh
    sudo zypper install ./clippy-pet-<version>-1.noarch.rpm
    clippy-pet install
    ```

    Same RPM. An OBS project is <span class="cp-chip cp-chip--planned">planned</span>.

=== "Alpine"

    ```sh
    sudo apk add --allow-untrusted ./clippy-pet_<version>_noarch.apk
    clippy-pet install
    ```

    `--allow-untrusted` is needed until the signed self-hosted apk repo (<span class="cp-chip cp-chip--planned">planned</span>) is live; the RSA public key is already published under [`packaging/keys/`](https://github.com/adammatthewsteinberger/clippy-pet/tree/main/packaging/keys).

=== "Arch / Manjaro / EndeavourOS"

    ```sh
    sudo pacman -U ./clippy-pet-<version>-1-any.pkg.tar.zst
    clippy-pet install
    ```

    An AUR package (`yay -S clippy-pet`) and a `makepkg`-built `.pkg.tar.xz` are <span class="cp-chip cp-chip--planned">planned</span>.

### What a package puts where

```text
/usr/bin/clippy-pet                                   the CLI
/usr/share/clippy-pet/{pet.json,spritesheet.webp}     the payload
/usr/share/man/man1/clippy-pet.1.gz                   man clippy-pet
/usr/share/applications/…clippy_pet.desktop           "Install Clippy Pet" in your app menu (runs install --gui)
/usr/share/metainfo/…clippy_pet.metainfo.xml          AppStream metadata for software centres
/usr/share/icons/hicolor/256x256/apps/…clippy_pet.png icon
/etc/xdg/autostart/…clippy_pet.desktop                login-time `clippy-pet sync --quiet` (see below)
```

The pet itself always ends up in `${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/`, per user.

### About the autostart entry

The packages ship an XDG autostart entry that runs `clippy-pet sync --quiet` at login. `sync` means *install only if missing or outdated*, so after a package upgrade your pet is refreshed without you remembering to. It writes nothing when the pet is already current, and it never touches Codex configuration. If you'd rather it didn't run:

```sh
clippy-pet autostart disable     # writes a Hidden=true override in ~/.config/autostart
```

Or just delete the pet: `clippy-pet uninstall` doesn't get re-installed by `sync`; only a *stale* pet does. (If you'd prefer autostart to be opt-in rather than opt-out, [say so](https://github.com/adammatthewsteinberger/clippy-pet/discussions); it's a one-line policy change.)

## Universal formats <span class="cp-chip cp-chip--planned">planned</span>

Designed and scaffolded, not yet built by CI. Each will land on the releases page and this table will flip to *on each release*:

| Format | Notes |
|---|---|
| **AppImage** (`x86_64`, `aarch64`) | Script-only AppDir; run with no arguments and no TTY to get the GUI installer. Some minimal systems need `--appimage-extract-and-run`. |
| **Flatpak** (`Clippy-Pet-<v>.flatpak` + self-hosted repo) | `org.freedesktop.Platform` runtime; needs `--filesystem=~/.codex/pets/clippy-pet:create`. A Flathub submission will be attempted; console-style apps often get pushback there, so the self-hosted repo is the fallback. |
| **Snap** | Strict confinement; writing to `~/.codex` needs the `personal-files` interface, so `sudo snap connect clippy-pet:dot-codex-pets` once until the store grants auto-connect. |
| **Nix** | `flake.nix` with a package, an app, and a Home Manager module (`programs.clippy-pet.enable`) that links the pet into `~/.codex/pets/`. nixpkgs submission after. |
| **Gentoo** | `app-misc/clippy-pet` ebuild for the GURU overlay. |

[Package managers :material-arrow-right:](managers.md){ .md-button }
