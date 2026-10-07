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

The packages ship an XDG autostart entry that runs `clippy-pet sync --quiet` at login. `sync` means *install only if missing*: it puts the pet back if it is gone and writes nothing when both files are already there, so it never overwrites. After a package upgrade, run `clippy-pet install --force` to refresh the files. It never touches Codex configuration. If you'd rather it didn't run:

```sh
clippy-pet autostart disable     # removes the per-user autostart entry (~/.config/autostart)
```

The packages also ship a system-wide entry in `/etc/xdg/autostart`, which `autostart disable` does not remove; to opt out of that one, copy it to `~/.config/autostart/` with `Hidden=true`. Note that after `clippy-pet uninstall`, a later `sync` (including the login-time one) installs the pet again. (If you'd prefer autostart to be opt-in rather than opt-out, [say so](https://github.com/adammatthewsteinberger/clippy-pet/discussions); it's a one-line policy change.)

## Universal formats <span class="cp-chip cp-chip--planned">planned</span>

Each will land on the releases page and flip to *on each release* only after a tagged release has actually shipped it. AppImage and Nix are further along than the rest; see their sections below.

| Format | Notes |
|---|---|
| **AppImage** (`x86_64`, `aarch64`) | Built by `packaging/appimage/build.sh` and smoke-tested on native runners of both architectures in `packaging-ci.yml`; the release workflow builds it before `SHA256SUMS` is signed. First attached to the next tagged release. [Details](#appimage) |
| **Flatpak** (`Clippy-Pet-<v>.flatpak` + self-hosted repo) | `org.freedesktop.Platform` runtime; needs `--filesystem=~/.codex/pets/clippy-pet:create`. A Flathub submission will be attempted; console-style apps often get pushback there, so the self-hosted repo is the fallback. |
| **Snap** | Strict confinement; writing to `~/.codex` needs the `personal-files` interface, so `sudo snap connect clippy-pet:dot-codex-pets` once until the store grants auto-connect. |
| **Nix** | `flake.nix` with a package, an app, `nix flake check` tests, and a Home Manager module (`programs.clippy-pet.enable`). In the repository on `develop`; nixpkgs submission after. [Details](#nix-and-home-manager) |
| **Gentoo** | `app-misc/clippy-pet` ebuild for the GURU overlay. |

## AppImage

The AppImage is an installer, not a long-running app: it carries the two pet files and the `clippy-pet` CLI, copies the pet into `${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/`, and exits.

```sh
chmod +x clippy-pet-<version>-x86_64.AppImage
./clippy-pet-<version>-x86_64.AppImage             # same as: install
./clippy-pet-<version>-x86_64.AppImage status
./clippy-pet-<version>-x86_64.AppImage uninstall
```

Double-clicking it in a file manager runs `install --gui`. Two CLI features are refused with an explanation, because an AppImage runs from a mount that disappears when it exits: `--link` (the link would dangle) and `autostart` (the login entry would point nowhere). Use a native package or the tarball if you want those. No FUSE? See [troubleshooting](../get-started/troubleshooting.md#appimage-wont-start).

## Nix and Home Manager

The repository is a flake. From a checkout, or from GitHub once this lands on the branch you point at:

```sh
nix run github:adammatthewsteinberger/clippy-pet/develop            # runs `clippy-pet install`
nix profile install github:adammatthewsteinberger/clippy-pet/develop # CLI on your PATH
```

Declaratively, with Home Manager. A minimal standalone setup (`home.nix` holds the rest of your configuration):

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clippy-pet = {
      url = "github:adammatthewsteinberger/clippy-pet/develop";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, clippy-pet, ... }: {
    homeConfigurations.you = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        clippy-pet.homeManagerModules.default
        { programs.clippy-pet.enable = true; }
        ./home.nix
      ];
    };
  };
}
```

That places `pet.json` and `spritesheet.webp` in `~/.codex/pets/clippy-pet/` as files Home Manager manages, so they update with your generation and disappear if you disable the module. Options:

| Option | Default | Meaning |
|---|---|---|
| `programs.clippy-pet.enable` | `false` | Install the pet. |
| `programs.clippy-pet.codexHome` | `".codex"` | Codex home, relative to your home directory. If you set `CODEX_HOME`, set this to match: flakes evaluate purely, so the module can't read your shell's environment. |
| `programs.clippy-pet.installCli` | `false` | Also put `clippy-pet` (for `status`, `path`, `version`) on your `PATH`. |
| `programs.clippy-pet.package` | this flake's package | Override the package. |

`nix flake check` builds the package, installs the pet into a scratch `CODEX_HOME` and compares it byte for byte, and evaluates the Home Manager module to confirm its file targets. CI runs it on x86_64 and aarch64 Linux and on macOS, and on Linux it also builds the example above straight out of this page. The status stays *planned* until that has run green on `develop`.

[Package managers :material-arrow-right:](managers.md){ .md-button }
