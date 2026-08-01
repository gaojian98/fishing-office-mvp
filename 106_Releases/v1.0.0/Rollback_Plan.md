# Fishing Office v1.0.0 Rollback Plan

## Current Stable Version

- RC1: v1.0.0-rc.1

## Gold Master Version

- Gold Master Candidate: v1.0.0

## Rollback Target

If Gold Master validation fails, restore the project state to the last accepted RC1 snapshot. The release documentation remains separated under `106_Releases/v1.0.0-rc.1/` and `106_Releases/v1.0.0/`, so RC1 validation material can be used as the recovery reference.

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
2. Restore RC1 source snapshot from the accepted pre-Gold-Master state.
3. Re-run `flutter clean`, `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build web --release`.
4. Re-run final validation scripts.
5. Confirm save fallback behavior before reopening Founder testing.

## Severe Issue Rules

Rollback immediately if any P0 or P1 appears after Gold Master freeze, including startup failure, save corruption, negative assets, duplicate rewards, dead core flow, or unrecoverable blank screen.
