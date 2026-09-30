#!/bin/sh
# Build the Home Manager example exactly as docs/packages/linux.md shows it.
#
# Extracts the first ```nix block after "A minimal standalone setup" from the
# Markdown, points its clippy-pet input at this checkout (shallow=1, because CI
# checks out a shallow clone that has no revCount), and its system at
# the host's; builds the Home Manager generation, and checks that the pet's
# two files are in it. If someone edits the example into something that no
# longer builds, this fails.
#
# Usage: tests/home-manager-doc-example.sh   (needs Nix with flakes enabled)
set -eu

ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
SYSTEM=$(nix eval --impure --raw --expr builtins.currentSystem)

awk '
    /A minimal standalone setup/ { found = 1 }
    found && /^```nix/ { inside = 1; next }
    inside && /^```/ { exit }
    inside { print }
' "$ROOT/docs/packages/linux.md" \
    | sed -e "s#github:adammatthewsteinberger/clippy-pet/develop#git+file://$ROOT?shallow=1#" \
          -e "s#x86_64-linux#$SYSTEM#" > "$WORK/flake.nix"
grep -q 'homeManagerModules.default' "$WORK/flake.nix" || {
    echo "error: could not extract the Home Manager example from docs/packages/linux.md" >&2
    exit 1
}
printf '{ ... }: { home.username = "you"; home.homeDirectory = "/home/you"; home.stateVersion = "26.05"; }\n' \
    > "$WORK/home.nix"

(cd "$WORK" && git init -q && git add -A)
out=$(nix build "$WORK#homeConfigurations.you.activationPackage" --no-link --print-out-paths)
for f in pet.json spritesheet.webp; do
    test -e "$out/home-files/.codex/pets/clippy-pet/$f" || {
        echo "error: $f missing from the Home Manager generation" >&2
        exit 1
    }
done
echo "the documented Home Manager example builds and places both pet files"
