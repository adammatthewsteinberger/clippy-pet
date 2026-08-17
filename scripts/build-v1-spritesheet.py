#!/usr/bin/env python3
"""Build the v1 (9-row, 1536x1872) spritesheet from the v2 atlas.

The v2 contract adds two look-direction rows (rows 9 and 10) below the nine
standard animation rows. The older v1 contract is exactly those nine rows, so a
v1 sheet is a lossless crop of the top 1872 pixels. ChatGPT's web pet upload
currently accepts v1 sheets only, which is what this build is for; the
ChatGPT desktop app and Codex CLI use the v2 sheet installed by `clippy-pet`.

Usage: build-v1-spritesheet.py [OUTPUT]   (default: dist/spritesheet-v1.webp)
"""

import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
V1_SIZE = (1536, 1872)
V1_ROWS = 9
CELL = (192, 208)
EXPECTED_USED = [7, 8, 8, 4, 5, 8, 6, 6, 6]


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "dist" / "spritesheet-v1.webp"
    src = ROOT / "spritesheet.webp"
    with Image.open(src) as opened:
        if opened.size != (1536, 2288):
            fail(f"expected a 1536x2288 v2 atlas, found {opened.width}x{opened.height}")
        sheet = opened.convert("RGBA")
    v1 = sheet.crop((0, 0, V1_SIZE[0], V1_SIZE[1]))
    if v1.size != V1_SIZE:
        fail(f"crop produced {v1.size}, expected {V1_SIZE}")
    alpha = v1.getchannel("A")
    for row, used in enumerate(EXPECTED_USED):
        for column in range(8):
            box = (column * CELL[0], row * CELL[1], (column + 1) * CELL[0], (row + 1) * CELL[1])
            populated = alpha.crop(box).getbbox() is not None
            if populated != (column < used):
                fail(f"unexpected cell occupancy at row {row}, column {column}")
    out.parent.mkdir(parents=True, exist_ok=True)
    v1.save(out, format="WEBP", lossless=True, quality=100, method=6)
    size = out.stat().st_size
    if size > 20 * 1024 * 1024:
        fail(f"{out} is {size} bytes; the web upload limit is 20 MiB")
    print(f"ok: wrote {out} ({V1_SIZE[0]}x{V1_SIZE[1]}, {V1_ROWS} rows, {size} bytes)")


if __name__ == "__main__":
    main()
