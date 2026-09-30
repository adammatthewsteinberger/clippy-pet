#!/usr/bin/env python3
"""Prototype a "tiny" (32 px) test frame from one Clippy Pet cell (issue #33).

This is a design probe, not a finished variant. It takes one 192x208 cell and
applies the changes a small-size variant would need, so the idea can be
judged on a real frame before anyone redraws 83 of them:

  * thicker wire: the silhouette grows by a few pixels, filled from the
    nearest existing wire colour, so strokes survive a ~6x downscale;
  * larger pupils: each pupil is scaled up about its centre (clipped to its
    eye), because a 12 px pupil becomes a 2 px dot at 32 px;
  * bolder eyebrows with a light halo: at small sizes on a dark terminal the
    near-black eyebrows vanish entirely, so they get thicker and a thin
    light edge that separates them from dark backgrounds;
  * a dark outline, so the light silhouette holds on light backgrounds.

The output keeps the v2 cell geometry (192x208, alpha), which is what the
contract allows: the host app scales the atlas; cells cannot be smaller.

Needs numpy and scipy:  python3 -m pip install numpy scipy pillow
Usage:  python3 scripts/prototype-tiny-frame.py OUT.png [--atlas spritesheet.webp] [--cell ROW:COL]
"""
from __future__ import annotations

import argparse

import numpy as np
from PIL import Image
from scipy import ndimage as ndi

CELL_W, CELL_H = 192, 208
WIRE_GROW = 2        # px added around the silhouette
PUPIL_SCALE = 1.35   # pupil enlargement about its centre
BROW_GROW = 2        # px added to each eyebrow
BROW_HALO = 1        # light edge around eyebrows, in px
OUTLINE = 1          # dark outline width, in px
OUTLINE_RGB = (40, 40, 56)
HALO_RGB = (236, 236, 244)


def prototype(cell: np.ndarray) -> np.ndarray:
    rgb = cell[..., :3].astype(np.float64)
    alpha = cell[..., 3].astype(np.float64)
    lum = rgb.mean(axis=2)
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    solid = alpha > 128
    dark = solid & (lum < 90)
    white = solid & (lum > 215) & (sat < 30)
    white[130:] = False

    # Eyes and pupils (one pupil per eye: the largest dark blob touching it).
    wl, wn = ndi.label(white)
    eyes = np.argsort(ndi.sum(white, wl, range(1, wn + 1)))[-2:] + 1
    dl, _ = ndi.label(dark)
    pupil = np.zeros_like(solid)
    eye_mask = np.zeros_like(solid)
    for e in eyes:
        ew = wl == e
        touching = set(np.unique(dl[ndi.binary_dilation(ew, iterations=2) & dark])) - {0}
        if touching:
            best = max(touching, key=lambda b: int((dl == b).sum()))
            pupil |= dl == best
        eye_mask |= ndi.binary_fill_holes(ndi.binary_dilation(ew | pupil, iterations=3)) & solid
    brows = dark & ~pupil
    brows[140:] = False  # dark pixels low in the cell are shading, not brows

    out_rgb, out_a = rgb.copy(), alpha.copy()

    # 1. Thicker wire: grow the silhouette, filling from the nearest opaque pixel.
    grown = ndi.binary_dilation(solid, iterations=WIRE_GROW)
    _, (iy, ix) = ndi.distance_transform_edt(~solid, return_indices=True)
    new = grown & ~solid
    out_rgb[new] = rgb[iy[new], ix[new]]
    out_a[new] = 255

    # 2. Larger pupils, scaled about each pupil's centre and clipped to its eye.
    pl, pn = ndi.label(pupil)
    for p in range(1, pn + 1):
        ys, xs = np.nonzero(pl == p)
        cy, cx = ys.mean(), xs.mean()
        yy, xx = np.nonzero(eye_mask)
        sy, sx = cy + (yy - cy) / PUPIL_SCALE, cx + (xx - cx) / PUPIL_SCALE
        syi, sxi = np.rint(sy).astype(int), np.rint(sx).astype(int)
        ok = (syi >= 0) & (syi < CELL_H) & (sxi >= 0) & (sxi < CELL_W)
        hit = np.zeros_like(ok)
        hit[ok] = pl[syi[ok], sxi[ok]] == p
        out_rgb[yy[hit], xx[hit]] = rgb[syi[hit], sxi[hit]]

    # 3. Bolder eyebrows with a light halo (halo first, so the brow sits on top).
    bold = ndi.binary_dilation(brows, iterations=BROW_GROW)
    halo = ndi.binary_dilation(bold, iterations=BROW_HALO) & ~bold & ~eye_mask
    out_rgb[halo] = HALO_RGB
    out_a[halo] = 255
    out_rgb[bold] = (20, 20, 24)
    out_a[bold] = 255

    # 4. Dark outline around the whole silhouette.
    body = out_a > 128
    ring = ndi.binary_dilation(body, iterations=OUTLINE) & ~body
    out_rgb[ring] = OUTLINE_RGB
    out_a[ring] = 255

    return np.dstack([np.clip(out_rgb, 0, 255), out_a]).astype(np.uint8)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("out")
    parser.add_argument("--atlas", default="spritesheet.webp")
    parser.add_argument("--cell", default="0:6", help="ROW:COL, 0-based (default: the neutral idle cell)")
    args = parser.parse_args()
    row, col = map(int, args.cell.split(":"))
    atlas = np.array(Image.open(args.atlas).convert("RGBA"))
    cell = atlas[row * CELL_H:(row + 1) * CELL_H, col * CELL_W:(col + 1) * CELL_W]
    Image.fromarray(prototype(cell), "RGBA").save(args.out)
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
