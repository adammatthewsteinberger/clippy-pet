# Packaging maintainer runbook

This documents how Clippy Pet's installers and packages are built, what's
live today, and what's left. See the top-level plan this was built from for
full design rationale; this file is the day-to-day operational reference.

## Status

### Done and verified in CI
- `packaging/bin/clippy-pet` — shared POSIX CLI, shellcheck-clean, tested
  under dash and bash.
- `scripts/install.sh` — dual-mode bootstrap (checkout + `curl | sh`).
- `packaging/dist/make-tarballs.sh` — reproducible
  `.tar.gz`/`.tgz`/`.tar.bz2`/`.tar.xz`/`.zip` runtime tarballs.
- `packaging/linux/{nfpm.yaml,build.sh}` — `.deb`, `.rpm`, `.apk`,
  `.pkg.tar.zst`. Functionally verified (install/status/uninstall
  round-trip against a byte-identical payload) in `debian:stable`,
  `fedora:latest`, `alpine:latest`, and `archlinux:latest` containers, and
  lint-clean under `lintian`/`rpmlint` aside from Debian-archive-only
  informational notes (e.g. `initial-upload-closes-no-bugs`, which only
  applies to an actual ITP submission).
- `.github/workflows/packaging-ci.yml` — lints + builds + smoke-tests all
  of the above on every PR and push to `develop`/`main`.
- `.github/workflows/release.yml` — on a `v*` tag: guards version
  consistency (`VERSION` == `CHANGELOG.md` top entry == `CITATION.cff`
  version == tag) and that the tag is on `main`, builds tarballs + Linux
  packages, checksums them, signs the checksum file with cosign
  (keyless/OIDC), attaches a GitHub artifact attestation, and publishes a
  GitHub Release.

### Not yet built (tracked, see the plan for full detail per target)
- macOS `.app`/`.pkg`/`.dmg` (signed + notarized — Apple Developer ID is
  available; secrets not yet wired into CI).
- AppImage, Flatpak, Snap.
- Homebrew tap + formula/cask, MacPorts Portfile, Nix flake + Home
  Manager module, AUR PKGBUILD, Alpine aports, Gentoo GURU ebuild, conda
  recipe, vcpkg port, conan recipe.
- Self-hosted GitHub Pages repos (apt/rpm-md/alpine/conda/flatpak) and the
  `install.sh` bootstrap hosting.
- COPR, OBS, Launchpad PPA build-service wiring.
- Upstream submissions: homebrew-core, nixpkgs, MacPorts, conda-forge,
  aports, GURU, Snap Store, Flathub, Debian ITP, Fedora review, openSUSE
  Factory.

## One-time setup required before the next phase

These are account/credential steps only the repo owner can do; nothing
else is blocked on them, but each corresponding package manager is:

- Rename the GitHub repo `clipster` → `clippy-pet` (the rename in this
  codebase is already done; this is the GitHub-side rename plus updating
  the local remote).
- Create the `homebrew-tap` repository.
- Enable GitHub Pages (serves `install.sh` and the static package repos).
- Generate and store as repo secrets: a GPG key (RSA-4096) for apt/rpm/
  alpine signing, an APK RSA signing key, an SSH key for AUR, a GitHub
  token scoped to the tap repo.
- Apple Developer ID certificate + notarization credentials (App Store
  Connect API key or app-specific password) as repo secrets.
- Accounts: AUR, Launchpad, COPR, OBS, Ubuntu One (Snap Store), GitLab
  (Alpine aports), GURU contributor access.

## Local build commands

```sh
make lint          # shellcheck every packaging script
make dist          # runtime tarballs -> dist/
./packaging/linux/build.sh   # .deb/.rpm/.apk/.pkg.tar.zst -> dist/ (needs nfpm)
```

## Release checklist (GitFlow)

1. On `release/x.y.z` branched from `develop`: bump `VERSION`, the
   `CITATION.cff` `version:`/`date-released:` fields, and move the
   `CHANGELOG.md` `[Unreleased]` section to a new `[x.y.z] - <date>`
   entry with updated compare links.
2. Merge `release/x.y.z` into `main` and `develop` per
   [CONTRIBUTING.md](../CONTRIBUTING.md).
3. Tag `vX.Y.Z` on `main`. This triggers `.github/workflows/release.yml`.
4. Once the Release is live, downstream publication steps (tap, AUR, etc.)
   run or are triggered manually per the plan, as each is wired up.

## Naming

The project and package name is `clippy-pet` everywhere except the reverse-
DNS application id, which uses `clippy_pet` (underscore) because dots and
hyphens are not both allowed in that scheme:
`io.github.adammatthewsteinberger.clippy_pet`.
