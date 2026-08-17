---
title: QA evidence (the receipts)
description: The validator, blind direction QA, semantic review, look continuity, and chroma cleanup evidence behind Clippy Pet, with the real numbers including the warnings.
---

# QA evidence (the receipts)

<div class="cp-bubble">It looks like you'd like proof rather than adjectives. Here's every check, every number, and every warning we decided to keep.</div>

Everything on this page is reproducible from files checked into the repository under `qa/` and `scripts/`. Nothing has been rounded up, and warnings are listed because a QA page that only shows green ticks isn't evidence, it's decoration.

## The validator

[`scripts/validate.py`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/scripts/validate.py) runs in CI on every push and before every package build. It fails hard on any of:

- `pet.json` missing a required field (`id`, `displayName`, `description`, `spriteVersionNumber`, `spritesheetPath`)
- `spriteVersionNumber != 2`
- an absolute or `..`-containing `spritesheetPath`
- image not exactly 1536 × 2288, or without an alpha channel, or entirely transparent
- **cell occupancy** deviating from the expected `[7, 8, 8, 4, 5, 8, 6, 6, 6, 8, 8]` populated cells per row, checked per cell using the alpha bounding box

```console
$ make validate
ok: Clippy Pet manifest and v2 spritesheet contract are valid
```

The [v1 build script](../how-it-works/contract.md#v1-versus-v2) applies the same occupancy check to its nine rows.

## Blind direction validation

`qa/direction-blind-validation.json`. The sixteen look frames were shuffled into anonymised A/B pairs (seven horizontal, seven vertical) and classified without labels: does A look further screen-left than B? further up?

| Metric | Value |
|---|---|
| Pairs | 14 (7 horizontal, 7 vertical) |
| Passing pairs | **11 / 14** |
| Hard-gated cardinal pairs (090 vs 270, 000 vs 180) | pass |
| Errors | 0 |
| Warnings | 6 |
| Human review required | yes (done; see semantic review) |

The six warnings, verbatim from the report:

```text
horizontal-7 A horizontal axis is ambiguous
horizontal-7 B classified screen-left; expected screen-right
vertical-4 A classified up; expected down
vertical-4 A and B were classified as the same vertical direction
vertical-7 A classified down; expected up
vertical-7 A and B were classified as the same vertical direction
```

All three flagged pairs involve shallow diagonals where the vertical component is a few pixels of pupil and eyebrow. They read correctly in motion and in the semantic review; the classifier's caution is documented rather than tuned away.

## Semantic review

`qa/direction-semantics.json`. An independent visual pass judged each of the sixteen frames against its expected direction with a one-line reason.

| Verdict | Count | Directions |
|---|---|---|
| pass | **13** | 000, 022.5, 045, 067.5, 090, 135, 180, 202.5, 225, 247.5, 270, 315, 337.5 |
| warning | 3 | 112.5, 157.5, 292.5 (correct axis, "downward/upward displacement subtle", no reversal) |
| fail | 0 | |

Sample reasons: *"090: Pupils unmistakably at screen-right sides."* *"292.5: Clear screen-left axis; upward displacement subtle, but labeled continuous loop has no reversal."*

## Look continuity

`qa/look-continuity.json`. Adjacent look frames around the circle were diffed pixel-wise and their centroids compared, to catch a frame that jumps.

| Metric | Value |
|---|---|
| Median changed pixels between neighbours | **2035.5** |
| Range | 1091 – 5421 |
| Bounding-area ratio between neighbours | 1.001 – 1.079 |
| Flagged outliers | 157.5 → 180 (4701 px vs neighbour average 2940); 337.5 → 000 (5421 px, 8.2 px centre shift) |

The 337.5 → 000 step is the loop seam where the pose returns to "straight up"; it was reviewed and accepted. The report also lists **interior transparent hole rows** for every direction; those are the see-through gaps inside the paperclip's loop and are intentional, recorded so nobody "fixes" them later.

## Chroma cleanup

`qa/chroma-despill-extended.json`. Frames were generated over `#00FF00` and cleaned with an edge-local spill-suppression pass (radius 5, tolerance 0.15, min saturation 0.10, strength 1.0).

| Metric | Value |
|---|---|
| Pixels changed | **226,035** |
| Decontaminated | 210,885 |
| Rejected | 0 |
| Alpha preserved | true |
| Busiest cell | `r5c3` (failed, frame 3): 4,647 px |

Per-cell counts are in the report, so a future recolour can be diffed against the original.

## Reproducing

```sh
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements-dev.txt
make validate                              # the validator
python3 scripts/build-v1-spritesheet.py    # v1 crop with occupancy check
```

The direction/continuity/chroma reports were produced by the asset pipeline whose outputs (frames, row strips, reports) are committed; the images on this page (`qa/contact-sheet.png`, `qa/look-directions.png`, `qa/previews/*.gif`) are the same artifacts. If a number here ever disagrees with a file in `qa/`, the file wins and [this page has a bug](https://github.com/adammatthewsteinberger/clippy-pet/issues/new/choose).

<div class="cp-bubble">It looks like you read a QA page to the end. You'd fit in here. <a href="../../community/contributing/">Contributing</a> is that way.</div>
