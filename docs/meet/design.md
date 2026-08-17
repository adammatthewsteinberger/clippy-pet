---
title: Design notes
description: "How Clippy Pet was drawn to read at small sizes: silhouette, palette, the 192×208 cell, eye placement, and loop discipline."
---

# Design notes

<div class="cp-bubble">It looks like you care about craft. Pull up a chair; this is the part I'm proud of.</div>

Pets render small (roughly 64 to 96 px tall in practice) on a background you don't control, and every frame has to sit inside a fixed 192×208 pixel cell. That constrains everything.

## Silhouette first

A paperclip is one continuous wire plus two eyes, which is close to the ideal small-size character: high-contrast outline, no interior detail that needs to survive downscaling. Every state was designed as a **silhouette pass first** (does the pose read in flat black at 64 px?) and shaded second. The failed and waiting states, which lean on posture, were reworked more than once until they read without eyebrows.

## The 192×208 cell

The contract fixes cells at 192 wide × 208 tall. The pet stands with its feet (well, the bottom of the loop) on a consistent baseline near the bottom of the cell so that switching between rows doesn't make it hop, and the tallest jump frame still keeps a few pixels of transparent margin at the top. `running-left` and `running-right` are mirrored *poses*, not mirrored *pixels*: the highlight stays on the same side so the light source doesn't flip when the character turns.

## Eyes carry everything

Almost all of the expression is in the eyes: pupil position, lid height, eyebrow angle. That's also why the [sixteen look directions](look-directions.md) got their own QA: a pupil that's two pixels off at 292.5° reads as suspicion. Pupils are drawn large and dark so they survive downscaling; whites are kept slightly warm so the pet doesn't look like two headlights against a dark theme.

## Palette

The wire is a cool silver-lilac gradient with a warm highlight, chosen to be visible on both light and dark backgrounds without an outline. Colours were checked at 50 % scale on pure white, `#1e1e1e`, and a busy code screenshot; if you use the [source frames](../make/index.md) to recolour, keep at least a 3:1 luminance contrast between wire and background across both themes.

## Transparency and chroma

Frames were generated over a chroma key and de-spilled with an edge-local suppression pass: 226,035 edge pixels touched across the atlas, alpha preserved everywhere, zero rejected pixels. The full report is `qa/chroma-despill-extended.json`. The look-continuity check also flags "interior hole rows" (small fully transparent runs inside the wire loop): those are intentional, they're the see-through gaps of a paperclip, and the report lists them so nobody mistakes them for a bug later.

## Loop discipline

Every animation row is authored so its last frame flows back into its first: no pop when the host loops. Idle has six frames plus a neutral seventh cell that the host can hold on. Waving is only four frames on purpose; a long wave overstays its welcome, which is a lesson the original character taught everyone.

## What we'd still like to improve

- Shallow diagonals (112.5°, 157.5°, 292.5°) could carry a touch more vertical cue.
- A dedicated 32 px "tiny" variant would help terminals with small cell heights.
- More personality in `waiting` without adding frames.

Each is a good first contribution. See [Make your own](../make/index.md) and [Submit a variant](../make/submit.md).
