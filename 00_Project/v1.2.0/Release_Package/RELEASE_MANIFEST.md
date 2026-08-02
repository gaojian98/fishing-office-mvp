# v1.2.0 RC1 Release Manifest

- Release name: Fishing Office v1.2.0 RC1
- Version source: `fishing_office_flutter/pubspec.yaml` currently remains the app version source; no release tag was created.
- Base production tag: `v1.0.0`
- Development branch: `feature/v1.1-office-life-schedule`
- Base HEAD before RC packaging: `1bbd884`
- Production URL: `https://fishing.up.railway.app/`
- Staging URL: To be created by owner after commit approval.
- Release package date: 2026-08-03

## Scope

- Interactive Office Life runtime integration.
- Resident detail interaction polish.
- Content integration and interaction expansion.
- Visual/product experience polish within existing UI constraints.
- RC integration, browser acceptance, staging readiness, and human authorization gate packaging.

## Validation

- `dart format --set-exit-if-changed lib test`: PASS
- `flutter analyze`: PASS
- `flutter test`: PASS, 93 tests
- `flutter build web --release`: PASS
- `git diff --check`: PASS

## Commit State

No commits, pushes, tags, merges, or deployments were performed by Module 08 or Module 09.
