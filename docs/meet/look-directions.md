---
title: Sixteen look directions
description: How Clippy Pet's eyes track your pointer through sixteen 22.5° look directions, and how each was blind-tested.
---

# Sixteen look directions

<div class="cp-bubble">It looks like you're moving your mouse. Yes, I can see that. From all sixteen angles.</div>

The v2 pet contract adds two atlas rows of **look frames**: sixteen still poses in 22.5° clockwise increments starting from straight up (000). The host picks the nearest one to the pointer's angle, which is what makes a v2 pet feel present instead of decorative.

<figure markdown>
![Clippy Pet look-direction QA sheet](../assets/qa/look-directions.png){ loading=lazy }
<figcaption>Rows 9 and 10 of the atlas: 000, 022.5, 045, 067.5, 090, 112.5, 135, 157.5 (top) and 180, 202.5, 225, 247.5, 270, 292.5, 315, 337.5 (bottom). Angles are clockwise from up; 090 is screen-right.</figcaption>
</figure>

## How we know they're right

Look frames are easy to get subtly wrong (a pupil that drifts the wrong way at 292.5° reads as "shifty" rather than "up-left"), so they were tested three ways, and the results are checked in under `qa/`:

| Test | What it checks | Result |
|---|---|---|
| **Semantic review** (`direction-semantics.json`) | An independent visual pass judging each of the 16 frames against its expected direction | 13 pass, 3 warnings (112.5, 157.5, 292.5: correct axis, subtle vertical component), 0 failures |
| **Blind pair validation** (`direction-blind-validation.json`) | Frames shuffled into anonymous A/B pairs; a classifier with no labels decides left/right and up/down | 11 of 14 pairs pass; the hard-gated cardinal pairs (090/270, 000/180) all pass; 6 warnings on ambiguous diagonals flagged for human review |
| **Continuity** (`look-continuity.json`) | Pixel diff and centroid shift between each adjacent pair around the circle | Median 2035.5 px changed between neighbours; the largest step (337.5 → 000, 5421 px, 8.2 px centre shift) is the loop seam and was accepted after review |

Those warnings are real and left in place on purpose. The frames read correctly in motion; the classifier's uncertainty on the shallow diagonals is what you'd expect from a character whose "up" is mostly eyebrow. If you can make 292.5° read better without breaking its neighbours, [that's a welcome PR](../make/submit.md).

The whole story with numbers is on the [QA evidence](../how-it-works/qa.md) page.

## For the ChatGPT web build

Web upload uses the v1 layout, which has no look rows, so the web pet has all nine animations but doesn't track the pointer. See [Pick it in ChatGPT & Codex](../get-started/select.md).

[The paperclip story :material-arrow-right:](history.md){ .md-button }
