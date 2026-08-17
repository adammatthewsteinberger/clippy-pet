---
title: Install
description: Install Clippy Pet with one command on macOS, Linux, or any Unix-like system, or use the double-click .dmg, .deb, and .rpm installers.
---

# Install

<div class="cp-bubble">It looks like you want the fastest option. It's the first one.</div>

## The one-liner (any Unix-like system)

```sh
curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh
```

What it does, in order: resolves the latest release, downloads the small runtime tarball and its `SHA256SUMS`, verifies the checksum, and runs `clippy-pet install`. It never needs `sudo`, never touches anything outside `~/.codex/pets/clippy-pet/`, and prints what it did. [Read the script](../packages/curl.md) before you run it if you like; we do.

??? tip "Options you can pass"

    ```sh
    # symlink instead of copy (auto-updates if you keep the extracted tarball around)
    curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh -s -- --link

    # pin a version
    CLIPPY_PET_VERSION=v1.1.0 sh -c "$(curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh)"

    # respect an unusual Codex home
    curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh -s -- --codex-home ~/.config/codex
    ```

## Prefer a native installer?

=== ":material-apple: macOS"

    Download **`Clippy-Pet-<version>.dmg`** from the [latest release](https://github.com/adammatthewsteinberger/clippy-pet/releases/latest), open it, and double-click:

    - **Install Clippy Pet.app**: installs for your user only, no administrator password.
    - **Clippy-Pet-\<version\>.pkg**: installs for every user on the Mac (asks for admin), and drops the `clippy-pet` command in `/usr/local/bin`.

    Or from a terminal:

    ```sh
    sudo installer -pkg Clippy-Pet-<version>.pkg -target /
    ```

    Homebrew (`brew install adammatthewsteinberger/tap/clippy-pet`) and MacPorts are <span class="cp-chip cp-chip--planned">planned</span>; see [macOS installers](../packages/macos.md) for signing status and details.

=== ":material-linux: Linux"

    Native packages are attached to every [release](https://github.com/adammatthewsteinberger/clippy-pet/releases/latest):

    ```sh
    sudo apt install ./clippy-pet_<version>_all.deb              # Debian, Ubuntu, Mint, Pop!_OS…
    sudo dnf install ./clippy-pet-<version>-1.noarch.rpm         # Fedora, RHEL, openSUSE (zypper in ./…)
    sudo apk add --allow-untrusted ./clippy-pet_<version>_noarch.apk   # Alpine
    sudo pacman -U ./clippy-pet-<version>-1-any.pkg.tar.zst      # Arch, Manjaro, EndeavourOS
    ```

    Then run `clippy-pet install` once as your user (or click **Install Clippy Pet** in your application menu). Packages put the payload in `/usr/share/clippy-pet`; the pet itself always lives in *your* home directory.

    AppImage, Flatpak, Snap, AUR, COPR, and Nix are <span class="cp-chip cp-chip--planned">planned</span>. [Linux installers](../packages/linux.md) has the full, honest matrix.

=== ":material-console: From a checkout"

    ```sh
    git clone https://github.com/adammatthewsteinberger/clippy-pet
    ./clippy-pet/scripts/install.sh
    ```

    Same script as the one-liner; when it finds `pet.json` next to itself it installs offline from the checkout.

=== ":material-file-multiple-outline: By hand"

    Copy `pet.json` and `spritesheet.webp` from the repo (or a release tarball) into:

    ```text
    ${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/
    ```

    That's genuinely all any installer does.

## Did it work?

```sh
clippy-pet status     # exit 0 = installed and current, 1 = missing, 2 = outdated
clippy-pet path       # prints the pet directory
```

(If you used the one-liner or manual copy, `clippy-pet` may not be on your `PATH`; `ls ~/.codex/pets/clippy-pet/` works just as well.)

## Next: pick it

The files are in place; now tell ChatGPT or Codex to use them.

[Pick it in ChatGPT & Codex :material-arrow-right:](select.md){ .md-button .md-button--primary }
[Something's off? Troubleshooting](troubleshooting.md){ .md-button }
