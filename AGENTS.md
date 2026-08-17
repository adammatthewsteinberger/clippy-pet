# AGENTS.md

Instructions for AI coding agents (Claude Code, Codex CLI, Cursor, Gemini CLI, and others) working in this repository. Tool-specific files (`CLAUDE.md`, `GEMINI.md`, `.cursor/rules/`) point back here — this is the canonical source. Human contributors should read [CONTRIBUTING.md](CONTRIBUTING.md) instead; the two documents describe the same rules but this one is written for an agent executing commands, not a person reading prose.

## What this project is

Clippy Pet is an unofficial, animated paperclip "pet" for the ChatGPT desktop app and Codex CLI, implementing OpenAI's documented pet file format as a third party. The deliverable is small and exact: a JSON manifest (`pet.json`) plus a single sprite atlas (`spritesheet.webp`), distributed through a one-line installer, native OS packages, and a signed GitHub release. A `v1` (nine-row, web-upload) spritesheet is built from the same source for ChatGPT on the web, which does not support look-direction tracking.

It is not affiliated with or endorsed by Microsoft or OpenAI — see [NOTICE.md](NOTICE.md). Never write or generate copy that implies otherwise.

## Repository map

| Path | Contents |
|---|---|
| `pet.json`, `spritesheet.webp` | The actual product: manifest + v2 atlas. Treat as a strict contract (see below). |
| `source/frames/`, `source/row-strips/` | Editable per-state source art the atlas is composed from. |
| `scripts/validate.py` | Validates manifest + atlas geometry/alpha/cell-occupancy. Run before every commit that touches the pet. |
| `scripts/build-v1-spritesheet.py` | Derives the legacy v1 (web-upload) sheet from v2 source. |
| `scripts/install.sh`, `packaging/bin/clippy-pet` | The one-line installer and the installed CLI (install/uninstall/status/sync/path/autostart). Shell, must pass `shellcheck`. |
| `packaging/linux/`, `packaging/macos/`, `packaging/dist/` | `nfpm`-based `.deb`/`.rpm`/`.apk`/Arch builds, macOS `.app`/`.pkg`/`.dmg` builds, reproducible tarballs. |
| `qa/` | Validator output, blind direction QA, semantic review, continuity/chroma reports, preview GIFs — the evidence backing README claims. Don't hand-edit; regenerate via the relevant script. |
| `docs/`, `mkdocs.yml`, `overrides/` | MkDocs Material documentation site, deployed to `gh-pages` by `.github/workflows/docs.yml`. |
| `.github/workflows/` | `validate.yml` (PR checks), `packaging-ci.yml` (build smoke tests), `release.yml` (tag-triggered release), `docs.yml`. |
| `VERSION`, `CHANGELOG.md`, `CITATION.cff` | Must always agree on the current version string — see Release process. |

## Setup and everyday commands

```sh
python3 -m venv .venv && . .venv/bin/activate
python3 -m pip install -r requirements-dev.txt
```

- `make validate` (or `python3 scripts/validate.py`) — manifest schema, `spriteVersionNumber == 2`, atlas is exactly 1536×2288 with an alpha channel, and per-cell occupancy matches the expected animation-frame counts. Run this after touching `pet.json`, `spritesheet.webp`, or anything under `source/`.
- `make lint` — `shellcheck` over the installer and packaging shell scripts. Run after touching any `.sh` file.
- `make dist` — builds reproducible tarballs via `packaging/dist/make-tarballs.sh` (runs `validate` first).
- `make v1` — builds `dist/spritesheet-v1.webp` for the web uploader.
- `make docs` — `mkdocs build --strict`; this is what CI runs, and broken internal links fail the build. Requires `pip install -r docs/requirements.txt`. Run after touching `docs/` or `mkdocs.yml`.
- `make docs-serve` — live preview at `http://127.0.0.1:8000/clippy-pet/`.
- `make checksums` — regenerates the root `SHA256SUMS` for `pet.json` + `spritesheet.webp` (not the release artifact checksums, which CI generates separately for `dist/`).

## Hard invariants — do not break these

- **v2 atlas geometry**: 1536×2288 px, 8 columns × 11 rows, 192×208-pixel cells, alpha channel present, `spriteVersionNumber: 2` in `pet.json`. `scripts/validate.py` enforces this; a change that fails it should not be committed.
- **Cell occupancy**: each row has a fixed number of populated (non-transparent) columns encoding animation frame counts (`expected_used` in `scripts/validate.py`). Adding/removing frames means updating that list deliberately, not accidentally leaving stray or missing pixels in a cell.
- **Path safety**: `pet.json`'s `spritesheetPath` must stay relative and inside the repo (no `..`, no absolute path) — the validator rejects anything else.
- **No official-affiliation language.** Every page that touches the Clippy/Office name or likeness must carry or link the unofficial notice in `NOTICE.md`. Use current, accurate product names: "ChatGPT desktop app (Codex inside)", "Codex CLI", "ChatGPT on the web" — not "Codex desktop" or similar inventions.
- **Status words in docs are load-bearing**: *live* = works today, *on each release* = CI attaches it to every tagged release, *planned* = does not exist yet. Never promote a row from planned to live without the thing actually existing and being tested.
- **No secrets, personal data, local absolute paths, or unlicensed assets** committed anywhere in the repo, including in generated QA output or commit messages.

## Branching model (GitFlow)

- `develop` is the default, integration branch. Ordinary feature/fix/docs/dependency PRs target `develop`.
- `main` is release-only and protected. Do not target ordinary PRs at it; only `release/<version>` and `hotfix/<description>` branches merge into it, and both of those also merge back into `develop`.
- Branch naming: `feature/<description>`, `fix/<description>`, `docs/<description>`, `release/<version>`, `hotfix/<description>`.
- Tags are created on `main` and use Semantic Versioning (`v1.1.0`). `develop` is never released directly.

## Pull request checklist

Before opening or updating a PR (mirrors `CONTRIBUTING.md`):

1. Branch from and target `develop` (unless doing the documented release/hotfix flow).
2. For any visual change: preserve v2 geometry and transparency, include before/after media (100% and ~64px, plus a GIF if motion changed).
3. Add an entry to the `## [Unreleased]` section of `CHANGELOG.md` for any user-visible change.
4. Run `make validate` (always) and `make docs` (if `docs/` or `mkdocs.yml` changed); report the result in the PR.
5. If shell scripts changed, run `make lint`.
6. Do not add personal data, credentials, local absolute paths, cache IDs, or unlicensed assets.

## Release process

Releases are cut from `main` and built entirely by `.github/workflows/release.yml`, triggered by pushing a `v*` tag. The workflow's `guard` job will hard-fail the release unless, **at the tagged commit**:

- `VERSION` (bare, e.g. `1.1.0`, no `v` prefix)
- the top dated entry in `CHANGELOG.md` (`## [1.1.0] - YYYY-MM-DD`, not `## [Unreleased]`)
- `version:` in `CITATION.cff`

all equal the tag name with its `v` stripped, and `python scripts/validate.py` passes, and the tag commit is an ancestor of `main`.

To cut a release: on `main`, move the `## [Unreleased]` changelog content into a new dated `## [x.y.z]` section, bump `VERSION` and `CITATION.cff` to match, update the changelog's compare-link footer, commit, then tag that commit `vX.Y.Z` and push the tag. CI then builds Linux packages, macOS installers, the v1 web spritesheet, checksums, a cosign signature, and GitHub artifact attestations, and publishes a GitHub Release with notes sliced directly out of that `CHANGELOG.md` section — so the changelog entry's wording ends up in the public release notes verbatim.

Because pushing a tag is public and hard to reverse (it builds and publishes a real GitHub release), an agent should confirm with the user before pushing a release tag rather than doing it autonomously.

## Writing style (docs and copy)

Documentation is deliberately playful but honest — see `CONTRIBUTING.md`'s "Writing style for docs and copy" section in full. In short: lead with what the reader gets, no manufactured urgency or fake stats, prefer showing (a GIF, a `qa/` number, a command) over telling.
