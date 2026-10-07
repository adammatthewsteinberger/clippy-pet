---
date: 2026-09-30
authors: [adam]
categories: [Engineering]
slug: shipping-two-files-like-they-matter
description: Clippy Pet is two files and 1.5 MB. Its release pipeline has a guard job, reproducible tarballs, cosign-signed checksums, build attestations, and four distro test containers. Here is each guarantee, the mechanism behind it, and how to borrow it for your own small project.
---

# Shipping two files like they matter

Clippy Pet is a JSON manifest and one image, about 1.5 MB together. The release that ships them has a guard job, reproducible tarballs, a signed checksum file, build-provenance attestations, and install tests in four Linux distributions and on macOS. That is more machinery than a paperclip needs. It is roughly the right amount for anything that asks you to paste `curl | sh` into a terminal.

This post walks through each guarantee, the mechanism behind it, and the file you would copy to get the same guarantee in your own project. None of it is specific to pets.

<!-- more -->

## The usual way

Most small projects ship like this: a tarball on a release page, a one-line install script, and a README that lists `brew install thing` next to a formula that hasn't been published yet. It works on the maintainer's machine. It usually works on yours.

The trouble is that "usually" is carrying the whole sentence. An install script runs with your user's permissions whether its payload is a compiler or a cartoon. The size of the project changes how much anyone will notice a problem. It doesn't change how much damage the problem can do.

## Where it breaks

Three failures show up again and again in small open-source releases. None of them is exotic.

1. **What you downloaded is not provably what CI built.** Without a checksum you can check against something the attacker can't also rewrite, a swapped tarball looks exactly like the real one.
2. **The version strings disagree.** `VERSION` says 1.2.0, the changelog's top entry says 1.1.0, and the citation file says 1.0.0. The release notes are now wrong in public, and nobody decided that on purpose.
3. **The docs promise commands that don't work yet.** The reader's first experience of your project is an error message, on a page that told them it would work.

Each one is cheap to prevent and expensive to explain after the fact.

## One guarantee at a time

| Guarantee | Mechanism | Where it lives |
|---|---|---|
| The asset matches its contract | A validator checks the manifest fields, the 1536 × 2288 atlas size, the alpha channel, path safety, and how many cells in each row are populated. It runs on every push and before every build. | [`scripts/validate.py`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/scripts/validate.py) |
| The repository stays clean | CI rejects commits that contain local absolute paths, generation cache IDs, or the project's retired name. | [`.github/workflows/validate.yml`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/.github/workflows/validate.yml) |
| A release can't publish mismatched versions | A `guard` job fails the release unless the tag is on `main` and the tag, `VERSION`, the top `CHANGELOG.md` entry, and `CITATION.cff` all agree. The validator runs again at the tagged commit. | [`.github/workflows/release.yml`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/.github/workflows/release.yml) |
| Rebuilding gives the same bytes | Tarballs are built with `SOURCE_DATE_EPOCH` taken from the last commit, sorted entries, a fixed mtime, and numeric owner 0. | [`packaging/dist/make-tarballs.sh`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/packaging/dist/make-tarballs.sh) |
| The checksums came from this repository's workflow | `SHA256SUMS` is signed keylessly with cosign. The signature bundle ties it to the GitHub Actions identity that produced it, with no long-lived signing key to lose. | `release.yml`, `SHA256SUMS.sigstore.json` on every release |
| Each checksummed asset has provenance | GitHub artifact attestations record which workflow run built which file. (The macOS installers are built in a separate job and are not covered yet.) | `actions/attest-build-provenance` in `release.yml` |
| Packages install on real systems | On every pull request and every push to `develop` or `main`, each `.deb`, `.rpm`, `.apk`, and Arch package is installed and exercised in a Debian, Fedora, Alpine, or Arch container, and the macOS app's bundled CLI is smoke-tested. The AppStream metadata and `.desktop` files are linted. | [`.github/workflows/packaging-ci.yml`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/.github/workflows/packaging-ci.yml) |
| The installer refuses a tampered download | `install.sh` fetches the tarball and `SHA256SUMS`, checks the hash, and stops on a mismatch before it copies anything. | [`scripts/install.sh`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/scripts/install.sh) |
| The docs don't promise what doesn't exist | Every install route carries one of three status words: *live*, *on each release*, or *planned*. The rule is that no row moves until the thing exists and has been tested. | [Installers & packages](../../packages/index.md) |

The last row isn't a CI job, and it's the one I'd keep if I could only keep one. The other eight protect the files. That one protects the reader's trust, and the reader is who the files are for.

## Check it yourself

You don't have to take any of this on faith. Download a release asset and its `SHA256SUMS`, then:

```sh
sha256sum -c SHA256SUMS --ignore-missing          # or: shasum -a 256 -c ...

cosign verify-blob \
  --bundle SHA256SUMS.sigstore.json \
  --certificate-identity-regexp 'https://github.com/adammatthewsteinberger/clippy-pet/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  SHA256SUMS

gh attestation verify clippy-pet-1.1.0.tar.gz -R adammatthewsteinberger/clippy-pet
```

Any one of those is enough to catch a swapped file. The [verification page](../../packages/verify.md) explains what each proves and what it doesn't.

## What I'd change

A pipeline write-up that only lists what went right isn't evidence. Here is what's still open.

- **macOS builds aren't notarized.** Developer ID signing and notarization are wired into the release workflow and switch on when the Apple credentials exist. Until then, Gatekeeper asks for a right-click and Open, and the docs say so on every macOS page.
- **The installer used to have a soft fallback.** With neither `sha256sum` nor `shasum`, `install.sh` printed a warning and skipped verification. That is fixed ([#30](https://github.com/adammatthewsteinberger/clippy-pet/issues/30)): it now stops, `--skip-verify` is the explicit opt-out, and the flag never bypasses a checksum mismatch. [`tests/install-sh.sh`](https://github.com/adammatthewsteinberger/clippy-pet/blob/develop/tests/install-sh.sh) covers the abuse case.
- **The blind look-direction QA scores 11 of 14 pairs.** The three flagged pairs are shallow diagonals where the whole cue is a couple of pixels of pupil. The warnings are [published verbatim](../../how-it-works/qa.md) instead of tuned away. Redrawing those frames is a good first contribution.
- **Most package managers are still *planned*.** Recipes are drafted, but each registry needs an account, a reviewer, or both. I'd rather show a column of honest grey chips than a column of commands that fail.

## Take it

The packaging pipeline is payload-agnostic. Swap `pet.json` and `spritesheet.webp` for your own files and most of it keeps working. If you want one guarantee without the rest:

- **Just checksums:** copy the verify function from `scripts/install.sh` and the `Checksums` step from `release.yml`.
- **Signed checksums:** add the two cosign steps. The workflow needs `id-token: write`, and there's no key to manage.
- **Version agreement:** copy the `guard` job. It's about a dozen lines of shell, and it turns "the release notes are wrong" from a public correction into a red check before anything ships.
- **Reproducible tarballs:** copy the four `tar` flags and the `SOURCE_DATE_EPOCH` block from `make-tarballs.sh`.

If you adapt any of it, I'd like to hear how it went. Open a thread in [Discussions](https://github.com/adammatthewsteinberger/clippy-pet/discussions) or pick up a [good first issue](https://github.com/adammatthewsteinberger/clippy-pet/labels/good%20first%20issue). The paperclip will watch.
