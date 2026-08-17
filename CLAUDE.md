# CLAUDE.md

This project's agent instructions live in [AGENTS.md](AGENTS.md) — read that first for the repo map, setup/validate/lint/docs commands, the v2 spritesheet's hard invariants, the GitFlow branching model, the PR checklist, and the release process.

Claude Code specifics not covered there:

- Two reusable skills are defined under `.claude/skills/`: `validate` (run the full pre-commit check suite) and `release` (cut and tag a release from `main`, following the guard rules in `.github/workflows/release.yml`). Prefer invoking these over reconstructing the steps by hand.
- Pushing a release tag is public and effectively irreversible (it triggers a real build-and-publish pipeline). Always confirm with the user before pushing a `v*` tag, even when otherwise operating autonomously.
