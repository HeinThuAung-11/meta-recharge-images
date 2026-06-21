#!/usr/bin/env bash
#
# Clean up image filenames into safe, URL-friendly slugs before uploading.
#   "Mobile Legends (MM).PNG"  ->  "mobile-legends-mm.png"
#   "Free Fire_Diamonds.jpeg"  ->  "free-fire-diamonds.jpeg"
#
# Lowercases, turns spaces/underscores/symbols into single hyphens, lowercases
# the extension, and resolves name collisions by appending -2, -3, ...
#
# SAFETY: dry-run by default (just prints planned renames). Pass --apply to
# actually rename. Run this BEFORE ./upload.sh.
#
#   ./normalize.sh            # preview
#   ./normalize.sh --apply    # rename
#
set -euo pipefail

FOLDERS=(games gift-cards products)
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

cd "$(dirname "$0")"

slugify() {
  # $1 = base name (no extension) -> lowercase hyphenated slug
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/-{2,}/-/g; s/^-+//; s/-+$//'
}

planned=0
renamed=0

while IFS= read -r f; do
  dir=$(dirname "$f")
  fname=$(basename "$f")
  ext="${fname##*.}"
  name="${fname%.*}"
  slug=$(slugify "$name")
  extl=$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')
  [ -z "$slug" ] && slug="image"
  newbase="$slug.$extl"

  # already clean?
  if [ "$fname" = "$newbase" ]; then
    continue
  fi

  # collision-safe target
  target="$dir/$newbase"
  n=2
  while [ -e "$target" ] && [ "$target" != "$f" ]; do
    target="$dir/$slug-$n.$extl"
    n=$((n + 1))
  done

  planned=$((planned + 1))
  if [ "$APPLY" -eq 1 ]; then
    mv -- "$f" "$target"
    renamed=$((renamed + 1))
    echo "renamed: $f  ->  $target"
  else
    echo "would rename: $f  ->  $target"
  fi
done < <(find "${FOLDERS[@]}" -type f \
            \( -iname '*.webp' -o -iname '*.png' -o -iname '*.jpg' \
               -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.svg' \) \
            | sort)

echo "──────────────────────────────────────────────────────────────────────"
if [ "$APPLY" -eq 1 ]; then
  echo "Renamed ${renamed} file(s). Now run ./upload.sh"
elif [ "$planned" -eq 0 ]; then
  echo "All filenames already clean. Run ./upload.sh"
else
  echo "${planned} file(s) would be renamed. Re-run with --apply to do it."
fi
