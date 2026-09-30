# Changelog

Notable changes are documented here using [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions. Releases are intended to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Blog post "Shipping two files like they matter", which walks through each release guarantee (validator, version guard, reproducible tarballs, cosign-signed checksums, build attestations, distro smoke tests, honest status words) and how to reuse it.
- `llms.txt` on the documentation site, plus schema.org structured data for the project, its maintainer, and blog posts.
- A "Pick your way in" section in the README and a "Build it with us" section on the docs home page, pointing art, packaging, CI, and writing contributors at concrete first tasks.
- `CITATION.cff` abstract, keywords, documentation URL, and release-artifact URL; AppStream help and contribute links and keywords.
- AppImages for x86_64 and aarch64 (`clippy-pet-<version>-<arch>.AppImage`), built by `packaging/appimage/build.sh` with a pinned, hash-verified `appimagetool` and runtime. The release workflow builds them before `SHA256SUMS` is signed, so they are covered by the cosign signature and attestations. Packaging CI smoke-tests each on a native runner. They are first attached to the next tagged release. ([#32](https://github.com/adammatthewsteinberger/clippy-pet/issues/32))
- `tests/install-sh.sh` (installer checksum handling, including the `--skip-verify` abuse case) and `tests/home-manager-doc-example.sh` (builds the documented Home Manager example), both run by packaging CI; `make test` runs the first.
- Blog post "Evidence for every fix": the verification behind this round of fixes (abuse-case installer tests, native-hardware packaging tests, a blind perceptual recheck with a published noise floor) and how to copy each habit.
- A rewritten "About the maintainer" page: how to build with the maintainer on Clippy Pet and vibey, how the project is run (each claim linked to its evidence), and the fixed-scope engagements he takes, which are kept separate from free public support. Structured data now describes the maintainer's role, expertise and services consistently with his résumé, and `llms.txt` gains a Maintainer section.
- `scripts/preview-at-size.py` renders any cells at 32–64 px over light and dark backgrounds, so visual changes can be judged at the sizes terminals actually draw. A [design note for a tiny variant](https://adammatthewsteinberger.github.io/clippy-pet/make/tiny-variant/) answers issue #33's open questions with evidence and a prototype test frame (`scripts/prototype-tiny-frame.py`); the variant itself is still planned. ([#33](https://github.com/adammatthewsteinberger/clippy-pet/issues/33))
- `flake.nix` with a `clippy-pet` package, `nix run` support, and a Home Manager module (`programs.clippy-pet.enable`, with `codexHome` and `installCli` options). `nix flake check` installs the pet into a scratch `CODEX_HOME` and verifies the module's file targets; CI runs it on Linux (x86_64, aarch64) and macOS. ([#31](https://github.com/adammatthewsteinberger/clippy-pet/issues/31))

### Changed

- `install.sh` now refuses to install when neither `sha256sum` nor `shasum` is available, instead of warning and continuing unverified. The new `--skip-verify` flag restores the old behaviour for systems with no checksum tool; it never bypasses a checksum mismatch. ([#30](https://github.com/adammatthewsteinberger/clippy-pet/issues/30))

### Fixed

- The README's "Related projects" listed seven repositories that no longer resolve; it now links vibey at its current home and the release-pipeline write-up.
- The package managers page and roadmap said a public Homebrew tap repository existed; it does not yet, and both now say so.
- The project page no longer describes v1.1.0 as unreleased.
- The pupils in the 112.5°, 157.5°, 202.5° and 292.5° look frames were nudged 3–4 px so each frame's minor-axis direction reads correctly against its neighbours (`scripts/retouch-look-pupils.py`; alpha and every other pixel unchanged). In a blind 64 px recheck, correct judgements on those frames rose from 10 of 16 to 13 of 16; details and caveats are on the QA page. ([#29](https://github.com/adammatthewsteinberger/clippy-pet/issues/29))
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
