---
title: Submit a variant
description: How to propose an animation improvement or a Clippy Pet variant for inclusion, what evidence to include, and how review works.
---

# Submit a variant

<div class="cp-bubble">It looks like you've improved me. Let's make sure I stay improved.</div>

Two kinds of contribution are welcome here:

- **Improvements** to the existing frames (better 292.5° look, more expressive `waiting`, cleaner loop seams).
- **Variants**: alternate palettes or costumes that keep the paperclip identity (a "dark theme" variant, a holiday hat, a monochrome terminal-friendly build).

Brand-new characters that aren't paperclips are wonderful and belong in their own repository; post them in [Show and tell](../community/show-and-tell.md) and we'll link to them.

## Before you open the PR

1. **Open an issue first** using the [pet variant template](https://github.com/adammatthewsteinberger/clippy-pet/issues/new?template=pet_variant.yml). Attach a GIF or the contact sheet. This avoids two people redrawing the same eyebrow.
2. **Keep the geometry.** 1536 × 2288, 8 × 11 cells, 192 × 208 each, alpha, unused cells transparent, `spriteVersionNumber: 2`.
3. **Run `make validate`.** If your frame counts differ from Clippy Pet's, say so; the validator's `expected_used` will need updating and the reviewer will want to know why.
4. **Include before/after evidence**: at minimum a side-by-side of the affected frames at 100 % and at ~64 px, and a GIF if motion changed.
5. **Regenerate `SHA256SUMS`** (`make checksums`) if `pet.json` or `spritesheet.webp` changed.
6. **Update `CHANGELOG.md`** under *Unreleased*.
7. **Licensing**: you must have the right to contribute every pixel under MIT. No traced third-party art, no Microsoft assets, no AI-generated frames whose training provenance you can't vouch for.

## How review works

The maintainer (see [Governance](../community/governance.md)) checks: contract compliance, small-size readability across light and dark backgrounds, loop cleanliness, look-direction sanity if touched, licence clarity, and whether the change fits the character. Feedback happens in the PR; visual work often takes a round or two, which is normal.

Variants that are accepted ship either as replacement frames (improvements) or as an additional pet id in a `variants/` directory with its own `pet.json`, so users can install both.

## Style guide for docs and copy

If you also touch documentation:

- Playful is good; manipulative is not. No fake urgency, no invented numbers, no "join thousands of…" unless the number is real and linked.
- Every page that touches the name or likeness carries the unofficial notice or links to it.
- Status words mean things: *live*, *on each release*, *planned*. Don't promote a row without the thing actually existing.
- Use current product names: "ChatGPT desktop app (Codex inside)", "Codex CLI", "ChatGPT on the web".

More in [Contributing](../community/contributing.md).
