#!/usr/bin/env python3
"""Render spritesheet cells at small on-screen sizes to judge legibility.

Terminals and compact layouts can draw a pet at 32-64 px tall, so the
192x208 cells are downscaled about 3-6x. Use this to check whether a cue
(pupils, eyebrows, a waving arm) survives before proposing art changes.

Each output tile shows the cell at the requested heights over a light and a
dark background, then enlarges the whole sheet with nearest-neighbour
scaling so the individual pixels stay visible.

Usage:
  python3 scripts/preview-at-size.py OUT.png [--atlas spritesheet.webp]
        [--cells ROW:COL ...] [--heights 32 64] [--zoom 4]

With no --cells it shows the first frame of every row. Needs only Pillow.
"""
from __future__ import annotations

import argparse

from PIL import Image, ImageDraw

CELL_W, CELL_H = 192, 208
ROW_NAMES = ["idle", "running-right", "running-left", "waving", "jumping", "failed",
             "waiting", "running", "review", "look 000-157.5", "look 180-337.5"]
BACKGROUNDS = [(245, 245, 245), (30, 30, 34)]  # light and dark terminal themes


def tile(atlas: Image.Image, row: int, col: int, heights: list[int]) -> Image.Image:
    cell = atlas.crop((col * CELL_W, row * CELL_H, (col + 1) * CELL_W, (row + 1) * CELL_H))
    widths = [round(h * CELL_W / CELL_H) for h in heights]
    out = Image.new("RGB", (sum(widths) * len(BACKGROUNDS) + 2 * len(widths) * len(BACKGROUNDS), max(heights)), "white")
    x = 0
    for bg in BACKGROUNDS:
        for h, w in zip(heights, widths):
            small = cell.resize((w, h), Image.LANCZOS)
            base = Image.new("RGBA", small.size, bg + (255,))
            base.alpha_composite(small)
            out.paste(base.convert("RGB"), (x, max(heights) - h))
            x += w + 2
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("out")
    parser.add_argument("--atlas", default="spritesheet.webp")
    parser.add_argument("--cells", nargs="*", help="ROW:COL pairs, 0-based")
    parser.add_argument("--heights", nargs="*", type=int, default=[32, 64])
    parser.add_argument("--zoom", type=int, default=4)
    args = parser.parse_args()

    atlas = Image.open(args.atlas).convert("RGBA")
    cells = [tuple(map(int, c.split(":"))) for c in args.cells] if args.cells else [(r, 0) for r in range(11)]
    tiles = [(r, c, tile(atlas, r, c, args.heights)) for r, c in cells]
    label_h = 12
    width = max(t.width for _, _, t in tiles)
    sheet = Image.new("RGB", (width, sum(t.height + label_h for _, _, t in tiles)), "white")
    y = 0
    for r, c, t in tiles:
        ImageDraw.Draw(sheet).text((0, y), f"{ROW_NAMES[r]} [{r}:{c}]", fill=(0, 0, 0))
        sheet.paste(t, (0, y + label_h))
        y += t.height + label_h
    sheet.resize((sheet.width * args.zoom, sheet.height * args.zoom), Image.NEAREST).save(args.out)
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
