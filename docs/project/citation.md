---
title: Cite this project
description: How to cite Clippy Pet, with the CITATION.cff metadata.
---

# Cite this project

<div class="cp-bubble">It looks like you're citing a paperclip in a paper. Someone had to be first.</div>

GitHub renders the repository's `CITATION.cff` as a **Cite this repository** button. The file itself:

```yaml
--8<-- "CITATION.cff"
```

Plain text:

> Steinberger, A. M. (2026). *Clippy Pet* (Version 1.1.0) [Computer software]. https://github.com/adammatthewsteinberger/clippy-pet

BibTeX:

```bibtex
@software{steinberger_clippy_pet_2026,
  author  = {Steinberger, Adam Matthew},
  title   = {Clippy Pet},
  year    = {2026},
  version = {1.1.0},
  url     = {https://github.com/adammatthewsteinberger/clippy-pet},
  license = {MIT},
  note    = {Unofficial animated paperclip pet for the ChatGPT desktop app and Codex CLI}
}
```

The version in `CITATION.cff` is bumped on every release together with `VERSION` and `CHANGELOG.md`; the release workflow checks that they agree.
