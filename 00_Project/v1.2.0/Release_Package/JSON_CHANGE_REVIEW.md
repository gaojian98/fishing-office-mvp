# JSON Change Review

Date: 2026-08-03
Branch: `feature/v1.1-office-life-schedule`

| File | Current entries | HEAD entries | Added ids | Removed ids | Duplicate ids | Reference check | Recommendation |
|---|---:|---:|---:|---:|---:|---|---|
| `fishing_office_flutter/assets/config/event.json` | 120 | 50 | 70 | 0 | 0 | PASS via JSON parse, duplicate-id scan, and automated content tests | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/events.json` | 120 | 50 | 70 | 0 | 0 | PASS via JSON parse, duplicate-id scan, and automated content tests | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/resident_dialogue.json` | 2620 | 2460 | 160 | 0 | 0 | PASS via JSON parse, duplicate-id scan, and automated content tests | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/resident_story.json` | 1320 | 1320 | 0 | 0 | 0 | PASS via JSON parse, duplicate-id scan, and automated content tests | REVIEW THEN KEEP |
| `fishing_office_flutter/assets/config/rumor.json` | 300 | 300 | 0 | 0 | 0 | PASS via JSON parse, duplicate-id scan, and automated content tests | REVIEW THEN KEEP |

## Notes

- `pubspec.yaml` does not register `assets/config/dialog.json`.
- `office_dialog.json` and `resident_dialogue.json` remain the intended dialogue assets.
- Linux/Railway case-sensitive path risk is covered by release candidate integration tests.
