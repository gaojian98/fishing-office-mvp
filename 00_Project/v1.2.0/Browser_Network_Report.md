# Browser Network Report

## Result

PASS for local critical resource checks after restarting the local server with the current `server.js`.

## Checked URLs

| URL | Status | Content-Type | Result |
| --- | ---: | --- | --- |
| `/` | 200 | `text/html; charset=utf-8` | PASS |
| `/flutter_bootstrap.js` | 200 | `application/javascript; charset=utf-8` | PASS |
| `/main.dart.js` | 200 | `application/javascript; charset=utf-8` | PASS |
| `/manifest.json` | 200 | `application/json; charset=utf-8` | PASS |
| `/assets/assets/config/resident_dialogue.json` | 200 | `application/json; charset=utf-8` | PASS |
| `/assets/assets/config/office_dialog.json` | 200 | `application/json; charset=utf-8` | PASS |
| `/assets/assets/config/dialog.json` | 404 | `text/plain; charset=utf-8` | PASS |

## Fix Applied

Root `server.js` now returns `404 Static asset not found` for missing static asset requests instead of serving SPA `index.html`.

## Impact

- Valid Flutter routes still fall back to `index.html`.
- Missing JSON, JS, CSS, image, or other static files no longer hide as HTML 200 responses.
- This makes Railway staging Network failures visible instead of silent.
