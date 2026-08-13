# Contributing

Thanks for helping improve Clipster.

## Setup

Python 3.10 or newer is recommended.

```sh
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install -r requirements-dev.txt
python3 scripts/validate.py
```

## Pull requests

1. Search existing issues and open one before a large compatibility or visual change.
2. Keep the change focused and explain its user impact.
3. Include before/after media for visual changes.
4. Preserve v2 geometry: 1536 by 2288 pixels, eight columns, eleven rows, and 192-by-208-pixel cells.
5. Preserve transparency, unused cells, and `spriteVersionNumber: 2`.
6. Update `CHANGELOG.md` for user-visible changes.
7. Run `make validate` and report the result.
8. Do not add personal data, credentials, local absolute paths, cache IDs, or assets you cannot license.

By submitting a contribution, you certify that you have the right to provide it under the MIT License. See `NOTICE.md` for limitations concerning third-party rights and trademarks.
