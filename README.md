# Pickup (Flutter + PWA)

Pickup now supports Web/PWA delivery so iOS users can install it from Safari
without App Store listing/review.

## Build Web PWA

```bash
flutter build web --release --pwa-strategy=offline-first
```

Generated output:

`build/web`

Deploy that folder to any HTTPS static host (Netlify, Vercel, Cloudflare Pages,
Nginx, etc.).

PowerShell helper:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_pwa.ps1
```

## Local Run (Important)

Do not open `build/web/index.html` directly with `file://`.
Flutter Web must run via HTTP/HTTPS.

Use:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/serve_pwa_local.ps1
```

Then open:

`http://127.0.0.1:8787`

Self-check:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/self_check_pwa.ps1
```

## iOS Install Flow (No App Store)

1. Open deployed URL in Safari on iPhone.
2. Tap Share.
3. Tap "Add to Home Screen".
4. Launch Pickup from home screen (standalone PWA mode).

iOS install guide page:

`/install-ios.html`

## Notes

- Journal entries, AI records, and API settings are persisted locally per device/browser.
- Image attachments are stored as compact base64 data URLs for cross-platform rendering.
- JSON export is available via share/download from the app.
- First load should be online so service worker can cache the app shell for offline reopen.

## Data Migration

### In-app import

Open Pickup Home -> top-right `Import / Migrate` button -> paste JSON -> import.

Supports:

- Legacy export format (`[ ...entries ]`)
- Current format (`{ entries: [...], aiEntries: [...] }`)

### CLI migration script

```bash
python scripts/migrate_export.py --input old_export.json --output migrated.json
```
