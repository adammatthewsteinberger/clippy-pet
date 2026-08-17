#!/bin/sh
# Build reproducible clippy-pet-<version> runtime tarballs (.tar.gz/.tgz/
# .tar.bz2/.tar.xz) and a .zip for the release. Run from the repository root.
set -eu

# shellcheck disable=SC1007
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
VERSION=$(cat "$ROOT/VERSION")
OUT="${1:-$ROOT/dist}"
STAGE_NAME="clippy-pet-$VERSION"
STAGE="$ROOT/.build/$STAGE_NAME"

command -v tar >/dev/null 2>&1 || { echo "error: tar is required" >&2; exit 1; }

# Reproducible timestamp: prefer the release tag's commit date, fall back to
# the current HEAD, then to the current time if this isn't a git checkout.
SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-}
if [ -z "$SOURCE_DATE_EPOCH" ] && command -v git >/dev/null 2>&1 && [ -d "$ROOT/.git" ]; then
    SOURCE_DATE_EPOCH=$(git -C "$ROOT" log -1 --format=%ct 2>/dev/null || true)
fi
SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-$(date +%s)}
export SOURCE_DATE_EPOCH

rm -rf "$STAGE" "$OUT"
mkdir -p "$STAGE/bin" "$STAGE/share/man/man1" "$STAGE/share/applications" \
    "$STAGE/share/metainfo" "$STAGE/share/icons/hicolor/256x256/apps" "$OUT"

# CLI, with the @VERSION@ / @DATADIR@ placeholders resolved for a
# self-contained, relocatable tarball (CLIPPY_PET_DATA / bundled-relative
# lookup both still work; the baked default just makes `path`/`version`
# correct without extra setup).
sed \
    -e "s/@VERSION@/$VERSION/" \
    -e "s#@DATADIR@#\$(cd \"\$(dirname \"\$0\")/../share/clippy-pet\" 2>/dev/null \&\& pwd)#" \
    "$ROOT/packaging/bin/clippy-pet" > "$STAGE/bin/clippy-pet"
chmod 755 "$STAGE/bin/clippy-pet"

mkdir -p "$STAGE/share/clippy-pet"
cp "$ROOT/pet.json" "$STAGE/share/clippy-pet/pet.json"
cp "$ROOT/spritesheet.webp" "$STAGE/share/clippy-pet/spritesheet.webp"

gzip -9n -c "$ROOT/packaging/share/man/man1/clippy-pet.1" > "$STAGE/share/man/man1/clippy-pet.1.gz"

for extra in \
    "share/applications/io.github.adammatthewsteinberger.clippy_pet.desktop" \
    "share/metainfo/io.github.adammatthewsteinberger.clippy_pet.metainfo.xml" \
    "share/icons/hicolor/256x256/apps/io.github.adammatthewsteinberger.clippy_pet.png"; do
    if [ -f "$ROOT/packaging/$extra" ]; then
        cp "$ROOT/packaging/$extra" "$STAGE/$extra"
    fi
done

cp "$ROOT/LICENSE" "$STAGE/LICENSE"
cp "$ROOT/NOTICE.md" "$STAGE/NOTICE.md"
cp "$ROOT/scripts/install.sh" "$STAGE/install.sh"
chmod 755 "$STAGE/install.sh"

# Deterministic ownership/order for reproducible archives.
TAR_REPRO_ARGS="--sort=name --mtime=@$SOURCE_DATE_EPOCH --owner=0 --group=0 --numeric-owner"
# shellcheck disable=SC2086
if ! tar $TAR_REPRO_ARGS -cf /dev/null -T /dev/null 2>/dev/null; then
    # BSD tar (macOS) doesn't support these flags; fall back to plain tar.
    TAR_REPRO_ARGS=""
fi

(
    cd "$ROOT/.build"
    # shellcheck disable=SC2086
    tar $TAR_REPRO_ARGS -cf - "$STAGE_NAME" | gzip -9n > "$OUT/$STAGE_NAME.tar.gz"
    cp "$OUT/$STAGE_NAME.tar.gz" "$OUT/$STAGE_NAME.tgz"
    # shellcheck disable=SC2086
    tar $TAR_REPRO_ARGS -cf - "$STAGE_NAME" | bzip2 -9 > "$OUT/$STAGE_NAME.tar.bz2"
    if command -v xz >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        tar $TAR_REPRO_ARGS -cf - "$STAGE_NAME" | xz -9e > "$OUT/$STAGE_NAME.tar.xz"
    fi
    if command -v zip >/dev/null 2>&1; then
        zip -q -X -r "$OUT/$STAGE_NAME.zip" "$STAGE_NAME"
    fi
)

rm -rf "$ROOT/.build"

echo "Built:"
ls -la "$OUT"
