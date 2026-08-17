#!/bin/sh
# Build the macOS installers: Install Clippy Pet.app, Clippy-Pet-<v>.pkg,
# and Clippy-Pet-<v>.dmg. Must run on macOS (uses pkgbuild, productbuild,
# hdiutil, osacompile, PlistBuddy).
#
# Signing/notarization are applied automatically when the relevant
# environment variables are set (see the "Sign & notarize" section below);
# otherwise the artifacts are built unsigned (ad-hoc where required) so
# local builds and forks still work.
set -eu

# Prevent cp/tar from emitting AppleDouble (._*) sidecar files for
# extended attributes like com.apple.provenance.
export COPYFILE_DISABLE=1

# shellcheck disable=SC1007
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
VERSION=$(cat "$ROOT/VERSION")
OUT="${1:-$ROOT/dist}"
BUILD="$ROOT/.build/macos"
APP_ID=io.github.adammatthewsteinberger.clippy_pet

for tool in pkgbuild productbuild hdiutil osacompile /usr/libexec/PlistBuddy; do
    command -v "$tool" >/dev/null 2>&1 || [ -x "$tool" ] || {
        echo "error: required macOS tool not found: $tool (this script must run on macOS)" >&2
        exit 1
    }
done

rm -rf "$BUILD"
mkdir -p "$BUILD" "$OUT"

# ---------------------------------------------------------------------------
# Shared payload (CLI with the app-bundle-relative @DATADIR@ resolved, plus
# pet.json/spritesheet.webp) reused by both the .app and the .pkg.

STAGE="$BUILD/payload"
mkdir -p "$STAGE/bin" "$STAGE/share/clippy-pet"
sed \
    -e "s/@VERSION@/$VERSION/" \
    -e "s#@DATADIR@#/usr/local/share/clippy-pet#" \
    "$ROOT/packaging/bin/clippy-pet" > "$STAGE/bin/clippy-pet"
chmod 755 "$STAGE/bin/clippy-pet"
cp "$ROOT/pet.json" "$STAGE/share/clippy-pet/pet.json"
cp "$ROOT/spritesheet.webp" "$STAGE/share/clippy-pet/spritesheet.webp"

# ---------------------------------------------------------------------------
# 1) "Install Clippy Pet.app" - no admin required, drag-and-drop friendly.

APP_NAME="Install Clippy Pet"
APP="$BUILD/$APP_NAME.app"
osacompile -o "$APP" "$ROOT/packaging/macos/install.applescript"

PLIST="$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $APP_ID.installer" "$PLIST" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $APP_ID.installer" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $VERSION" "$PLIST" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $VERSION" "$PLIST" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleName string $APP_NAME" "$PLIST" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string 11.0" "$PLIST" 2>/dev/null || true
cp "$ROOT/packaging/macos/clippy-pet.icns" "$APP/Contents/Resources/applet.icns"

mkdir -p "$APP/Contents/Resources/bin" "$APP/Contents/Resources/share"
# The app's CLI is invoked with CLIPPY_PET_DATA set explicitly (see
# install.applescript), so @DATADIR@ is left unresolved here and the
# baked-in search path (share/clippy-pet next to bin/) is unused too -
# only VERSION needs substituting.
sed -e "s/@VERSION@/$VERSION/" \
    "$ROOT/packaging/bin/clippy-pet" > "$APP/Contents/Resources/bin/clippy-pet"
chmod 755 "$APP/Contents/Resources/bin/clippy-pet"
cp -R "$STAGE/share/clippy-pet" "$APP/Contents/Resources/share/clippy-pet"

# ---------------------------------------------------------------------------
# 2) Clippy-Pet-<version>.pkg - system-domain install to /usr/local, with a
#    postinstall script that seeds the console user's own Codex home.

PKGROOT="$BUILD/pkgroot"
mkdir -p "$PKGROOT/usr/local/bin" "$PKGROOT/usr/local/share/clippy-pet" \
    "$PKGROOT/usr/local/share/man/man1"
cp "$STAGE/bin/clippy-pet" "$PKGROOT/usr/local/bin/clippy-pet"
cp "$STAGE/share/clippy-pet/pet.json" "$PKGROOT/usr/local/share/clippy-pet/pet.json"
cp "$STAGE/share/clippy-pet/spritesheet.webp" "$PKGROOT/usr/local/share/clippy-pet/spritesheet.webp"
gzip -9n -c "$ROOT/packaging/share/man/man1/clippy-pet.1" > "$PKGROOT/usr/local/share/man/man1/clippy-pet.1.gz"
xattr -cr "$PKGROOT"

SCRIPTS="$BUILD/scripts"
mkdir -p "$SCRIPTS"
cp "$ROOT/packaging/macos/postinstall" "$SCRIPTS/postinstall"
chmod 755 "$SCRIPTS/postinstall"

COMPONENT_PKG="$BUILD/component.pkg"
pkgbuild \
    --root "$PKGROOT" \
    --identifier "$APP_ID.pkg" \
    --version "$VERSION" \
    --install-location / \
    --scripts "$SCRIPTS" \
    "$COMPONENT_PKG"

RESOURCES="$BUILD/resources"
mkdir -p "$RESOURCES"
cp "$ROOT/packaging/macos/resources/welcome.html" "$RESOURCES/"
cp "$ROOT/packaging/macos/resources/conclusion.html" "$RESOURCES/"
{
    printf '%s\n' '<html><body style="font-family: -apple-system, sans-serif; font-size: 12px; white-space: pre-wrap;">'
    cat "$ROOT/LICENSE"
    printf '\n\n'
    cat "$ROOT/NOTICE.md"
    printf '%s\n' '</body></html>'
} > "$RESOURCES/license.html"

DIST_XML="$BUILD/distribution.xml"
sed "s/__VERSION__/$VERSION/" "$ROOT/packaging/macos/distribution.xml" > "$DIST_XML"

PKG_UNSIGNED="$BUILD/Clippy-Pet-$VERSION-unsigned.pkg"
(
    cd "$BUILD"
    productbuild \
        --distribution "$DIST_XML" \
        --resources "$RESOURCES" \
        --package-path "$BUILD" \
        "$PKG_UNSIGNED"
)

# ---------------------------------------------------------------------------
# Sign & notarize (only if credentials are present in the environment).

FINAL_PKG="$OUT/Clippy-Pet-$VERSION.pkg"
if [ -n "${MACOS_INSTALLER_SIGNING_IDENTITY:-}" ]; then
    productsign --sign "$MACOS_INSTALLER_SIGNING_IDENTITY" "$PKG_UNSIGNED" "$FINAL_PKG"
else
    echo "warning: MACOS_INSTALLER_SIGNING_IDENTITY not set; shipping an unsigned .pkg" >&2
    cp "$PKG_UNSIGNED" "$FINAL_PKG"
fi

if [ -n "${MACOS_APP_SIGNING_IDENTITY:-}" ]; then
    codesign --force --deep --options runtime --timestamp \
        --sign "$MACOS_APP_SIGNING_IDENTITY" "$APP"
else
    echo "warning: MACOS_APP_SIGNING_IDENTITY not set; ad-hoc signing the .app" >&2
    codesign --force --deep --sign - "$APP"
fi

if [ -n "${APPLE_ID:-}" ] && [ -n "${APPLE_TEAM_ID:-}" ] && [ -n "${APPLE_APP_PASSWORD:-}" ]; then
    xcrun notarytool submit "$FINAL_PKG" \
        --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_PASSWORD" \
        --wait
    xcrun stapler staple "$FINAL_PKG"
    ditto -c -k --sequesterRsrc --keepParent "$APP" "$BUILD/app-for-notary.zip"
    xcrun notarytool submit "$BUILD/app-for-notary.zip" \
        --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_PASSWORD" \
        --wait
    xcrun stapler staple "$APP"
else
    echo "warning: notarization credentials not set; artifacts are not notarized" >&2
fi

# ---------------------------------------------------------------------------
# 3) Clippy-Pet-<version>.dmg containing the .app, the .pkg, and docs.

DMGROOT="$BUILD/dmgroot"
mkdir -p "$DMGROOT"
cp -R "$APP" "$DMGROOT/"
cp "$FINAL_PKG" "$DMGROOT/"
cp "$ROOT/LICENSE" "$DMGROOT/LICENSE.txt"
cp "$ROOT/NOTICE.md" "$DMGROOT/NOTICE.txt"
cat > "$DMGROOT/README.txt" <<EOF
Clippy Pet $VERSION

Double-click "Install Clippy Pet.app" to install for your user only
(no administrator password required), or run the included .pkg to
install for every user on this Mac.

After installing, reload Codex, then open Settings > Pets > Clippy Pet
(or run /pets clippy-pet in the Codex CLI TUI).
EOF

DMG="$OUT/Clippy-Pet-$VERSION.dmg"
rm -f "$DMG"
hdiutil create -volname "Clippy Pet" -srcfolder "$DMGROOT" -fs HFS+ -format UDZO -ov "$DMG"

rm -rf "$BUILD"
echo "Built:"
ls -la "$OUT"
