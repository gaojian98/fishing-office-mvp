# v1.2.0 RC Integration Test Report

## Environment

- Date: 2026-08-02 22:15:42 UTC+07:00
- Branch: `feature/v1.1-office-life-schedule`
- Flutter project: `fishing_office_flutter`

## Results

- `dart format lib test`: PASS, 214 files checked, 1 changed.
- `flutter analyze`: PASS, no issues found.
- `flutter test test/release_candidate_integration_test.dart`: PASS, 20 tests.
- `flutter test`: PASS, 78 tests.
- `flutter build web --release`: PASS.
- `git diff --check`: PASS.

## Cross-module Coverage

- Office Hub -> Resident List -> Resident Detail -> Player Action: PASS via widget and smoke tests.
- Dialogue / Story / Rumor / Dynamic Event / Group / Friendship: PASS via smoke and content integration tests.
- Career / Skill / Quest / Achievement / Player Influence / Daily Summary / Save: PASS via smoke tests.
- Fishing -> Wallet / Inventory / Collection / Task / Transaction: PASS via smoke tests.

## Fixed During Module

- RC test assumptions were corrected to use actual `CareerState.careerLevel` and existing fish rarity identifiers.

## Limits

- Browser automation API was unavailable in this environment, so true Console and visual pointer checks are recorded as manual follow-up.
