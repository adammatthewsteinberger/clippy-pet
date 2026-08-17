---
title: macOS
description: Clippy Pet macOS installers, .dmg with a no-admin .app and a system .pkg, plus signing/notarization status and Homebrew and MacPorts plans.
---

# macOS

<div class="cp-bubble">It looks like you're on a Mac. You get a disk image, because some things from 1996 are still good ideas.</div>

## What's in the `.dmg`

Every release attaches **`Clippy-Pet-<version>.dmg`** <span class="cp-chip cp-chip--release">on each release</span>. Open it and you'll find:

| Item | What it does | Admin? |
|---|---|---|
| **Install Clippy Pet.app** | Runs the bundled `clippy-pet install --gui` against *your* `~/.codex`, shows a done dialog with the "Settings → Pets" hint. Nothing is copied outside your home. | No |
| **Clippy-Pet-\<version\>.pkg** | Installer.app package. Puts `clippy-pet` in `/usr/local/bin`, the payload in `/usr/local/share/clippy-pet`, and a man page; then its postinstall runs `clippy-pet install` **as the logged-in console user** so the pet appears without a second step. Other users on the Mac run `clippy-pet install` once. | Yes |
| README, LICENSE, NOTICE | The usual. NOTICE is the not-affiliated-with-Microsoft text. | |

The `.pkg` is also attached on its own for scripted installs:

```sh
sudo installer -pkg Clippy-Pet-<version>.pkg -target /
```

Bundle identifiers: `io.github.adammatthewsteinberger.clippy_pet.installer` (the app) and `io.github.adammatthewsteinberger.clippy_pet.pkg` (the package). Both are built by [`packaging/macos/build.sh`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/packaging/macos/build.sh) using `osacompile`, `pkgbuild`, `productbuild`, and `hdiutil`. Intel and Apple silicon Macs are both supported; the payload is architecture-independent.

## Signing & notarization: current status

The build script signs with a Developer ID Application/Installer identity and submits to Apple's notary service **when the release workflow has the Apple credentials**. Until those secrets are set, releases are **ad-hoc signed and not notarized**, and Gatekeeper will show the "can't be opened" dialog.

<span class="cp-chip cp-chip--planned">planned</span> Notarized builds. Track progress in the [roadmap](../project/roadmap.md).

Meanwhile:

- Right-click the app or pkg → **Open**, or **System Settings → Privacy & Security → Open Anyway**.
- Or use the [one-liner](curl.md), which downloads a plain tarball and doesn't involve Gatekeeper at all.

## Homebrew

<span class="cp-chip cp-chip--planned">planned</span> A tap repository exists at [`adammatthewsteinberger/homebrew-tap`](https://github.com/adammatthewsteinberger/homebrew-tap) and the formula is written; publishing waits on the v1.1.0 tarball being live so the formula's URL and checksum resolve. Once published:

```sh
brew install adammatthewsteinberger/tap/clippy-pet
clippy-pet install
```

The formula installs the CLI and payload under the Homebrew prefix and prints a caveat reminding you to run `clippy-pet install` (Homebrew, correctly, doesn't write into your home). A `--cask` for the notarized `.pkg` follows once notarization is live. Submission to homebrew-core comes later, when the project meets its notability threshold.

## MacPorts

<span class="cp-chip cp-chip--planned">planned</span> A Portfile (`sysutils/clippy-pet`, `supported_archs noarch`) is drafted for submission to macports-ports after the first release. Then: `sudo port install clippy-pet`.

## Uninstalling

See [Uninstall](../get-started/uninstall.md). Short version: `clippy-pet uninstall`, and `sudo pkgutil --forget io.github.adammatthewsteinberger.clippy_pet.pkg` if you used the package.
