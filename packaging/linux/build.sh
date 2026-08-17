#!/bin/sh
# Build .deb, .rpm, .apk, and .pkg.tar.zst packages with nfpm.
# Usage: packaging/linux/build.sh [output-dir]
set -eu

# shellcheck disable=SC1007
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
VERSION=$(cat "$ROOT/VERSION")
OUT="${1:-$ROOT/dist}"
STAGE="$ROOT/.build/linux-stage"

command -v nfpm >/dev/null 2>&1 || { echo "error: nfpm is required (https://nfpm.goreleaser.com)" >&2; exit 1; }

rm -rf "$STAGE"
mkdir -p "$STAGE/usr/bin" "$STAGE/usr/share/clippy-pet" "$STAGE/usr/share/man/man1" \
    "$STAGE/usr/share/applications" "$STAGE/usr/share/metainfo" \
    "$STAGE/usr/share/icons/hicolor/256x256/apps" "$STAGE/usr/share/doc/clippy-pet" \
    "$STAGE/usr/share/licenses/clippy-pet" "$STAGE/etc/xdg/autostart" "$OUT"

sed \
    -e "s/@VERSION@/$VERSION/" \
    -e "s#@DATADIR@#/usr/share/clippy-pet#" \
    "$ROOT/packaging/bin/clippy-pet" > "$STAGE/usr/bin/clippy-pet"
chmod 755 "$STAGE/usr/bin/clippy-pet"

cp "$ROOT/pet.json" "$STAGE/usr/share/clippy-pet/pet.json"
cp "$ROOT/spritesheet.webp" "$STAGE/usr/share/clippy-pet/spritesheet.webp"
gzip -9n -c "$ROOT/packaging/share/man/man1/clippy-pet.1" > "$STAGE/usr/share/man/man1/clippy-pet.1.gz"
cp "$ROOT/packaging/share/applications/io.github.adammatthewsteinberger.clippy_pet.desktop" \
    "$STAGE/usr/share/applications/"
cp "$ROOT/packaging/share/metainfo/io.github.adammatthewsteinberger.clippy_pet.metainfo.xml" \
    "$STAGE/usr/share/metainfo/"
cp "$ROOT/packaging/share/icons/hicolor/256x256/apps/io.github.adammatthewsteinberger.clippy_pet.png" \
    "$STAGE/usr/share/icons/hicolor/256x256/apps/"
cp "$ROOT/packaging/share/autostart/io.github.adammatthewsteinberger.clippy_pet.desktop" \
    "$STAGE/etc/xdg/autostart/"
cp "$ROOT/packaging/linux/debian-copyright" "$STAGE/usr/share/doc/clippy-pet/copyright"
gzip -9n -c "$ROOT/packaging/linux/debian-changelog" > "$STAGE/usr/share/doc/clippy-pet/changelog.gz"
cp "$ROOT/LICENSE" "$STAGE/usr/share/licenses/clippy-pet/LICENSE"

export CLIPPY_PET_VERSION="$VERSION"
export CLIPPY_PET_STAGE="$STAGE"
export CLIPPY_PET_REPO="$ROOT"

for packager in deb rpm apk archlinux; do
    echo "Building $packager..."
    (
        cd "$ROOT/packaging/linux"
        nfpm package \
            --config nfpm.yaml \
            --packager "$packager" \
            --target "$OUT/"
    )
done

rm -rf "$ROOT/.build"
echo "Built:"
ls -la "$OUT"
