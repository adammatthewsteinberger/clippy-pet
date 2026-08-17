# Governance

Clippy Pet currently uses a benevolent-maintainer model. Adam Matthew Steinberger is the lead maintainer and has final responsibility for releases, roadmap decisions, moderation, security coordination, and repository administration.

Decisions should be explained publicly in issues or pull requests whenever privacy and security permit. Contributions are evaluated on compatibility, visual quality, maintainability, accessibility, licensing clarity, and benefit to users. Maintainer status may be extended to sustained contributors in the future.

## Branch and release stewardship

The project uses GitFlow. `main` is the protected release branch and `develop` is the protected integration branch. Maintainers review contributions into `develop`, prepare `release/<version>` branches, merge stabilized releases into both `main` and `develop`, tag releases from `main`, and ensure urgent `hotfix/<description>` changes return to both long-lived branches.

Both long-lived branches require pull requests, successful validation, resolved review conversations, CODEOWNER approval, and linear history. Force pushes and deletion of the long-lived branches are prohibited. Repository administrators retain an emergency bypass for recovery, not as the routine contribution path.

This governance model may change as the contributor community grows; material changes will be recorded in `CHANGELOG.md`.
