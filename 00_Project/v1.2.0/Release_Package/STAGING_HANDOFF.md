# Staging Handoff

## Repository

- Repository: `https://github.com/gaojian98/fishing-office-mvp.git`
- Source branch: `feature/v1.1-office-life-schedule`
- Proposed RC branch: `rc/v1.2.0-rc.1`

## Railway Configuration

- Staging service: create a separate service; do not reuse production.
- Root Directory: repository root.
- Dockerfile path: `Dockerfile`.
- Docker build context: repository root.
- Flutter project path: `fishing_office_flutter/`.
- Build command: Dockerfile runs `flutter pub get` and `flutter build web --release`.
- Start command: `node server.js`.
- Port: `PORT` environment variable; Dockerfile defaults to `3000`.
- Health check: GET `/` should return 200 HTML.

## Expected Asset Paths

- `/flutter_bootstrap.js`
- `/main.dart.js`
- `/manifest.json`
- `/assets/assets/config/resident_dialogue.json`
- `/assets/assets/config/office_dialog.json`

## Domain Behavior

- Staging domain must be separate from `https://fishing.up.railway.app/`.
- Production domain must not be changed during RC staging.

## SPA Fallback

- Real SPA routes return `index.html`.
- Missing static assets, including missing JSON, return 404.
- Direct `/assets/assets/config/dialog.json` request should return 404.

## Environment Variables

- Required: `PORT` provided by Railway.
- Secrets: none required for this static Flutter web service.
- Do not add API keys or Railway tokens to the repository.

## Staging Validation

1. Verify deployed commit equals pushed RC commit.
2. Verify critical resources return correct statuses and content types.
3. Verify Console error count is 0.
4. Click all 9 home entries.
5. Run Start Fishing -> Wait -> Pull Line -> Result -> Sell / Put Into Bag.
6. Validate mobile viewport manually.

## Rollback Method

If P0/P1 appears in staging, stop promotion and keep production on `v1.0.0`. Revert on the RC branch with a normal revert commit; do not force push.
