---
title: One-line install & tarballs
description: What Clippy Pet's install.sh does line by line, how to pin versions, and what's inside the runtime tarballs.
---

# One-line install & tarballs

<div class="cp-bubble">It looks like you're about to pipe curl into sh. Here's exactly what you'd be running.</div>

```sh
curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh
```

## What the script does

`install.sh` is a single POSIX shell file, wrapped in `main() { … }; main "$@"` so a truncated download can't run half a script. It has two modes:

**Checkout mode.** If a `pet.json` sits next to the script (you cloned the repo), it just runs `packaging/bin/clippy-pet install` from the checkout, offline.

**Remote mode.** Otherwise it:

1. Resolves the latest release by reading the `Location:` header of `https://github.com/adammatthewsteinberger/clippy-pet/releases/latest` (no API calls, no rate limits). Set `CLIPPY_PET_VERSION=v1.1.0` to pin.
2. Downloads `clippy-pet-<version>.tar.gz` **and** `SHA256SUMS` from that GitHub Release into a temporary directory.
3. Verifies the tarball's SHA-256 against `SHA256SUMS` using `sha256sum` or `shasum -a 256`, and aborts on mismatch.
4. Extracts it and runs `bin/clippy-pet install "$@"`, forwarding any flags you passed after `--`.
5. Cleans up the temporary directory.

It never uses `sudo`, never writes outside the temp dir and `${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/`, and needs only `curl` (or `wget`), `tar`, and a checksum tool.

[Read `scripts/install.sh` on GitHub :material-open-in-new:](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/scripts/install.sh){ .md-button }

??? example "Flags you can forward"

    ```sh
    curl -fsSL …/install.sh | sh -s -- --link            # symlink the pet dir to the extracted payload
    curl -fsSL …/install.sh | sh -s -- --force           # overwrite even if identical/edited
    curl -fsSL …/install.sh | sh -s -- --migrate         # also remove a legacy ~/.codex/pets/clipster
    curl -fsSL …/install.sh | sh -s -- --codex-home DIR  # explicit Codex home
    curl -fsSL …/install.sh | sh -s -- --quiet
    ```

    Note that `--link` points the pet directory at the *extracted temp copy* in remote mode, which is removed at the end; use `--link` from a checkout or an extracted tarball you intend to keep.

## The tarballs

Every release attaches the same tree in five compressions: `.tar.gz`, `.tgz` (identical bytes, different suffix for the tools that insist), `.tar.bz2`, `.tar.xz`, and `.zip`.

```text
clippy-pet-<version>/
├── bin/clippy-pet                 POSIX sh CLI, version and data dir baked in
├── share/clippy-pet/pet.json
├── share/clippy-pet/spritesheet.webp
├── share/man/man1/clippy-pet.1.gz
├── share/applications/io.github.adammatthewsteinberger.clippy_pet.desktop
├── share/metainfo/io.github.adammatthewsteinberger.clippy_pet.metainfo.xml
├── share/icons/hicolor/256x256/apps/io.github.adammatthewsteinberger.clippy_pet.png
├── install.sh
├── LICENSE
└── NOTICE.md
```

They're built by [`packaging/dist/make-tarballs.sh`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/packaging/dist/make-tarballs.sh) with sorted entries, zeroed ownership, and `SOURCE_DATE_EPOCH` from the tagged commit, so rebuilding the same tag yields the same bytes. Source-based package recipes (Homebrew, AUR, Nix, and friends) fetch the `.tar.gz`, not GitHub's auto-generated source archive, because the repository also carries ~19 MB of source frames and QA evidence that end users don't need.

Using a tarball directly:

```sh
tar xzf clippy-pet-<version>.tar.gz
./clippy-pet-<version>/bin/clippy-pet install
```

## The CLI that does the work

```text
clippy-pet [install] [--codex-home DIR] [--link] [--force] [--if-missing] [--migrate] [--quiet] [--gui]
clippy-pet uninstall
clippy-pet status              exit 0 current · 1 not installed · 2 outdated
clippy-pet sync                install --if-missing (what autostart runs)
clippy-pet path
clippy-pet autostart enable|disable|status
clippy-pet version
```

`man clippy-pet` has the long version. It's shellcheck-clean POSIX sh, tested under dash, bash, BusyBox ash, and macOS `/bin/sh`, and it finds its payload by looking (in order) at `$CLIPPY_PET_DATA`, the baked-in data dir, paths relative to itself, and the usual `/usr/share`, `/usr/local/share`, `/opt/homebrew/share` locations.

[Verify downloads :material-arrow-right:](verify.md){ .md-button }
