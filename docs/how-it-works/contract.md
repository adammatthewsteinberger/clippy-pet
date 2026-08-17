---
title: The pet contract
description: "The Codex pet contract Clippy Pet implements: pet.json fields, the 1536×2288 v2 atlas with 8×11 cells of 192×208, v1 versus v2, and where pets are stored."
---

# The pet contract

<div class="cp-bubble">It looks like you're reading a spec. This one fits on a napkin.</div>

Pets in the ChatGPT desktop app and Codex CLI are described by a small manifest plus a spritesheet. Clippy Pet implements the **v2** contract; here's what that means concretely.

## `pet.json`

```json
{
  "id": "clippy-pet",
  "displayName": "Clippy Pet",
  "description": "A nostalgic animated paperclip assistant with expressive old-school desktop-helper energy.",
  "spriteVersionNumber": 2,
  "spritesheetPath": "spritesheet.webp"
}
```

| Field | Meaning |
|---|---|
| `id` | Directory name and the value you pass to `/pets` or `[tui].pet`. Lowercase, hyphenated. |
| `displayName` | What the picker shows. |
| `description` | One line, shown in the picker. |
| `spriteVersionNumber` | `2` here. Determines the atlas layout the host expects. |
| `spritesheetPath` | Relative to `pet.json`; must not be absolute or contain `..`. |

## The v2 atlas

| Property | Value |
|---|---|
| Image | WebP, RGBA (alpha required), **1536 × 2288 px** |
| Grid | **8 columns × 11 rows**, cells of **192 × 208 px** |
| Rows 0–8 | Animation states, left to right: `idle`, `running-right`, `running-left`, `waving`, `jumping`, `failed`, `waiting`, `running`, `review` |
| Rows 9–10 | Look directions: 000, 022.5, 045, 067.5, 090, 112.5, 135, 157.5 (row 9) and 180, 202.5, 225, 247.5, 270, 292.5, 315, 337.5 (row 10), clockwise from up |
| Frames | Left-aligned in each row; unused cells fully transparent |

Clippy Pet's occupancy, which the validator enforces cell by cell:

| Row | State | Populated cells |
|---|---|---|
| 0 | idle | 7 (6 frames + neutral) |
| 1 | running-right | 8 |
| 2 | running-left | 8 |
| 3 | waving | 4 |
| 4 | jumping | 5 |
| 5 | failed | 8 |
| 6 | waiting | 6 |
| 7 | running | 6 |
| 8 | review | 6 |
| 9 | look 000–157.5 | 8 |
| 10 | look 180–337.5 | 8 |

## v1 versus v2

| | v1 | v2 |
|---|---|---|
| Size | 1536 × 1872 | 1536 × 2288 |
| Rows | 9 (animations only) | 11 (animations + 2 look rows) |
| Pointer tracking | no | yes |
| Where accepted | ChatGPT web upload (≤ 20 MiB) | ChatGPT desktop app, Codex CLI |

Because v1 is a strict prefix of v2, a v1 sheet is a lossless crop of the top 1872 px of the v2 atlas. [`scripts/build-v1-spritesheet.py`](https://github.com/adammatthewsteinberger/clippy-pet/blob/main/scripts/build-v1-spritesheet.py) does exactly that (and re-checks occupancy), and the result ships as `spritesheet-v1.webp` on each release for people who use ChatGPT on the web.

## Where pets live

```text
${CODEX_HOME:-$HOME/.codex}/pets/<id>/pet.json
${CODEX_HOME:-$HOME/.codex}/pets/<id>/spritesheet.webp
```

The directory is per user; there is no system-wide pets directory. That single fact shapes every installer on this site: system packages ship the payload under `<prefix>/share/clippy-pet/` and a CLI copies it into your home. Hosts scan the directory at launch, which is why "reload the app" is step one in [troubleshooting](../get-started/troubleshooting.md).

## Things the contract doesn't specify (and Clippy Pet's choices)

- **Frame timing** is the host's; author loops so any reasonable rate looks fine.
- **Neutral idle cell**: Clippy Pet uses cell 6 of row 0 as a hold pose.
- **Baseline**: keep the character's bottom edge consistent across rows so state switches don't hop.
- **Lighting**: don't mirror pixels for left/right; mirror poses and keep the highlight side.

More in [design notes](../meet/design.md). If you're building a pet from scratch, [Make your own](../make/index.md) walks through it.
