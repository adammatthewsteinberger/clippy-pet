---
title: Make your own pet
description: "How to remix Clippy Pet or build a brand-new pet for the ChatGPT desktop app and Codex CLI: frames, atlas assembly, validation, and sharing."
---

# Make your own pet

<div class="cp-bubble">It looks like you want a pet that isn't a paperclip. Rude, but fair. Here's how.</div>

Everything you need to make a pet is in this repository, and none of it is secret. There are two routes:

## Route A: remix Clippy Pet

The normalized per-state frames live in `source/frames/<state>/NN.png` (MIT-licensed; the unofficial notice covers the likeness). Recolour, re-shade, swap the eyes, add a hat. Then reassemble:

1. Keep every frame **192 × 208** with a transparent background and the character's baseline where it is.
2. Lay frames left-to-right into rows in this order: `idle`, `running-right`, `running-left`, `waving`, `jumping`, `failed`, `waiting`, `running`, `review`, then the two look rows (see the [contract](../how-it-works/contract.md)).
3. Export a lossless RGBA WebP at 1536 × 2288.
4. Update `pet.json`: new `id` (lowercase, hyphens), `displayName`, `description`.
5. Run the validator; if you changed frame counts, adjust `expected_used` in `scripts/validate.py` to match your rows.
6. Drop the two files in `~/.codex/pets/<your-id>/`, reload, admire.

??? example "Assemble an atlas with Pillow (Python)"

    ```python
    from pathlib import Path
    from PIL import Image

    ROWS = ["idle", "running-right", "running-left", "waving", "jumping",
            "failed", "waiting", "running", "review", "look-a", "look-b"]
    W, H, COLS = 192, 208, 8
    atlas = Image.new("RGBA", (W * COLS, H * len(ROWS)), (0, 0, 0, 0))
    for r, state in enumerate(ROWS):
        for c, frame in enumerate(sorted(Path(f"frames/{state}").glob("*.png"))[:COLS]):
            atlas.alpha_composite(Image.open(frame).convert("RGBA"), (c * W, r * H))
    atlas.save("spritesheet.webp", lossless=True, quality=100, method=6)
    ```

## Route B: hatch something new

Start from the [contract](../how-it-works/contract.md) and the [design notes](../meet/design.md). The advice that mattered most for Clippy Pet, in order:

1. **Design the silhouette at 64 px first.** If it doesn't read in flat black at that size, no amount of shading will save it.
2. **Put the expression in the eyes.** They're the only feature guaranteed to survive downscaling.
3. **Author loops, not clips.** Last frame flows into first; the host chooses timing.
4. **Mirror poses, not pixels** for left/right so the light doesn't flip.
5. **Do the look directions last, and test them blind.** Shuffle the sixteen frames, hide the labels, and ask someone which way each looks. Ours got 13/16 clean on the first honest pass and we published the three warnings.
6. **Ship the receipts.** A contact sheet and a validator make your pet reviewable, and reviewable pets get shared.

OpenAI documents the pets feature and its file format on the [ChatGPT help site](https://learn.chatgpt.com/docs/pets); if their contract changes, that page wins over anything here.

## Reuse the packaging, too

Because Clippy Pet's installers are payload-agnostic, you can fork the repo, replace `pet.json`/`spritesheet.webp`, change the name in `VERSION`, `pet.json`, `packaging/linux/nfpm.yaml`, and `packaging/bin/clippy-pet` (`PET_ID`), and inherit the one-line installer, the `.deb`/`.rpm`/`.apk`/Arch builds, the macOS `.dmg`, checksums, signatures, and this documentation site. The [packaging runbook](../project/packaging.md) is the map.

## Show it off

Made something? Post it in [Show and tell](../community/show-and-tell.md) with a GIF. If it's a Clippy Pet variant you'd like merged, read [Submit a variant](submit.md).

[Submit a variant :material-arrow-right:](submit.md){ .md-button .md-button--primary }
