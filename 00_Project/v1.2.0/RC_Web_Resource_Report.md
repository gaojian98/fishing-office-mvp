# v1.2.0 RC Web Resource Report

## Local URL

`http://127.0.0.1:3101/`

## HTTP Checks

- `/`: 200, `text/html`
- `/flutter_bootstrap.js`: 200, JavaScript
- `/main.dart.js`: 200, JavaScript
- `/manifest.json`: 200, JSON
- `/favicon.png`: 200, PNG
- `/assets/AssetManifest.bin`: 200
- `/assets/FontManifest.json`: 200, JSON
- `/assets/assets/config/resident_dialogue.json`: 200, JSON
- `/assets/assets/config/office_dialog.json`: 200, JSON
- `/assets/assets/config/resident_story.json`: 200, JSON
- `/assets/assets/config/rumor.json`: 200, JSON
- `/assets/assets/config/festival.json`: 200, JSON
- `/assets/assets/config/weather.json`: 200, JSON
- `/assets/assets/config/task.json`: 200, JSON
- `/assets/assets/config/fish_catalog.json`: 200, JSON
- `/assets/assets/config/dialog.json`: 404, `text/plain`

## Asset Registration

- `assets/config/dialog.json`: not registered.
- `assets/config/resident_dialogue.json`: registered.
- `assets/config/office_dialog.json`: registered.

## Console

Automated browser Console check PASS.

- Home load: 0 errors.
- 9 home entries: 0 errors.
- Core fishing flow: 0 errors.

## Static Asset Fallback

Root `server.js` now returns 404 for missing static asset requests before SPA fallback. This prevents missing JSON from being served as `index.html`.
