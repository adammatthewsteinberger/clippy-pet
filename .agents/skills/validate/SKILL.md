---
name: validate
description: Run Clippy Pet's full pre-commit check suite (manifest/spritesheet validator, shellcheck, docs build) based on what changed. Use before committing or opening a PR in this repo, or when the user asks to validate, check, or lint the project.
---

# Validate

Run the checks that apply to what actually changed in the working tree, per `AGENTS.md` and `CONTRIBUTING.md`'s PR checklist. Don't run steps that don't apply — e.g. don't require a docs build for a change that only touched `packaging/`.

1. Determine what changed: `git status --porcelain` and/or `git diff --stat` against the target branch.
2. Always run the manifest/spritesheet validator if `pet.json`, `spritesheet.webp`, or anything under `source/` changed (or when in doubt — it's fast):
   ```sh
   . .venv/bin/activate 2>/dev/null || python3 -m venv .venv && . .venv/bin/activate && python3 -m pip install -r requirements-dev.txt
   make validate
   ```
3. If any `.sh` file under `scripts/` or `packaging/` changed:
   ```sh
   make lint
   ```
   (requires `shellcheck`; report if it isn't installed rather than skipping silently)
4. If `docs/` or `mkdocs.yml` changed:
   ```sh
   pip install -r docs/requirements.txt
   make docs
   ```
   This runs `mkdocs build --strict`, so broken internal links fail it.
5. If `CHANGELOG.md`, `VERSION`, or `CITATION.cff` changed, sanity-check by eye that they still agree with each other (the release guard enforces this strictly at tag time — see the `release` skill).
6. Report which checks ran and their pass/fail result. Do not report the task as validated if a required check couldn't be run (e.g. missing `shellcheck`) — say so explicitly instead of skipping it quietly.
