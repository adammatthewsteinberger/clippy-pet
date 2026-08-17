---
name: release
description: Cut and tag a Clippy Pet release from main, following the guard rules enforced by .github/workflows/release.yml. Use when the user asks to create a release, cut a release, tag a version, or ship a new version.
---

# Release

Releases are built entirely by CI once a `v*` tag lands on `main` — this skill's job is to get `main` into a state the release workflow's `guard` job will accept, then tag it. Pushing the tag is public and effectively irreversible (it builds real installers and publishes a real GitHub Release), so **always confirm with the user before pushing the tag**, even in an otherwise autonomous session.

## 1. Establish the target commit

```sh
git fetch origin
git log origin/main --oneline -5
git tag -l --sort=-v:refname | head -5   # confirm the intended tag doesn't already exist
```

The release must be tagged on a commit that is an ancestor of `origin/main` (normally `origin/main`'s current HEAD itself).

## 2. Check whether main is release-ready

At the target commit, these three must all read the **same version string** (no `v` prefix), and it must be the version being released:

- `VERSION` — bare version, e.g. `1.1.0`
- `CHANGELOG.md` — the **top** entry must be `## [x.y.z] - YYYY-MM-DD` (a real date, not `## [Unreleased]`)
- `CITATION.cff` — the `version:` field

This is exactly what `release.yml`'s `guard` job checks; check it yourself first so a failure doesn't burn a CI run:

```sh
cat VERSION
sed -n 's/^## \[\([0-9][^]]*\)\].*/\1/p' CHANGELOG.md | head -n1
sed -n 's/^version: //p' CITATION.cff
```

If they don't already agree — e.g. there's unreleased content sitting under `## [Unreleased]` in `CHANGELOG.md` that needs to ship — prepare a release commit:

1. Rename `## [Unreleased]` to `## [x.y.z] - YYYY-MM-DD` (today's date) in `CHANGELOG.md`, leaving a fresh empty `## [Unreleased]` above it.
2. Update the compare-link footer at the bottom of `CHANGELOG.md` (the `[Unreleased]: .../compare/vX...HEAD` and `[x.y.z]: .../compare/...` lines).
3. Bump `VERSION` to `x.y.z`.
4. Bump `version:` in `CITATION.cff` to `x.y.z` (and `date-released:` if the project keeps that current).
5. Run `python3 scripts/validate.py` to make sure nothing else is broken.
6. Commit, and get this onto `main` through the project's normal flow — either it's already on `develop` and gets merged via a `release/x.y.z` branch per `AGENTS.md`'s branching model, or, for a hotfix, branch `hotfix/<description>` from `main` directly. Do not push straight to `main` without going through review unless the user explicitly directs otherwise.

If `main` already agrees on all three (as it will right after a release branch merges), skip straight to tagging.

## 3. Tag and push

Confirm with the user first (target commit, tag name, and that this will trigger a public release build). Then:

```sh
git tag -a vX.Y.Z <commit-sha> -m "vX.Y.Z"
git push origin vX.Y.Z
```

Pushing the tag triggers `.github/workflows/release.yml`: the `guard` job re-checks everything above, `build`/`macos` produce Linux packages, macOS installers, the v1 web spritesheet, and `SHA256SUMS` (cosign-signed, attested), and `publish` creates the GitHub Release with notes sliced verbatim out of that version's `CHANGELOG.md` section. Point the user at the Actions run to watch it (`gh run watch` or the repo's Actions tab) rather than assuming success.
