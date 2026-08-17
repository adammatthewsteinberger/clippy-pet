---
title: How it works
description: The pet contract Clippy Pet follows, where the files live, how the repository is laid out, and the QA evidence behind every frame.
---

# How it works

<div class="cp-bubble">It looks like you want to see under the hood. There isn't much of a hood; that's the nice part.</div>

A pet is two files. Everything else in this project exists to make those two files correct, verifiable, and easy to put in the right place.

- **[The pet contract](contract.md)**: `pet.json`, the atlas geometry, v1 versus v2, and where pets live on disk.
- **[QA evidence](qa.md)**: the validator, the blind direction test, semantic review, continuity, chroma cleanup, with the actual numbers.
- **[Repository layout](repository.md)**: what's where and why the runtime tarball is 1.5 MB while the repo is 19 MB.

```mermaid
flowchart LR
  A[pet.json + spritesheet.webp] -->|copied by| B[clippy-pet install]
  B --> C["~/.codex/pets/clippy-pet/"]
  C -->|scanned by| D[ChatGPT desktop app]
  C -->|scanned by| E[Codex CLI]
  A -->|cropped to v1| F[spritesheet-v1.webp]
  F -->|uploaded to| G[ChatGPT web]
```
