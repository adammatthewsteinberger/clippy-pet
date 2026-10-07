---
title: Packaging runbook
description: "Maintainer runbook for Clippy Pet releases: what CI builds, secrets, one-time setup status, the GitFlow release checklist, and how the docs site deploys without clobbering package repos."
---

# Packaging runbook

<div class="cp-bubble">It looks like you're the maintainer, or curious how the sausage is made. Either way, this is the operational reference.</div>

## What CI builds today

| Workflow | Trigger | Produces |
|---|---|---|
| `validate.yml` | PR, push | `scripts/validate.py` result; old-name guard (`clipster` may not reappear outside an allow-list) |
| `packaging-ci.yml` | PR, push to `develop`/`main` | shellcheck, `desktop-file-validate`, `appstreamcli validate`; tarballs; `.deb` `.rpm` `.apk` `.pkg.tar.zst`; install/status/uninstall smoke in `debian:stable`, `fedora:latest`, `alpine:latest`, `archlinux`; AppImages (x86_64, aarch64) with install/status/refusal/uninstall smoke on native runners of each architecture; `nix flake check` + `nix build` on x86_64 and aarch64 Linux and macOS; macOS `.app`/`.pkg`/`.dmg` build + bundled-CLI smoke |
| `release.yml` | tag `v*` | guard (tag on `main`; `VERSION` = `CHANGELOG` top = `CITATION.cff` = tag; validator) → Linux build (tarballs, nfpm packages, AppImages) (`SHA256SUMS`, cosign keyless bundle and GitHub artifact attestation are produced here, so they cover the Linux outputs only) ∥ macOS build (signed + notarized when Apple secrets exist) → GitHub Release merging both sets of assets, including `spritesheet-v1.webp` |
| `docs.yml` | PR (build only), push to `main`, manual | `properdocs build --strict`; deploy to `gh-pages` preserving reserved paths |

Local equivalents: `make validate`, `make lint`, `make dist`, `make v1`, `./packaging/linux/build.sh` (needs nfpm), `./packaging/appimage/build.sh` (Linux x86_64 or aarch64; downloads the pinned toolchain), `nix flake check` (needs Nix with flakes), `./packaging/macos/build.sh` (macOS), `make docs` / `make docs-serve`.

## Layout

```text
packaging/bin/clippy-pet          shared POSIX CLI (@VERSION@ / @DATADIR@ substituted at build)
packaging/share/                  man page, .desktop launcher + autostart, AppStream metainfo, icon
packaging/dist/make-tarballs.sh   reproducible tarballs (SOURCE_DATE_EPOCH from the tag commit)
packaging/linux/                  nfpm.yaml, build.sh, debian-copyright (DEP-5), debian-changelog
packaging/appimage/               build.sh (pinned, hash-verified appimagetool + runtimes), AppRun
flake.nix, flake.lock             Nix package, checks, and Home Manager module
packaging/macos/                  build.sh, postinstall, install.applescript, distribution.xml, resources/, .icns
packaging/keys/                   public GPG (.gpg.asc) and apk (.rsa.pub) keys + README
scripts/install.sh                bootstrap; published as /install.sh on Pages
scripts/build-v1-spritesheet.py   v1 crop for web upload
```

Identifiers: package/CLI/repo `clippy-pet`; reverse-DNS app id `io.github.adammatthewsteinberger.clippy_pet` (underscore, since the scheme can't take both dots and hyphens; `.installer` / `.pkg` suffixes for the two macOS bundles); data dir `<prefix>/share/clippy-pet/`; Homebrew tap `adammatthewsteinberger/homebrew-tap`; Pages `https://adammatthewsteinberger.github.io/clippy-pet/`.

## Design constraints worth remembering

- Pets are per-user; **no package may write to `$HOME`** (Debian policy, Homebrew policy, common sense). Packages ship payload + CLI; the CLI (or the opt-out autostart `sync`) copies into the user's home. Only the macOS `.app`, the `.pkg` postinstall (as the console user), and `install.sh` touch a home directory directly.
- Source-based recipes fetch the **runtime tarball** from Releases, not the GitHub source archive (`source/` and `qa/` are `export-ignore`).
- nFPM gotchas hit so far: env vars in `src` need `expand: true`; `packager:` for Arch goes in a top-level `archlinux:` block; don't declare `depends: sh` (breaks Debian's solver); hand-written `changelog.Debian.gz` beats nfpm's `changelog:`; run nfpm from `packaging/linux/`.
- macOS: `COPYFILE_DISABLE=1` before `pkgbuild`; PlistBuddy `Add … || Set …` for `CFBundleIdentifier`; postinstall resolves the console user via `${SUDO_USER:-$(stat -f%Su /dev/console)}`, skips `root`/`loginwindow`/`_*`, and never fails the package.
- Alpine's `cmp` may be missing; the CLI's `files_equal` falls back to `cksum`/`md5sum`.
- AppImages run from a transient mount, so `AppRun` refuses `--link` and `autostart` (both would leave references to it behind) and runs `install --gui` when started with no arguments and no TTY. Test them on a native runner: under emulation, binfmt handlers reject the AppImage magic bytes with `Exec format error`.
- The Home Manager module can't read `CODEX_HOME`: flakes evaluate purely. It exposes `programs.clippy-pet.codexHome` instead.

## Updating pinned toolchains

- **AppImage.** `packaging/appimage/build.sh` pins `appimagetool` (`APPIMAGETOOL_TAG`) and the type2 runtime (`RUNTIME_TAG`) to exact upstream releases, each checked against a SHA-256 in the script. To update: download the new release's `appimagetool-{x86_64,aarch64}.AppImage` and `runtime-{x86_64,aarch64}`, run `sha256sum` on them, and change the tag and hashes in one commit. Never point these at `continuous`.
- **Nix.** `nix flake update` refreshes `flake.lock`; move `nixpkgs` and `home-manager` to the next stable pair (`nixos-YY.MM`, `release-YY.MM`) together, and bump `home.stateVersion` in the flake's check to match.

## Secrets and one-time setup

Set in the repository's Actions secrets. Private keys and passphrases are **never** committed; an offline backup exists outside the repository.

| Secret | Purpose | Status |
|---|---|---|
| `GPG_PRIVATE_KEY`, `GPG_PASSPHRASE` | RSA-4096, apt/rpm repo signing; public key fingerprint `49B2 46A2 9CD4 0801 4D5C 1EEE 57F1 8C00 88A5 8920`, expires 2028-08 | set |
| `APK_PRIVATE_KEY` | Alpine signing (`adam@matthewsteinberger.com-6a834891`) | set |
| `AUR_SSH_PRIVATE_KEY` | push to AUR | set (public key must still be attached to an AUR account) |
| `TAP_GITHUB_TOKEN` | fine-grained PAT scoped to `homebrew-tap` only, Contents: read/write | **needed** |
| `MACOS_CERT_P12`, `MACOS_CERT_PASSWORD`, `APPLE_TEAM_NAME`, `APPLE_TEAM_ID`, `APPLE_ID`, `APPLE_APP_PASSWORD` | Developer ID signing + notarization | **needed** (requires Apple Developer enrolment) |
| `COPR_API_TOKEN` · `OBS_USERNAME`/`OBS_PASSWORD` · `LAUNCHPAD_SSH_PRIVATE_KEY` · `SNAPCRAFT_STORE_CREDENTIALS` | build services | **needed** (each requires an account) |

Accounts still to create, in order of value: Apple Developer ID → AUR → Launchpad (PPA) → COPR → OBS → Ubuntu One / Snap Store (`snapcraft register clippy-pet`) → GitLab (aports) → GURU access. Also: upload `docs/assets/social-preview.png` in the repository's Settings → Social preview (no API for that).

## Release checklist (GitFlow)

1. `release/x.y.z` from `develop`: bump `VERSION`; `CITATION.cff` `version:` and `date-released:`; move `CHANGELOG.md` *Unreleased* to `[x.y.z] - date` and fix compare links; `packaging/linux/debian-changelog` entry.
2. PR `release/x.y.z` → `main`; merge; back-merge into `develop`.
3. Tag `vX.Y.Z` on `main` → `release.yml` runs.
4. Check the Release page (all assets, `SHA256SUMS`, `.sigstore.json`), then `curl -fsSL …/install.sh | sh` on a clean machine.
5. Downstream: tap formula, AUR, COPR, OBS, PPA, snap edge, Pages repos, as each is wired; open a tracking issue for the manual PRs (nixpkgs, MacPorts, aports, GURU, conda-forge, Flathub).
6. `docs.yml` redeploys the site from `main` automatically; the announcement bar text lives in `overrides/main.html`.

## Docs and Pages

`gh-pages` hosts both this site and non-site paths. `docs.yml`:

1. `pip install -r docs/requirements.txt && properdocs build --strict`
2. copies `scripts/install.sh` → `site/install.sh` and `packaging/keys/*` → `site/keys/`, adds `site/.nojekyll`
3. checks out `gh-pages` and `rsync -a --delete` the site into it **excluding** `apt/ rpm/ alpine/ conda/ flatpak/` (the package repos, owned by the release pipeline)
4. asserts those directories still exist if they existed before, then commits and pushes; `concurrency: gh-pages` serialises it against any repo publisher

`properdocs gh-deploy` is deliberately not used because it force-replaces the branch.

## Naming

Project and package: `clippy-pet`. Display: Clippy Pet. Old name `clipster` is allowed only in the migration code path, the changelog, and the guard's allow-list; `validate.yml` fails otherwise.
