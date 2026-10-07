---
date: 2026-09-30
authors: [adam]
categories: [Engineering]
slug: evidence-for-every-fix
description: Five open issues on a two-file project, and the evidence each fix needed before it could say "done". A blind test that caught a script moving pupils the wrong way, an installer tested with no checksum tool, AppImages run on native hardware, and a Nix example built from the docs themselves.
---

# Evidence for every fix

Clippy Pet had five open issues this week: an installer that trusted downloads it couldn't check, two missing package formats, four look frames that read the wrong way, and a request for a version that works at 32 px. All five now have a fix or a firm answer. This post is about the part that usually gets skipped: the evidence each one needed before it could honestly be called done.

If you maintain a small project, every habit below is cheap to copy.

<!-- more -->

## Test the failure, not the fix

The installer bug was one line. When neither `sha256sum` nor `shasum` existed, `install.sh` printed a warning and installed the download anyway. The fix makes it stop, and adds a `--skip-verify` flag for systems that have no checksum tool at all.

Testing only the new error message would have missed the dangerous case. So the test builds a fake release (a stub tarball, its `SHA256SUMS`, and a stub `curl` that serves them locally) and runs the real script under `dash` in a Debian container through five cases: no tool; no tool with the flag; a tool present; a tampered tarball; and a tampered tarball *with* the flag. The last one is the case that matters. A flag called "skip verify" must never let a tampered download through when a checksum tool is available. It doesn't, and [`tests/install-sh.sh`](https://github.com/adammatthewsteinberger/clippy-pet/blob/develop/tests/install-sh.sh) now proves it under `dash`, `bash` and `sh` on every pull request.

**Copy this:** for every escape hatch you add, write the test that tries to abuse it.

## Run it where it will run

AppImages bundle a per-architecture runtime, so "x86_64 and aarch64" means one payload packed twice. The first local test failed with `Exec format error`: an x86_64 AppImage under emulation on an ARM laptop, where the translation layer rejects the AppImage's magic bytes. That's an artefact of the test machine, not a bug. It's also exactly the kind of result that gets "fixed" by changing the wrong thing.

The CI job now runs each AppImage on a native runner of its own architecture. The Nix flake gets the same treatment: `nix flake check` runs on x86_64 and aarch64 Linux and on macOS. The Home Manager example in the docs is tested by extracting the code block *from the Markdown file* and building a real Home Manager generation from it ([`tests/home-manager-doc-example.sh`](https://github.com/adammatthewsteinberger/clippy-pet/blob/develop/tests/home-manager-doc-example.sh), also in CI), so the test checks the words a reader will copy.

**Copy this:** if your docs contain a config snippet, build the snippet, not your private copy of it.

## Let someone who can't see the answer check your work

Issue #29 was four look frames whose shallow diagonal didn't read at 64 px. The first attempt was a script that found each eye's centre, then moved each pupil to where the geometry said it should be. It would have shipped, except that it moved 112.5° *up*, when the whole complaint was that 112.5° already looked up.

The cause was the art itself. The eyes are shaded spheres, and their lower rim is darker than the "white" threshold, so every eye-centre estimate sat too high. Measuring harder wasn't the fix. The fix was nudging each pupil by 3 to 4 pixels, chosen by comparing each frame with its neighbours, and then asking someone who didn't know the answer.

That meant a blind test. All sixteen frames, before and after, rendered at 64 px, given random names, shuffled into two sets, and labelled by two raters with no answer key. Correct judgements on the four retouched frames went from 10 of 16 to 13 of 16. That's an improvement, and a modest one. The same test found two things nobody asked about. First, a noise floor: one rater labelled identical images differently across the two sets. Second, a bigger problem: the whole upper arc of look directions reads as "level" at 64 px. Both are on the [QA page](../../how-it-works/qa.md), next to the original numbers, which weren't touched.

The retouch script refuses to run on any cell whose SHA-256 isn't the original art or the finished result, and it never changes alpha. The first version did: 99 opaque pixels at the eyes' edges became partly see-through. A diff of the alpha channel caught it before anyone else could.

**Copy this:** when a change is about perception, get a verdict from someone who doesn't know what you expect, and publish the noise floor with the score.

## Answer the question that was asked

Issue #33 asked for a 32 px variant, and it asked for a sketch or a single test frame first. The honest deliverable was the groundwork, not 74 redrawn cells: the contract fixes cells at 192 × 208, so a tiny variant is a bolder character, not a smaller one. The same measurements found that the near-black eyebrows vanish entirely on dark terminals, at 64 px as well as 32. A prototype frame shows the trade-off in one image: thicker wire reads at 32 px, but it starts to fill the paperclip's loops. That judgement belongs to whoever draws it. [The design note](../../make/tiny-variant.md) has the evidence and a preview tool.

**Copy this:** close the issue that was asked, and open the ones you found.

## The pattern

None of this is specific to pets. Four habits:

1. Test the failure path of every escape hatch.
2. Run each build on the hardware and in the context it will ship to.
3. Get perceptual changes checked blind, and publish the noise floor.
4. Label status by what exists, not by what's merged.

The two packaging formats landed as *planned* on purpose. The AppImage becomes *on each release* only after a tagged release has actually shipped one, and the Nix flake becomes *live* once CI is green on `develop`. The status words are a promise, so they wait for the evidence.

Want to pick up the upper look arc, the dark-terminal eyebrows, or the tiny variant? [Start here](../../community/contributing.md).
