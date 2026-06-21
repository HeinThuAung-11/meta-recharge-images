# Meta Recharge — Catalog Images

Public image host for the Meta Recharge app + website. Images live here and are
served through the **jsDelivr** global CDN (free, effectively unlimited
bandwidth) so they don't burn Supabase Storage egress.

## Folders

- `games/` — game cover / icon images
- `gift-cards/` — gift-card brand & category images
- `products/` — package / product images

Use lowercase, hyphenated, unique filenames, e.g. `mobile-legends.webp`.
Prefer **WebP**, ≤ ~1024px wide, to keep files small.

## How to add an image and get its URL

1. Add the file to the right folder (via GitHub web UI "Add file → Upload
   files", or `git add` + push).
2. Build the jsDelivr URL:

   ```
   https://cdn.jsdelivr.net/gh/HeinThuAung-11/meta-recharge-images@main/<folder>/<file>
   ```

   Example:

   ```
   https://cdn.jsdelivr.net/gh/HeinThuAung-11/meta-recharge-images@main/games/mobile-legends.webp
   ```

3. In the admin panel → item → **Image** tab → paste that URL into
   **"Paste image URL"** → Save. The app and website then load it straight from
   the CDN.

## Notes

- **New files** are served immediately (first request fetches from GitHub, then
  is cached at the edge). Because each image has a unique filename, you never
  hit a stale-cache problem.
- If you ever **replace** a file at the same path, jsDelivr caches branch URLs,
  so purge it once:
  `https://purge.jsdelivr.net/gh/HeinThuAung-11/meta-recharge-images@main/<folder>/<file>`
  (or just upload under a new filename — simplest).
- Keep this repo **public** — jsDelivr only serves public repos.
