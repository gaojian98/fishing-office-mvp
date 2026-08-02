# Staging Deployment Plan

## Status

Prepared only. Not executed.

## Preconditions

Before staging deployment:

1. Product owner authorizes Commit.
2. Product owner authorizes Push.
3. Product owner authorizes RC tag creation.
4. Product owner confirms Railway staging service is separate from production.
5. Final validation remains PASS.

## Planned Deployment Target

- Service: separate Railway staging service.
- Root directory: repository root.
- Dockerfile: `Dockerfile`.
- Start command: `node server.js`.
- Domain: staging domain to be provided by Railway.

## Staging Checks

After deployment:

1. Confirm deployment commit equals the pushed RC commit.
2. Confirm `/` returns 200.
3. Confirm `/flutter_bootstrap.js` returns 200.
4. Confirm `/main.dart.js` returns 200.
5. Confirm `manifest.json` returns 200 JSON.
6. Confirm `resident_dialogue.json` returns 200 JSON.
7. Confirm `office_dialog.json` returns 200 JSON.
8. Confirm `dialog.json` is not requested by the app.
9. Confirm direct missing static JSON returns 404, not HTML.
10. Confirm Console error count is 0.
11. Click all 9 home entries.
12. Run the core fishing flow.

## Module 08 Handoff

Detailed staging handoff is now available at:

- `00_Project/v1.2.0/Release_Package/STAGING_HANDOFF.md`
- `00_Project/v1.2.0/Release_Package/AUTHORIZED_COMMANDS.md`
- `00_Project/v1.2.0/Release_Package/AUTHORIZATION_CHECKLIST.md`

No Railway deployment has been executed.

## Rollback

If staging produces P0 or P1:

- Do not promote to production.
- Keep `v1.0.0` production unchanged.
- Revert or amend only on the feature branch after diagnosis.
