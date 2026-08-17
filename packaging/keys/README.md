# Package signing keys

Public keys used to sign Clippy Pet releases. Import the one relevant to
your package manager; see [Verify downloads](https://adammatthewsteinberger.github.io/clippy-pet/packages/verify/)
for how each repository uses them.

| File | Used for | Fingerprint / identity |
|---|---|---|
| `clippy-pet-signing.gpg.asc` | apt/rpm repository signing (InRelease/repomd) | RSA-4096, fingerprint `49B2 46A2 9CD4 0801 4D5C  1EEE 57F1 8C00 88A5 8920`, `Adam Matthew Steinberger (Clippy Pet package signing) <adam@matthewsteinberger.com>`, expires 2028-08-16 |
| `clippy-pet-signing.apk.rsa.pub` | Alpine `apk` repository signing | key name `adam@matthewsteinberger.com-6a834891` (matches `apk.signature.key_name` in `packaging/linux/nfpm.yaml` and the filename Alpine expects under `/etc/apk/keys/`) |

Import the GPG key:

```sh
curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/keys/clippy-pet-signing.gpg.asc \
  | gpg --dearmor | sudo tee /etc/apt/keyrings/clippy-pet.gpg > /dev/null
```

Both the corresponding private keys are stored as GitHub Actions secrets
(`GPG_PRIVATE_KEY`/`GPG_PASSPHRASE`, `APK_PRIVATE_KEY`) and never committed.
