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
  packages + macOS installers, checksums them, signs the checksum file
  with cosign (keyless/OIDC), attaches a GitHub artifact attestation, and
  publishes a GitHub Release.
- `packaging/macos/{build.sh,postinstall,install.applescript,
  distribution.xml,resources/,clippy-pet.icns}` — builds "Install Clippy
  Pet.app" (no admin required; runs the CLI against the current user's
  Codex home), `Clippy-Pet-<v>.pkg` (system-domain install to
  `/usr/local`, with a postinstall script that seeds the console user's
  own `~/.codex/pets/clippy-pet/`), and `Clippy-Pet-<v>.dmg` (bundles
  both plus README/LICENSE/NOTICE). Verified locally: `pkgbuild`/
  `productbuild` output inspected via `pkgutil --expand-full` (correct
  4-file payload, correct Distribution/postinstall), the console-user/
  home-directory resolution the postinstall script performs was
  independently confirmed, and the bundled CLI was smoke-tested via the
  same code path the `.app` uses. Signing/notarization are wired into
  `release.yml` behind the Apple secrets listed below; without them the
  build still produces ad-hoc-signed, unnotarized artifacts (so forks
  and local builds work), which macOS Gatekeeper will flag until signed
  builds are published.

### Not yet built (tracked, see the plan for full detail per target)
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

## One-time setup: status

### Done

- **GitHub repo renamed** `clipster` → `clippy-pet` (GitHub redirects the
  old URL automatically). Local remote updated. Topics updated.
- **`homebrew-tap` repository created**:
  <https://github.com/adammatthewsteinberger/homebrew-tap> (empty
  `Formula/`/`Casks/` directories, ready for the formula/cask once
  written).
- **GitHub Pages enabled**, serving the `gh-pages` branch at
  <https://adammatthewsteinberger.github.io/clippy-pet/>.
- **Signing keys generated and stored as repo secrets**
  (`gh secret list -R adammatthewsteinberger/clippy-pet`):
  - `GPG_PRIVATE_KEY` / `GPG_PASSPHRASE` — RSA-4096 key for apt/rpm
    repository signing, expires 2026-08 + 2y. Public key committed at
    [`packaging/keys/clippy-pet-signing.gpg.asc`](../packaging/keys/clippy-pet-signing.gpg.asc)
    (fingerprint `49B2 46A2 9CD4 0801 4D5C  1EEE 57F1 8C00 88A5 8920`).
  - `APK_PRIVATE_KEY` — RSA-4096 key for Alpine `apk` repository signing.
    Public key committed at
    [`packaging/keys/clippy-pet-signing.apk.rsa.pub`](../packaging/keys/clippy-pet-signing.apk.rsa.pub),
    key name `adam@matthewsteinberger.com-6a834891` (already referenced
    by `apk.signature.key_name` wherever the apk repo signing step is
    added).
  - `AUR_SSH_PRIVATE_KEY` — ed25519 keypair for pushing to AUR. Public
    key is in `~/.clippy-pet-signing/aur-ed25519.pub` on the packaging
    machine (not committed, since it's only useful once attached to an
    AUR account — see the checklist below).
  - All four private keys/passphrase also live locally under
    `~/.clippy-pet-signing/` (mode 600) as a backup; that directory is
    outside the repo and is not tracked by git.

### Still needed (requires your action)

`release.yml` and future publishing steps read these secrets from
`repos/adammatthewsteinberger/clippy-pet` (Settings > Secrets and
variables > Actions) or, where noted, from a separate service's own
account settings. None of this can be done by an agent — each involves
identity verification, payment, or a web-only signup flow.

1. **Apple Developer ID** (unlocks signed/notarized macOS installers —
   highest-value remaining item):
   - Enroll at <https://developer.apple.com/programs/enroll/> ($99/yr).
   - In Xcode or the [developer portal](https://developer.apple.com/account/resources/certificates/list),
     create a **Developer ID Application** and a **Developer ID
     Installer** certificate.
   - Export both as one `.p12` from Keychain Access (File > Export
     Items), set a password.
   - Generate an app-specific password at <https://appleid.apple.com>
     (Sign-In and Security > App-Specific Passwords) for `notarytool`.
   - Set repo secrets: `MACOS_CERT_P12` (`base64 -i cert.p12 | pbcopy`),
     `MACOS_CERT_PASSWORD`, `APPLE_TEAM_NAME` and `APPLE_TEAM_ID` (shown
     in the certificate name, "Developer ID Application: `<name>`
     (`<team id>`)"), `APPLE_ID`, `APPLE_APP_PASSWORD`.

2. **AUR account** (<https://aur.archlinux.org/register>): after signing
   up, add this public key to your account's SSH Public Key field
   (Account Details > My Account):

   ```
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCAy9elXRWE/sg7x99FXS9+S24xcjaARo1R8nk7MR/t adam@matthewsteinberger.com (AUR clippy-pet)
   ```

   (also at `~/.clippy-pet-signing/aur-ed25519.pub`). No further secret
   needed — `AUR_SSH_PRIVATE_KEY` is already set.

3. **Launchpad account** (<https://launchpad.net/+login>) + create a PPA
   (Personal Package Archive) named `clippy-pet` under your account, then
   upload the GPG public key above to your Launchpad OpenPGP keys
   (Account > OpenPGP keys) and confirm it via the emailed challenge.
   Set repo secret `LAUNCHPAD_SSH_PRIVATE_KEY` (a separate SSH key
   registered to your Launchpad account for `dput`/SFTP uploads — not
   the AUR or GPG key).

4. **COPR account** (Fedora Accounts System,
   <https://accounts.fedoraproject.org>) → create a COPR project at
   <https://copr.fedorainfracloud.org>, then get an API token from
   <https://copr.fedorainfracloud.org/api/> and set repo secret
   `COPR_API_TOKEN` (the whole `~/.config/copr` file contents `gh
   secret set COPR_API_TOKEN < ~/.config/copr` works well).

5. **OBS account** (<https://build.opensuse.org>) → set repo secrets
   `OBS_USERNAME`/`OBS_PASSWORD` (or an API token, once wired into the
   `osc` step).

6. **Ubuntu One account** (<https://login.ubuntu.com>) for the Snap
   Store → `snapcraft login`, then `snapcraft export-login` to produce a
   credentials file for repo secret `SNAPCRAFT_STORE_CREDENTIALS`, and
   `snapcraft register clippy-pet` to claim the name.

7. **GitLab account** (<https://gitlab.alpinelinux.org>) for submitting
   the Alpine aports merge request. No secret needed for the self-hosted
   apk repo (already covered by `APK_PRIVATE_KEY`); this is only for the
   upstream aports submission.

8. **Gentoo GURU contributor access**: request via
   <https://wiki.gentoo.org/wiki/Project:GURU/Access_Request> (needs a
   Gentoo/GitHub identity and a short access request).

9. **Homebrew tap push token**: create a fine-grained GitHub Personal
   Access Token (<https://github.com/settings/personal-access-tokens/new>)
   scoped to just the `homebrew-tap` repository with Contents:
   Read-and-write, then set it as repo secret `TAP_GITHUB_TOKEN` on
   `clippy-pet`. (Deliberately not reusing a broader personal token here
   — CI should only be able to touch the tap repo.)

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
