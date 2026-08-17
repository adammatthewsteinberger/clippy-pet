#!/usr/bin/env python3
"""Validate the portable Clippy Pet manifest and v2 spritesheet contract."""

import json
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent

def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)

def main() -> None:
    try:
        metadata = json.loads((ROOT / "pet.json").read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"cannot read pet.json: {exc}")
    required = {"id", "displayName", "description", "spriteVersionNumber", "spritesheetPath"}
    missing = sorted(required - metadata.keys())
    if missing:
        fail(f"pet.json is missing: {', '.join(missing)}")
    if metadata["spriteVersionNumber"] != 2:
        fail("spriteVersionNumber must be 2")
    relative = Path(metadata["spritesheetPath"])
    if relative.is_absolute() or ".." in relative.parts:
        fail("spritesheetPath must be safe and repository-relative")
    path = ROOT / relative
    if not path.is_file():
        fail(f"spritesheet does not exist: {relative}")
    with Image.open(path) as opened:
        if opened.size != (1536, 2288):
            fail(f"spritesheet must be 1536x2288; found {opened.width}x{opened.height}")
        if "A" not in opened.getbands():
            fail("spritesheet must include an alpha channel")
        alpha = opened.convert("RGBA").getchannel("A")
    if alpha.getbbox() is None:
        fail("spritesheet is entirely transparent")
    # Idle includes six animation frames plus the neutral/default slot.
    expected_used = [7, 8, 8, 4, 5, 8, 6, 6, 6, 8, 8]
    for row, used_count in enumerate(expected_used):
        for column in range(8):
            box = (column * 192, row * 208, (column + 1) * 192, (row + 1) * 208)
            populated = alpha.crop(box).getbbox() is not None
            if populated != (column < used_count):
                fail(f"unexpected cell occupancy at row {row}, column {column}")
    print("ok: Clippy Pet manifest and v2 spritesheet contract are valid")

if __name__ == "__main__":
    main()
