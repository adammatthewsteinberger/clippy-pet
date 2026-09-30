---
title: "About the maintainer: Adam Matthew Steinberger"
description: "Adam Matthew Steinberger maintains Clippy Pet and vibey. Staff software engineer for AI platforms, identity and security; takes fixed-scope work: AI security reviews, RAG chatbots, LLM gateways, Okta and Entra ID governance, SOC 2 readiness."
---

# About the maintainer

<div class="cp-bubble">It looks like you want to know who's responsible for this. Fair. It was on purpose.</div>

**Adam Matthew Steinberger** maintains Clippy Pet. He is a staff software engineer in Greenville, South Carolina, working US-remote, and has spent 13 years shipping production software for insurance, lending, healthcare and security teams. His recent work is the plumbing that lets AI run safely inside those places: identity governance kept in Git, LLM gateways with spend caps and tamper-evident audit trails, and release pipelines that hold up to review.

A paperclip pet is a small project. It gets the same treatment on purpose, because small projects are where good habits are cheap to practise and easy to see.

## Build something with him

**On Clippy Pet.** Every part of the project has a first task: pixel art, packaging for your distro, shell and CI, or a clearer sentence on any page. [Good first issues](https://github.com/adammatthewsteinberger/clippy-pet/labels/good%20first%20issue) are labelled, the [contributing guide](../community/contributing.md) fits on one screen, and reviews happen in writing on the pull request. If you'd rather ask first, [Discussions](https://github.com/adammatthewsteinberger/clippy-pet/discussions) is the place.

**On vibey.** His larger open-source project is [vibey](https://github.com/the-vibey-project/vibey) (MIT, `pip install vibey-engine`): a conductor that carries a change from a spec interview through design, build and review across several AI coding agents. Every decision and handoff lands in an append-only PostgreSQL ledger, and a person is asked only for the decisions that are theirs to make. Its chaos test crashes a fifth of its workers mid-job and passes only if no job is lost or run twice. [Read the docs](https://the-vibey-project.github.io/vibey/main/) or [volunteer on it](https://vibewithadam.matthewsteinberger.com/join-me).

## How this project is run

If you want to know how he works, this repository is a fair sample, and every item below links to the evidence:

- **Decisions are written down before they're built.** [`AGENTS.md`](https://github.com/adammatthewsteinberger/clippy-pet/blob/develop/AGENTS.md) states the invariants any contributor, human or AI, must keep; the [changelog](changelog.md) records what changed and why.
- **Releases can be checked, not just trusted.** Checksums are signed with cosign, every asset has a build-provenance attestation, and tarballs are reproducible. [How that works](../blog/posts/2026-09-30-shipping-two-files-like-they-matter.md).
- **Status words are a contract.** *Live* means it works today; *planned* means it doesn't exist yet. The [package managers page](../packages/managers.md) says planned more often than anything else.
- **Evidence includes the misses.** The [QA page](../how-it-works/qa.md) publishes blind-test results that failed alongside the ones that passed, with a noise floor.
- **Changes are tested where they'll run.** On every pull request, CI installs and uninstalls the packages in Debian, Fedora, Alpine and Arch containers, runs the AppImages on native runners of each architecture, runs `nix flake check` on Linux and macOS, tests the installer's refusal to install a tampered download, and builds the Home Manager example straight out of the docs.

## Fixed-scope engagements

Clippy Pet is free and stays free. Separately, Adam takes a small number of fixed-scope contract engagements, each one an outcome he has already delivered in production:

| Engagement | What you get | Proof |
|---|---|---|
| **AI codebase and security review** | Findings ranked by severity, a one-page summary, a phased roadmap | Reviewed a 59,000-line codebase in 10 hours; pre-release reviews have caught an auth bypass, path traversal and SSRF |
| **Production RAG chatbot in 30 days** | Answers from your documents with sources, an evaluation set, monitoring, a handoff | Two delivered in 30 days each, one fully self-hosted (Mistral-7B, FAISS, vLLM) |
| **LLM cost and policy gateway** | One API in front of your AI vendors, with spend caps, allowlists and an audit trail | Sole architect of a gateway in front of six vendors; three product teams moved onto it |
| **Okta and Entra ID governance fixes** | An access review, then groups, roles and policy managed from Git with drift detection | Two governance-as-code control planes, 40 resource kinds, no stored tenant secrets |
| **SOC 2 and OWASP LLM Top 10 readiness for an AI feature** | A STRIDE threat model and a control-gap list mapped to SOC 2, the OWASP LLM Top 10 and the NIST AI RMF | Wrote the SOC 2 readiness assessment and threat model for a report platform |

How an engagement runs:

- **Written first.** It starts with a short [written intake](https://github.com/adammatthewsteinberger/resume/blob/HEAD/freelance/intake.md) you answer on your own time. Calls are welcome, never required.
- **Fixed scope, fixed price,** with an acceptance checklist agreed in writing before work starts.
- **Predictable replies** in set windows each weekday, US Eastern time.
- **Risks in writing, early:** anything that threatens the date or scope gets a short note with options the day it's found.
- **Two or three clients at a time,** and every engagement ends with documentation your team can run without him.
- **AI use is disclosed.** He builds with AI coding agents under the same tests and review gates he'd hold a person to, signs off on every deliverable himself, and says which parts were agent-assisted.

[See the full catalogue :material-arrow-right:](https://github.com/adammatthewsteinberger/resume/blob/HEAD/SERVICES.md){ .md-button .md-button--primary }
[Email Adam](mailto:adam@matthewsteinberger.com){ .md-button }

Engagements are unrelated to Clippy Pet support, which stays in public [Discussions](https://github.com/adammatthewsteinberger/clippy-pet/discussions) and [Issues](https://github.com/adammatthewsteinberger/clippy-pet/issues) for everyone.

## Writing

*Novice to Navigator* is a plain-language guide to AI chatbots for business; the first edition is [free to read](https://vibewithadam.matthewsteinberger.com/novice-to-navigator). *Engineering Influence* is a 200-plus-source field manual on how influence, attention and culture work, with a hard rule against manipulating the audience you're trying to serve. This site tries to practise the honest half of that on a small, silly, well-made thing. Neither book is for sale; both are listed [on his site](https://vibewithadam.matthewsteinberger.com/books).

## Elsewhere

- Portfolio and open source: [vibewithadam.matthewsteinberger.com](https://vibewithadam.matthewsteinberger.com) · [open-source list](https://vibewithadam.matthewsteinberger.com/open-source)
- Résumé (Markdown, PDF, JSON Resume): [github.com/adammatthewsteinberger/resume](https://github.com/adammatthewsteinberger/resume)
- GitHub: [@adammatthewsteinberger](https://github.com/adammatthewsteinberger) · [The Vibey Project](https://github.com/the-vibey-project)
- LinkedIn: [linkedin.com/in/adammatthewsteinberger](https://www.linkedin.com/in/adammatthewsteinberger/)

Clippy Pet was made to brighten the hearts of Clippy lovers and to bring the old-school digital assistant into the 21st century.

## Supporting the project

A star on the repository helps more than you'd think (package-manager reviewers look), and a bug report helps more than a star. If a **Sponsor** button appears on the repository, it's optional.

[Back to the paperclip :material-arrow-left:](../index.md){ .md-button }
