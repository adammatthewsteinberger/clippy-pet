# Contributing

Thanks for helping improve Clipster.

## Setup

Python 3.10 or newer is recommended.

```sh
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install -r requirements-dev.txt
python3 scripts/validate.py
```

## Branching model

Clipster uses GitFlow with two protected long-lived branches:

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

1. Search existing issues and open one before a large compatibility or visual change.
2. Branch from `develop` and target `develop`, except for the documented release and hotfix flows.
3. Keep the change focused and explain its user impact.
4. Include before/after media for visual changes.
5. Preserve v2 geometry: 1536 by 2288 pixels, eight columns, eleven rows, and 192-by-208-pixel cells.
6. Preserve transparency, unused cells, and `spriteVersionNumber: 2`.
7. Update the `Unreleased` section of `CHANGELOG.md` for user-visible changes.
8. Run `make validate` and report the result.
9. Resolve every review thread and obtain the required CODEOWNER approval.
10. Do not add personal data, credentials, local absolute paths, cache IDs, or assets you cannot license.

By submitting a contribution, you certify that you have the right to provide it under the MIT License. See `NOTICE.md` for limitations concerning third-party rights and trademarks.
