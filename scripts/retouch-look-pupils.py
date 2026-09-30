#!/usr/bin/env python3
"""Nudge the pupils in four look-direction cells of spritesheet.webp (issue #29).

The look rows (atlas rows 9 and 10, 000° to 337.5° clockwise from "up") have
no per-frame source files: the row strips in source/row-strips/ are raw
generator output from before downscaling and chroma cleanup. This script
therefore edits the atlas cells directly, and only inside the two eyes.

Blind direction QA (qa/direction-blind-validation.json) flagged the shallow
diagonals 112.5°, 157.5°, 202.5° and 292.5°. Compared with their neighbours,
each one's minor-axis cue was missing or pointed the wrong way:

  112.5° sat higher than 90°        -> pupils down 4 px
  157.5° was nearly bottom-centre   -> pupils right 3 px
  202.5° matched 180°               -> pupils left 4 px
  292.5° was level with 270°        -> pupils up 4 px (still below 315°)

4 px at full size is ~1.3 px at 64 px: the smallest move that survives
downscaling without breaking the sequence. The shifts were chosen by eye
against each frame's neighbours, not computed. Automatic eye-centre finding
proved unreliable on these shaded, sphere-like eyes.

For each eye the script paints the pupil out (filling from the surrounding
eye-white and shaded rim), then paints the same pupil back in at the shifted
position, clipped to the eye. Alpha is never changed, only colour, and
nothing outside the eyes changes.

Each cell is guarded by SHA-256: the script edits a cell only if it is the
original, skips it if it already matches the result, and refuses anything
else. Re-running it is therefore a no-op, and it never edits art it wasn't
written for. The atlas is re-saved as lossless WebP with exact colours, so
every other pixel stays byte-identical.

Needs numpy and scipy (not in requirements-dev.txt, which the validator and
CI use):  python3 -m pip install numpy scipy pillow
Usage:    python3 scripts/retouch-look-pupils.py [--atlas spritesheet.webp] [--dry-run]
Afterwards run `make validate` and `make checksums`.
"""
from __future__ import annotations

import argparse
import hashlib
import sys

import numpy as np
from PIL import Image
from scipy import ndimage as ndi

CELL_W, CELL_H = 192, 208

# direction (degrees) -> pupil shift in full-size pixels (dx right+, dy down+), both eyes
SHIFTS: dict[float, tuple[int, int]] = {
    112.5: (0, +4),
    157.5: (+3, 0),
    202.5: (-4, 0),
    292.5: (0, -4),
}

# SHA-256 of each cell's raw RGBA bytes: (original, after this script).
CELL_SHA256: dict[float, tuple[str, str]] = {
    112.5: (
        "76722ca227398f2533e78e09e4e911374f7b3d640694f57129bdd3966495bbb5",
        "f96a0a4feb590dfc1b1f1ee1aad81ec34150799fc9e47b2752988e7c0fa06aec",
    ),
    157.5: (
        "e59f89598d62fc9705ae023ee0008bdfa2b5f51357e234198a27339fac06915f",
        "056e9e0601e8cea3c835bc52fa73cd1eb4cecc7d277ad261ad357cb5b8b751f3",
    ),
    202.5: (
        "c1e20e3c6df62dafeac1972be2951a4a15f913bec3aefd31b39b20cf942bb7ca",
        "a2ecc01fb76cb452f9614d8d2c4e29da9f2263587e95b6242d583dff653f620e",
    ),
    292.5: (
        "68f72f70463d804c214f394bd7866d417938df525094c321e375d8611fb2d673",
        "a6c1b3010e572f6ce5dceb7652e8370a8e7f53467ca600ec576071536a34772f",
    ),
}


def cell_box(deg: float) -> tuple[int, int, int, int]:
    index = round(deg / 22.5) % 16
    row, col = (9, index) if index < 8 else (10, index - 8)
    return col * CELL_W, row * CELL_H, (col + 1) * CELL_W, (row + 1) * CELL_H


def sha256(cell: np.ndarray) -> str:
    return hashlib.sha256(np.ascontiguousarray(cell, dtype=np.uint8).tobytes()).hexdigest()


def find_eyes(cell: np.ndarray) -> list[dict]:
    """The two eyes, screen-left first: pupil mask and eye mask (white, pupil and shaded rim)."""
    rgb = cell[..., :3].astype(np.float64)
    alpha = cell[..., 3]
    lum = rgb.mean(axis=2)
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    white = (alpha > 200) & (lum > 215) & (sat < 30)
    dark = (alpha > 128) & (lum < 90)
    white[130:] = False  # the eyes are in the upper part of every look cell
    dark[130:] = False

    labels, count = ndi.label(white)
    sizes = ndi.sum(white, labels, range(1, count + 1))
    dark_labels, _ = ndi.label(dark)
    eyes = []
    for label in np.argsort(sizes)[-2:] + 1:
        eye_white = labels == label
        wy, wx = np.nonzero(eye_white)
        near = ndi.binary_dilation(eye_white, iterations=2) & dark
        candidates = sorted(set(np.unique(dark_labels[near])) - {0})
        if not candidates:
            raise SystemExit("error: could not find a pupil; refusing to guess")
        # Every eye has exactly one pupil. Eyebrows can touch the eye-white
        # too, so take the dark blob nearest the white's centre, not every
        # blob that touches it; ignore specks under 40% of the largest blob.
        areas = {blob: int((dark_labels == blob).sum()) for blob in candidates}
        candidates = [b for b in candidates if areas[b] >= 0.4 * max(areas.values())]

        def distance(blob: int) -> float:
            by, bx = np.nonzero(dark_labels == blob)
            return float(np.hypot(by.mean() - wy.mean(), bx.mean() - wx.mean()))
        pupil = ndi.binary_fill_holes(dark_labels == min(candidates, key=distance))
        # The shaded lower rim is darker than "white", so grow the eye a few
        # pixels into opaque, non-eyebrow pixels to include it.
        eyebrow = dark & ~pupil
        eye = ndi.binary_fill_holes(ndi.binary_dilation(eye_white | pupil, iterations=3)) & (alpha > 200) & ~eyebrow
        eyes.append({"eye": eye, "pupil": pupil, "x": np.nonzero(eye)[1].mean()})
    return sorted(eyes, key=lambda e: e["x"])


def move_pupil(cell: np.ndarray, eye: dict, dx: int, dy: int) -> None:
    """Paint one pupil out and back in at (+dx, +dy), clipped to the eye."""
    inside = eye["eye"]
    lum = cell[..., :3].mean(axis=2)
    # The pupil plus its anti-aliased rim: darker-than-white pixels right around it.
    sprite_mask = eye["pupil"] | (ndi.binary_dilation(eye["pupil"], iterations=2) & inside & (lum < 235))
    original = cell.copy()

    # Paint the pupil out: nearest eye pixel that isn't pupil, then a light blur inside the hole only.
    source = inside & ~sprite_mask
    _, (iy, ix) = ndi.distance_transform_edt(~source, return_indices=True)
    cell[sprite_mask] = original[iy[sprite_mask], ix[sprite_mask]]
    blurred = np.stack([ndi.gaussian_filter(cell[..., ch], 1.2) for ch in range(4)], axis=-1)
    cell[sprite_mask] = blurred[sprite_mask]

    # Paint it back in, shifted, clipped to the eye.
    ys, xs = np.nonzero(sprite_mask)
    ty, tx = ys + dy, xs + dx
    ok = (ty >= 0) & (ty < cell.shape[0]) & (tx >= 0) & (tx < cell.shape[1])
    ys, xs, ty, tx = ys[ok], xs[ok], ty[ok], tx[ok]
    keep = inside[ty, tx]
    ty, tx, ys, xs = ty[keep], tx[keep], ys[keep], xs[keep]
    # "Darken" composite: the pupil's anti-aliased fringe was blended against
    # bright eye-white, so over the shaded rim it would leave a light halo.
    # A pupil is darker than every part of the eye, so keep the darker pixel.
    sprite_px, under_px = original[ys, xs], cell[ty, tx]
    darker = sprite_px[:, :3].mean(axis=1) < under_px[:, :3].mean(axis=1)
    cell[ty[darker], tx[darker]] = sprite_px[darker]

    # A retouch changes colour, never coverage: the eye's silhouette is not
    # moving, so every pixel keeps its original alpha.
    cell[..., 3] = original[..., 3]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--atlas", default="spritesheet.webp")
    parser.add_argument("--dry-run", action="store_true", help="report what would change without writing")
    args = parser.parse_args()

    atlas = np.array(Image.open(args.atlas).convert("RGBA"))
    changed = 0
    for deg, (dx, dy) in SHIFTS.items():
        x0, y0, x1, y1 = cell_box(deg)
        cell = atlas[y0:y1, x0:x1]
        before, after = CELL_SHA256[deg]
        current = sha256(cell)
        if current == after:
            print(f"{deg:6.1f}°  already retouched, skipping")
            continue
        if current != before:
            print(f"error: the {deg}° cell is neither the original nor the retouched art; refusing to edit it", file=sys.stderr)
            return 1
        work = cell.astype(np.float64)
        for eye in find_eyes(cell):
            move_pupil(work, eye, dx, dy)
        result = np.clip(np.rint(work), 0, 255).astype(np.uint8)
        if sha256(result) != after:
            print(f"error: the {deg}° retouch did not reproduce the expected result; refusing to write", file=sys.stderr)
            return 1
        atlas[y0:y1, x0:x1] = result
        changed += 1
        print(f"{deg:6.1f}°  pupils moved by ({dx:+d}, {dy:+d}) px")

    if changed == 0 or args.dry_run:
        print("no changes written" if changed == 0 else "dry run: no changes written")
        return 0
    Image.fromarray(atlas, "RGBA").save(args.atlas, "WEBP", lossless=True, exact=True, quality=100, method=6)
    print(f"wrote {args.atlas}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
