# Changelog

Notable changes are documented here using [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions. Releases are intended to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Blog post "Shipping two files like they matter", which walks through each release guarantee (validator, version guard, reproducible tarballs, cosign-signed checksums, build attestations, distro smoke tests, honest status words) and how to reuse it.
- `llms.txt` on the documentation site, plus schema.org structured data for the project, its maintainer, and blog posts.
- A "Pick your way in" section in the README and a "Build it with us" section on the docs home page, pointing art, packaging, CI, and writing contributors at concrete first tasks.
- `CITATION.cff` abstract, keywords, documentation URL, and release-artifact URL; AppStream help and contribute links and keywords.

### Changed

- `install.sh` now refuses to install when neither `sha256sum` nor `shasum` is available, instead of warning and continuing unverified. The new `--skip-verify` flag restores the old behaviour for systems with no checksum tool; it never bypasses a checksum mismatch. ([#30](https://github.com/adammatthewsteinberger/clippy-pet/issues/30))

### Fixed

- The docs home page now states plainly that the site counts page views with cookie-free GoatCounter; it previously said analytics were off unless enabled.
- The roadmap and installers page no longer describe v1.1.0 as unreleased.
- The first blog post and the make-your-own guide now quote the QA numbers the QA page records (11 of 14 blind pairs, 13 of 16 frames in semantic review).
- The AppStream description now names OpenAI as well as Microsoft in the non-affiliation notice.

## [1.1.0] - 2026-08-17

### Changed

- Renamed the project from Clipster to Clippy Pet. The pet id, install directory, and package name are now `clippy-pet`.

### Added

- One-line installer (`install.sh`), the shared POSIX `clippy-pet` CLI (install / uninstall / status / sync / path / autostart), reproducible runtime tarballs, `.deb` / `.rpm` / `.apk` / Arch packages, and macOS `.app` / `.pkg` / `.dmg` installers, all built and smoke-tested in CI and attached to each release with `SHA256SUMS`, a cosign signature, and GitHub artifact attestations.
- Documentation site at <https://adammatthewsteinberger.github.io/clippy-pet/> (MkDocs Material): per-OS install guide, honest installer/package-manager status matrix, animation and look-direction galleries, pet-contract reference, QA evidence, make-your-own guide, blog, and about-the-author page. Deployed by `docs.yml` without touching package-repository paths on `gh-pages`.
- `spritesheet-v1.webp` (nine-row, 1536×1872) release asset built by `scripts/build-v1-spritesheet.py` for ChatGPT web pet upload.
- Engagement pass on `README.md`, `CONTRIBUTING.md` (docs preview, writing style guide, variant submission), `SUPPORT.md` (Discussions), a pet-variant issue template, a `FUNDING.yml` template, and dependabot coverage for docs and GitHub Actions.
- FOSS governance, validation, installation, and GitHub community files.
- Documented the protected GitFlow branch, contribution, release, and hotfix workflow.
- `AGENTS.md` as the canonical instructions for AI coding agents working in this repo (repo map, commands, spritesheet contract, branching model, PR checklist, release process), with `CLAUDE.md` and `GEMINI.md` pointing to it, Cursor rules at `.cursor/rules/clippy-pet.mdc`, and Claude Code skills for `validate` and `release` under `.claude/skills/`.

## [1.0.0] - 2026-08-13

### Added

- Codex-compatible v2 pet manifest and transparent 8-by-11 atlas.
- Nine standard animation states and sixteen clockwise look directions.
- Source strips, normalized frames, previews, and QA evidence.

[Unreleased]: https://github.com/adammatthewsteinberger/clippy-pet/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/adammatthewsteinberger/clippy-pet/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/adammatthewsteinberger/clippy-pet/releases/tag/v1.0.0
