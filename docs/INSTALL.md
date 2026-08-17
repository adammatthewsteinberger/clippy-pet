# Installing Clippy Pet

Clippy Pet is a [Codex](https://developers.openai.com/codex) pet: a manifest
(`pet.json`) and a spritesheet (`spritesheet.webp`) that live in
`${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/`. Every installer below just
gets those two files into that directory; nothing else runs on your system
afterward.

After installing, reload Codex and open **Settings > Pets > Clippy Pet**
(desktop app), or run `/pets clippy-pet` in the Codex CLI TUI.

## One-line install (any Unix-like system)

```sh
curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh
```

This downloads the latest release tarball, verifies its SHA-256 checksum
against the published `SHA256SUMS`, and installs. Pass extra flags after
`--`, e.g. `--link` to symlink instead of copy:

```sh
curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh -s -- --link
```

Set `CLIPPY_PET_VERSION=v1.2.0` to pin a specific release instead of latest.

## From a checkout

```sh
git clone https://github.com/adammatthewsteinberger/clippy-pet
./clippy-pet/scripts/install.sh
```

## Package managers

| Manager | Command | Status |
|---|---|---|
| Homebrew (macOS/Linux) | `brew install adammatthewsteinberger/tap/clippy-pet` | planned (tap not yet published) |
| MacPorts | `sudo port install clippy-pet` | planned |
| Nix | `nix profile install github:adammatthewsteinberger/clippy-pet` | planned |
| APT (Debian/Ubuntu) | see below | planned (self-hosted repo) |
| DNF (Fedora) | see below | planned (COPR) |
| Zypper (openSUSE) | see below | planned (OBS) |
| pacman (Arch, via AUR) | `yay -S clippy-pet` | planned |
| apk (Alpine) | see below | planned (self-hosted repo) |
| Snap | `sudo snap install clippy-pet` | planned |
| Flatpak | `flatpak install clippy-pet.flatpakref` | planned |
| conda/mamba | `conda install -c conda-forge clippy-pet` | planned |

Native `.deb`, `.rpm`, `.apk`, and `.pkg.tar.zst` packages are attached to
every [GitHub Release](https://github.com/adammatthewsteinberger/clippy-pet/releases)
today and can be installed directly:

```sh
sudo apt install ./clippy-pet_<version>_all.deb      # Debian/Ubuntu
sudo dnf install ./clippy-pet-<version>-1.noarch.rpm # Fedora
sudo apk add --allow-untrusted ./clippy-pet_<version>_noarch.apk  # Alpine
sudo pacman -U ./clippy-pet-<version>-1-any.pkg.tar.zst           # Arch
```

Each package installs `clippy-pet` to your `PATH`, its data files under
`/usr/share/clippy-pet`, a man page (`man clippy-pet`), an "Install Clippy
Pet" entry in your application menu, and (disabled by default unless you
run `clippy-pet autostart enable`) an XDG autostart entry that keeps the pet
installed across package upgrades.

## macOS GUI installers

`.pkg`, `.app`, and `.dmg` installers, signed and notarized with a Developer
ID, are planned but not yet published — see [PACKAGING.md](PACKAGING.md) for
status.

## CLI reference

```
clippy-pet [install] [--codex-home DIR] [--link] [--force] [--if-missing] [--migrate] [--quiet] [--gui]
clippy-pet uninstall
clippy-pet status      # exit 0 up to date, 1 not installed, 2 outdated
clippy-pet sync        # install --if-missing, used by autostart
clippy-pet path
clippy-pet autostart {enable|disable|status}
clippy-pet version
```

See `man clippy-pet` (or [the man page source](../packaging/share/man/man1/clippy-pet.1))
for full details.

## Verifying a download

Every release publishes a `SHA256SUMS` file and a
[cosign](https://github.com/sigstore/cosign) keyless signature bundle:

```sh
shasum -a 256 -c SHA256SUMS
cosign verify-blob --bundle SHA256SUMS.sigstore.json \
  --certificate-identity-regexp 'https://github.com/adammatthewsteinberger/clippy-pet/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  SHA256SUMS
```

Releases also carry a
[GitHub artifact attestation](https://github.com/adammatthewsteinberger/clippy-pet/attestations),
verifiable with `gh attestation verify <file> -R adammatthewsteinberger/clippy-pet`.

## Migrating from Clipster

Clippy Pet was previously named Clipster. If you installed it under that
name, its files are at `~/.codex/pets/clipster/`. Running any current
installer with `--migrate` removes that legacy directory automatically;
otherwise you can delete it yourself once you've confirmed Clippy Pet is
installed and working.

## Troubleshooting

- **macOS Gatekeeper blocks the installer**: once signed installers are
  published, right-click > Open, or System Settings > Privacy & Security >
  Open Anyway. Until then, use a package manager or the one-line install.
- **AppImage won't run**: some minimal environments lack FUSE. Run it with
  `--appimage-extract-and-run`.
- **Snap can't write to `~/.codex`**: run
  `snap connect clippy-pet:dot-codex-pets` once after installing.
- **Pet doesn't appear on Linux under Wayland**: this is a known Codex
  Desktop limitation, not a Clippy Pet issue.
- **`CODEX_HOME` is set to something unusual**: every installer respects it;
  pass `--codex-home DIR` to the CLI directly if needed.
