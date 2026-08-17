# Changelog

Notable changes are documented here using [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions. Releases are intended to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
