# Interactive Office Life QA Stability Test Plan

## Scope
- Office Hub.
- Resident list.
- Resident detail.
- Player action request/result.
- Share-fish selector.
- Friendship, memory, skill, save, and processed action integration.
- Overlay, pointer, loading, and duplicate-submit safety.

## Priority
- P0: app startup, save damage, core interaction flow interruption.
- P1: resident detail unavailable, duplicate settlement, broken overlay or pointer lock.
- P2: copy, slow response, weak empty state, mobile layout discomfort.
- P3: minor wording or visual polish.

## Targeted Tests
- `flutter test test/widgets/resident_detail_dialog_test.dart`
- `flutter test test/framework_smoke_test.dart`

## Full Validation
- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `flutter build web --release`

## Manual Acceptance Recommended
- Open and close Office Hub repeatedly.
- Open resident section, detail, result panel, and share-fish selector repeatedly.
- Verify homepage buttons remain clickable after dialog close.
- Verify Chrome console has no blocking errors.
- Verify Network has no critical 404.
