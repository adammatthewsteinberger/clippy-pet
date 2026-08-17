---
title: Verify downloads
description: How to verify Clippy Pet releases with SHA256SUMS, cosign keyless signatures, GitHub artifact attestations, and the published GPG and apk keys.
---

# Verify downloads

<div class="cp-bubble">It looks like you don't take a stranger's word for it. Neither do we; here's how to check ours.</div>

Every release <span class="cp-chip cp-chip--release">on each release</span> publishes three independent proofs. Any one is enough; belt-and-braces people use all three.

## 1. Checksums

`SHA256SUMS` lists every asset. Download it next to the file(s) you fetched and:

```sh
shasum -a 256 -c SHA256SUMS --ignore-missing     # macOS / BSD
sha256sum -c SHA256SUMS --ignore-missing         # GNU
```

The [one-line installer](curl.md) does this for you automatically.

## 2. Sigstore signature on the checksum file

`SHA256SUMS` is signed keylessly with [cosign](https://github.com/sigstore/cosign) by the GitHub Actions release workflow. Verifying proves the checksum file was produced by *this repository's* workflow, not by someone with a stolen laptop:

```sh
cosign verify-blob \
  --bundle SHA256SUMS.sigstore.json \
  --certificate-identity-regexp 'https://github.com/adammatthewsteinberger/clippy-pet/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  SHA256SUMS
```

## 3. GitHub artifact attestation

Each release asset carries a build-provenance attestation you can check with the GitHub CLI:

```sh
gh attestation verify clippy-pet-<version>.tar.gz -R adammatthewsteinberger/clippy-pet
```

Attestations are listed at [github.com/adammatthewsteinberger/clippy-pet/attestations](https://github.com/adammatthewsteinberger/clippy-pet/attestations).

## GPG and apk keys

Repository signing keys for the <span class="cp-chip cp-chip--planned">planned</span> apt/rpm and Alpine repos are already published so you can pin them ahead of time:

| Key | Use | Where |
|---|---|---|
| RSA-4096 OpenPGP, fingerprint `49B2 46A2 9CD4 0801 4D5C 1EEE 57F1 8C00 88A5 8920`, expires 2028-08 | apt `InRelease`, rpm signatures | [`packaging/keys/clippy-pet-signing.gpg.asc`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/packaging/keys/clippy-pet-signing.gpg.asc), also served at [`/keys/`](https://adammatthewsteinberger.github.io/clippy-pet/keys/) on this site |
| RSA apk key `adam@matthewsteinberger.com-6a834891` | Alpine `.apk` and repo index | [`packaging/keys/clippy-pet-signing.apk.rsa.pub`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/packaging/keys/clippy-pet-signing.apk.rsa.pub) |

Private keys live only in the release workflow's secrets and in the maintainer's offline backup; they are never in the repository.

## macOS signing

Developer ID signing and Apple notarization of the `.app`/`.pkg`/`.dmg` are wired into the release workflow and activate when the credentials are present. Status: <span class="cp-chip cp-chip--planned">planned</span> (see [macOS](macos.md)). When live, `spctl -a -vv -t install Clippy-Pet-<version>.pkg` and `xcrun stapler validate` will pass.

## Reporting a problem

If a checksum or signature doesn't verify, **don't install**, and please [report it privately](../community/security.md).
