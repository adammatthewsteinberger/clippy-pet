#!/bin/sh
set -eu

repository_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_root=${CODEX_HOME:-"$HOME/.codex"}
destination="$codex_root/pets/clippy-pet"
mkdir -p "$destination"
cp "$repository_dir/pet.json" "$destination/pet.json"
cp "$repository_dir/spritesheet.webp" "$destination/spritesheet.webp"
printf 'Installed Clippy Pet in %s\n' "$destination"
