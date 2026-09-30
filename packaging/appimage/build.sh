#!/bin/sh
# Build Clippy Pet AppImages (x86_64 and aarch64) into dist/.
# Usage: packaging/appimage/build.sh [output-dir]
#
# The payload is architecture-independent (two data files and a POSIX sh
# CLI), so one AppDir is packed once per architecture with that
# architecture's AppImage runtime. appimagetool and both runtimes are pinned
# to exact upstream releases and verified by SHA-256 before use.
#
# Runs on Linux x86_64 or aarch64. Needs curl and sha256sum. FUSE is not
# required: appimagetool is run with APPIMAGE_EXTRACT_AND_RUN=1.
set -eu

# shellcheck disable=SC1007
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
VERSION=$(cat "$ROOT/VERSION")
OUT="${1:-$ROOT/dist}"
WORK="$ROOT/.build/appimage"
APPID=io.github.adammatthewsteinberger.clippy_pet

# Pinned toolchain. To update: bump the tag, download the assets, and replace
# the hashes with `sha256sum` output. Never point these at "continuous".
APPIMAGETOOL_TAG=1.9.1
RUNTIME_TAG=20251108

appimagetool_sha256() {
    case $1 in
        x86_64) echo ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0 ;;
        aarch64) echo f0837e7448a0c1e4e650a93bb3e85802546e60654ef287576f46c71c126a9158 ;;
    esac
}

runtime_sha256() {
    case $1 in
        x86_64) echo 2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d ;;
        aarch64) echo 00cbdfcf917cc6c0ff6d3347d59e0ca1f7f45a6df1a428a0d6d8a78664d87444 ;;
    esac
}

need() {
    command -v "$1" >/dev/null 2>&1 || { echo "error: $1 is required" >&2; exit 1; }
}
need curl
need sha256sum

fetch_verified() {
    # fetch_verified URL DEST SHA256
    curl -fsSL -o "$2" "$1"
    printf '%s  %s\n' "$3" "$2" | sha256sum -c --quiet - || {
        echo "error: checksum mismatch for $1" >&2
        exit 1
    }
}

host=$(uname -m)
case $host in
    x86_64|amd64) host=x86_64 ;;
    aarch64|arm64) host=aarch64 ;;
    *) echo "error: unsupported build host architecture: $host" >&2; exit 1 ;;
esac

rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"

fetch_verified \
    "https://github.com/AppImage/appimagetool/releases/download/$APPIMAGETOOL_TAG/appimagetool-$host.AppImage" \
    "$WORK/appimagetool" "$(appimagetool_sha256 "$host")"
chmod 755 "$WORK/appimagetool"

# --- the AppDir (shared by every architecture) ---------------------------
APPDIR="$WORK/AppDir"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/share/clippy-pet" "$APPDIR/usr/share/metainfo" \
    "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/256x256/apps"

# @DATADIR@ is deliberately left unresolved: the mount point changes on every
# run, so AppRun exports CLIPPY_PET_DATA instead (and the CLI also probes
# $APPDIR/usr/share/clippy-pet on its own).
sed -e "s/@VERSION@/$VERSION/" \
    "$ROOT/packaging/bin/clippy-pet" > "$APPDIR/usr/bin/clippy-pet"
chmod 755 "$APPDIR/usr/bin/clippy-pet"
cp "$ROOT/packaging/appimage/AppRun" "$APPDIR/AppRun"
chmod 755 "$APPDIR/AppRun"

cp "$ROOT/pet.json" "$ROOT/spritesheet.webp" "$APPDIR/usr/share/clippy-pet/"
cp "$ROOT/LICENSE" "$ROOT/NOTICE.md" "$APPDIR/usr/share/clippy-pet/"
cp "$ROOT/packaging/share/metainfo/$APPID.metainfo.xml" "$APPDIR/usr/share/metainfo/"
cp "$ROOT/packaging/share/applications/$APPID.desktop" "$APPDIR/usr/share/applications/"
cp "$ROOT/packaging/share/applications/$APPID.desktop" "$APPDIR/$APPID.desktop"
cp "$ROOT/packaging/share/icons/hicolor/256x256/apps/$APPID.png" \
    "$APPDIR/usr/share/icons/hicolor/256x256/apps/"
cp "$ROOT/packaging/share/icons/hicolor/256x256/apps/$APPID.png" "$APPDIR/$APPID.png"
ln -sf "$APPID.png" "$APPDIR/.DirIcon"

# --- pack once per architecture ------------------------------------------
for arch in x86_64 aarch64; do
    fetch_verified \
        "https://github.com/AppImage/type2-runtime/releases/download/$RUNTIME_TAG/runtime-$arch" \
        "$WORK/runtime-$arch" "$(runtime_sha256 "$arch")"
    target="$OUT/clippy-pet-$VERSION-$arch.AppImage"
    echo "Building $(basename "$target")..."
    # --no-appstream: the metainfo is validated by packaging-ci's lint job;
    # appimagetool's own check would need network access to fetch a schema.
    ARCH=$arch APPIMAGE_EXTRACT_AND_RUN=1 SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-0} \
        "$WORK/appimagetool" --no-appstream --runtime-file "$WORK/runtime-$arch" \
        "$APPDIR" "$target"
    chmod 755 "$target"
done

rm -rf "$WORK"
echo "Built:"
ls -la "$OUT"/*.AppImage
