---
title: Uninstall & migrate
description: Remove Clippy Pet completely in one command, and migrate from the old Clipster name.
---

# Uninstall & migrate

<div class="cp-bubble">It looks like you're removing a paperclip. No hard feelings; the 2001 send-off was worse.</div>

## Uninstall

```sh
clippy-pet uninstall
```

That deletes `${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/` and nothing else. If you never had the CLI on your `PATH` (one-liner or manual install), the equivalent is:

```sh
rm -rf "${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet"
```

Then remove the system package, if you used one:

```sh
sudo apt remove clippy-pet          # Debian/Ubuntu
sudo dnf remove clippy-pet          # Fedora
sudo apk del clippy-pet             # Alpine
sudo pacman -R clippy-pet           # Arch
sudo pkgutil --forget io.github.adammatthewsteinberger.clippy_pet.pkg   # macOS .pkg (then delete /usr/local/bin/clippy-pet and /usr/local/share/clippy-pet)
```

The macOS **Install Clippy Pet.app** installs nothing outside your home, so there's nothing to forget; delete the app if you copied it somewhere.

If you enabled the optional autostart sync (`clippy-pet autostart enable`), `clippy-pet autostart disable` removes `~/.config/autostart/io.github.adammatthewsteinberger.clippy_pet.desktop`. Nothing else is written anywhere.

## Migrating from Clipster

Clippy Pet was briefly called Clipster; if you installed under that name, the files sit at `~/.codex/pets/clipster/`. Any current installer with `--migrate` removes the legacy directory after installing the new one:

```sh
clippy-pet install --migrate
```

Or delete it by hand once Clippy Pet is working. Both pets can coexist; they just clutter the picker.

## Reinstalling later

Everything is idempotent. Run the [one-liner](install.md) again and you're back.
