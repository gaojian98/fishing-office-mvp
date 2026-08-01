# Fishing Office v1.0.0 Rollback Plan

## Current Stable Version

- RC1: v1.0.0-rc.1

## Gold Master Version

- Base Version: v1.0.0
- Base Tag: v1.0.0
- Base Tag Commit: 38ce4b886a8b8a13fa4dd4c13d036a0bb3588f31
- Production Commit: 90989c382b5aa0f52afde78cde1ba09ef0df7d1e
- Release Strategy: Production Hotfix on top of v1.0.0; keep `v1.0.0` tag unchanged.

## Rollback Target

If the production hotfix fails, restore production to the previous known stable commit or to the base `v1.0.0` tag depending on severity. The release documentation remains separated under `106_Releases/v1.0.0-rc.1/` and `106_Releases/v1.0.0/`, so RC1 validation material can be used as the recovery reference.

## Rollback File Scope

- Flutter app version metadata: `fishing_office_flutter/pubspec.yaml`
- Node package metadata: `package.json`, `fishing_office_flutter/package.json`
- Release documentation under `106_Releases/v1.0.0/`
- Gold Master report under `00_Project/Gold_Master_Report.md`

## Save Compatibility Strategy

- Runtime save schema version remains `1.0` for v1.0.0 to preserve RC1 save compatibility.
- Existing 1.x saves are migrated by the current save migration path.
- Corrupt or incompatible saves must fall back to safe initialization instead of crashing.

## Recovery Steps

1. Stop deployment or local serving process.
2. For hotfix-only failure, redeploy base tag commit `38ce4b886a8b8a13fa4dd4c13d036a0bb3588f31` or the previous production commit confirmed in Railway.
3. For broader Gold Master failure, restore RC1 source snapshot from the accepted pre-Gold-Master state.
4. Re-run `flutter clean`, `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build web --release`.
5. Re-run final validation scripts.
6. Confirm save fallback behavior before reopening Founder testing.

## Tag Rules

- Do not delete `v1.0.0`.
- Do not overwrite `v1.0.0`.
- Do not force push.
- Current production version is documented by `Production Commit`, not by moving the base tag.

## Severe Issue Rules

Rollback immediately if any P0 or P1 appears after production finalization, including startup failure, save corruption, negative assets, duplicate rewards, dead core flow, or unrecoverable blank screen.
