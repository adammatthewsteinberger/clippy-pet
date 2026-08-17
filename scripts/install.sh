#!/bin/sh
# Clippy Pet installer.
#
# From a checkout of this repository, this runs the local payload directly:
#   ./scripts/install.sh
#
# As a standalone bootstrap (e.g. served from GitHub Pages), it downloads the
# latest (or a pinned) release tarball, verifies its checksum, and installs:
#   curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh
#
# Any arguments are forwarded to `clippy-pet install`, e.g.:
#   curl -fsSL .../install.sh | sh -s -- --link
set -eu

REPO=adammatthewsteinberger/clippy-pet

main() {
    # shellcheck disable=SC1007
    repository_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

    if [ -f "$repository_dir/pet.json" ] && [ -f "$repository_dir/spritesheet.webp" ]; then
        # Running from a checkout: install directly, offline.
        if [ -x "$repository_dir/packaging/bin/clippy-pet" ]; then
            CLIPPY_PET_DATA="$repository_dir" exec "$repository_dir/packaging/bin/clippy-pet" install "$@"
        fi
        # Fallback for older checkouts without the packaging/ CLI.
        codex_root=${CODEX_HOME:-"$HOME/.codex"}
        destination="$codex_root/pets/clippy-pet"
        mkdir -p "$destination"
        cp "$repository_dir/pet.json" "$destination/pet.json"
        cp "$repository_dir/spritesheet.webp" "$destination/spritesheet.webp"
        printf 'Installed Clippy Pet in %s\n' "$destination"
        return 0
    fi

    bootstrap "$@"
}

bootstrap() {
    need curl
    need tar

    version=${CLIPPY_PET_VERSION:-latest}
    if [ "$version" = latest ]; then
        release_url="https://github.com/$REPO/releases/latest"
    else
        release_url="https://github.com/$REPO/releases/tag/$version"
    fi

    resolved=$(curl -fsSI "$release_url" | tr -d '\r' | awk '/^[Ll]ocation:/ {print $2; exit}')
    if [ -z "${resolved:-}" ]; then
        resolved=$release_url
    fi
    tag=$(printf '%s' "$resolved" | sed -n 's#.*/tag/##p')
    if [ -z "$tag" ]; then
        echo "error: could not resolve a release tag from $release_url" >&2
        exit 1
    fi
    ver=${tag#v}

    base="https://github.com/$REPO/releases/download/$tag"
    tarball="clippy-pet-$ver.tar.gz"

    workdir=$(mktemp -d)
    trap 'rm -rf "$workdir"' EXIT

    echo "Downloading $tarball ($tag)..."
    curl -fsSL -o "$workdir/$tarball" "$base/$tarball"
    curl -fsSL -o "$workdir/SHA256SUMS" "$base/SHA256SUMS"

    verify_checksum "$workdir" "$tarball"

    tar -xzf "$workdir/$tarball" -C "$workdir"
    extracted="$workdir/clippy-pet-$ver"
    if [ ! -d "$extracted" ]; then
        extracted=$(find "$workdir" -maxdepth 1 -type d -name 'clippy-pet-*' | head -n1)
    fi
    if [ ! -x "$extracted/bin/clippy-pet" ]; then
        echo "error: downloaded tarball did not contain bin/clippy-pet" >&2
        exit 1
    fi

    CLIPPY_PET_DATA="$extracted" "$extracted/bin/clippy-pet" install "$@"
}

verify_checksum() {
    dir=$1
    file=$2
    line=$(grep -- "  $file\$" "$dir/SHA256SUMS" 2>/dev/null || true)
    if [ -z "$line" ]; then
        echo "warning: no checksum entry found for $file; skipping verification" >&2
        return 0
    fi
    expected=$(printf '%s' "$line" | awk '{print $1}')
    if command -v sha256sum >/dev/null 2>&1; then
        actual=$(sha256sum "$dir/$file" | awk '{print $1}')
    elif command -v shasum >/dev/null 2>&1; then
        actual=$(shasum -a 256 "$dir/$file" | awk '{print $1}')
    else
        echo "warning: no sha256sum/shasum available; skipping verification" >&2
        return 0
    fi
    if [ "$expected" != "$actual" ]; then
        echo "error: checksum mismatch for $file" >&2
        echo "  expected: $expected" >&2
        echo "  actual:   $actual" >&2
        exit 1
    fi
}

need() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "error: required command not found: $1" >&2
        exit 1
    }
}

main "$@"
