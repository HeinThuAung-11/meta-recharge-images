#!/usr/bin/env bash
#
# Upload all images in this repo and print every jsDelivr CDN URL at once.
#
# Workflow:
#   1. Drop image files into  games/  gift-cards/  or  products/
#      (WebP preferred, lowercase-hyphenated names, e.g. mobile-legends.webp).
#   2. Run:  ./upload.sh
#
# It commits + pushes everything in one go, then writes every image's jsDelivr
# URL to urls.txt (and prints them). Paste a URL into the admin "Image" tab.
#
set -euo pipefail

OWNER="HeinThuAung-11"
REPO="meta-recharge-images"
BRANCH="main"
FOLDERS=(games gift-cards products)

cd "$(dirname "$0")"

# ── 1. Commit & push any added/changed images ───────────────────────────────
git add -A
if git diff --cached --quiet; then
  echo "No new or changed images to upload."
else
  count=$(git diff --cached --name-only | grep -cE '\.(webp|png|jpe?g|gif|svg)$' || true)
  git commit -q -m "Add/update images ($(date +%Y-%m-%d_%H-%M), ${count} file(s))"
  git push -q origin "$BRANCH"
  echo "✓ Pushed ${count} image change(s) to ${REPO}."
fi

# ── 2. Build every jsDelivr URL ─────────────────────────────────────────────
OUT="urls.txt"
: > "$OUT"
echo
echo "jsDelivr URLs (also saved to $OUT):"
echo "──────────────────────────────────────────────────────────────────────"
found=0
while IFS= read -r f; do
  url="https://cdn.jsdelivr.net/gh/${OWNER}/${REPO}@${BRANCH}/${f}"
  echo "$url" | tee -a "$OUT"
  found=$((found + 1))
done < <(find "${FOLDERS[@]}" -type f \
            \( -iname '*.webp' -o -iname '*.png' -o -iname '*.jpg' \
               -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.svg' \) \
            | sort)
echo "──────────────────────────────────────────────────────────────────────"
echo "${found} image URL(s)."

if [ "$found" -eq 0 ]; then
  echo "(No images yet — drop files into ${FOLDERS[*]} and re-run.)"
fi
