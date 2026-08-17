# Contributing

Thanks for helping improve Clippy Pet. Whether it's a better eyebrow at 292.5°, a package recipe for your distro, or a typo in the docs, it's welcome. This file is the short version; the [documentation site](https://adammatthewsteinberger.github.io/clippy-pet/community/contributing/) renders it with more context.

## Setup

Python 3.10 or newer is recommended.

```sh
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install -r requirements-dev.txt
python3 scripts/validate.py
```

For packaging work: `make lint` (shellcheck), `make dist` (tarballs), `./packaging/linux/build.sh` (needs [nfpm](https://nfpm.goreleaser.com)), `./packaging/macos/build.sh` (macOS only).

For documentation: `pip install -r docs/requirements.txt` then `make docs-serve` and open <http://127.0.0.1:8000/clippy-pet/>. `make docs` runs `mkdocs build --strict`, which is what CI runs; broken links fail the build.

## Branching model

Clippy Pet uses GitFlow with two protected long-lived branches:

- `main` contains production-ready releases. Do not target ordinary contribution pull requests at `main`.
- `develop` is the integration branch for the next release. Feature, documentation, maintenance, and dependency pull requests normally target `develop`.

Use short-lived branches named for their purpose:

- `feature/<description>` for new behavior or assets
- `fix/<description>` for non-urgent corrections
- `docs/<description>` for documentation-only changes
- `release/<version>` for release stabilization; branch from `develop` and merge into both `main` and `develop`
- `hotfix/<description>` for urgent production fixes; branch from `main` and merge into both `main` and `develop`

Keep branches current with their target branch. Delete short-lived branches after merge. Releases from `main` use Semantic Versioning tags such as `v1.1.0`; routine development is never released directly from `develop`.

## Pull requests

1. Search existing issues and open one before a large compatibility or visual change. For animation or variant work, use the **Pet variant / show and tell** issue template.
2. Branch from `develop` and target `develop`, except for the documented release and hotfix flows.
3. Keep the change focused and explain its user impact.
4. Include before/after media for visual changes (100 % and ~64 px, plus a GIF if motion changed).
5. Preserve v2 geometry: 1536 by 2288 pixels, eight columns, eleven rows, and 192-by-208-pixel cells.
6. Preserve transparency, unused cells, and `spriteVersionNumber: 2`.
7. Update the `Unreleased` section of `CHANGELOG.md` for user-visible changes.
8. Run `make validate` (and `make docs` if you touched `docs/` or `mkdocs.yml`) and report the result.
9. Resolve every review thread and obtain the required CODEOWNER approval.
10. Do not add personal data, credentials, local absolute paths, cache IDs, or assets you cannot license.

## Writing style for docs and copy

Clippy Pet's documentation is deliberately playful (the pet talks in speech bubbles) and deliberately honest. When you write for it:

- Lead with what the reader gets; keep the joke short and after the substance.
- No manipulation: no fake urgency, no invented statistics, no testimonials, no "join thousands" without a real linked number.
- Status words are load-bearing. *live* means it works today; *on each release* means CI attaches it to every tagged release; *planned* means it does not exist yet. Never promote a row early.
- Every page that touches the name or likeness carries, or links to, the unofficial notice in `NOTICE.md`.
- Use current product names: "ChatGPT desktop app (Codex inside)", "Codex CLI", "ChatGPT on the web".
- Prefer showing (a GIF, a number from `qa/`, a command) over telling.

## Submitting a pet variant

See <https://adammatthewsteinberger.github.io/clippy-pet/make/submit/>. Short version: open the variant issue with a GIF, keep the geometry, run the validator, include before/after evidence, regenerate `SHA256SUMS`, and confirm you can license every pixel under MIT.

By submitting a contribution, you certify that you have the right to provide it under the MIT License. See `NOTICE.md` for limitations concerning third-party rights and trademarks.
