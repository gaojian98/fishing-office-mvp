# Final Bug List

Version: v1.0.0-rc.1
Scope: Phase 5 Pack 29 Final Bug Fix Sprint

## Summary

- P0: 0
- P1: 0
- P2: 1 found, 1 fixed
- P3: 5 recorded, deferred as non-blocking

## Issues

| id | severity | module | description | reproductionSteps | expectedResult | actualResult | status | rootCause | modifiedFiles | regressionScope |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BUG-001 | P2 | Store / JSON Resources | Store category icon paths pointed to `assets/icons/store/*.png`, but the project has no `assets/icons` directory. | Run resource-path validation against `assets/config/store/store_products.json`. | All configured image/icon paths resolve to existing assets. | Category icon paths were missing. | Fixed | Store category icon config referenced old planned icon paths. | `/Users/pc/Documents/fishing-office-mvp/fishing_office_flutter/assets/config/store/store_products.json`; `/Users/pc/Documents/fishing-office-mvp/fishing_office_flutter/test/framework_smoke_test.dart`; `/Users/pc/Documents/fishing-office-mvp/fishing_office_flutter/tool/final_bug_fix_validation.py` | Store popup, JSON asset validation, release resource validation |
| BUG-002 | P3 | Documentation | Historical docs still mention old local URLs such as `127.0.0.1:3100` and `8084`. | Search historical documentation for old local URLs. | Current validation uses `127.0.0.1:3101`; old references do not affect runtime. | Old references remain in historical context. | Deferred | Historical reports preserve prior test context. | None | Documentation only |
| BUG-003 | P3 | Test Logs | Runtime debug logs are verbose in `flutter test` output. | Run `flutter test`. | Test logs remain readable enough for regression. | Debug prints are noisy but non-blocking. | Deferred | Existing debug observability intentionally logs Runtime flow. | None | Test output only |
| BUG-004 | P3 | Audio | Real ambient and SFX assets are not connected yet. | Trigger ambient presentation or fishing result cues. | Missing audio must not crash runtime. | Existing AudioManager safely no-ops and logs cues in debug. | Deferred | Audio asset pipeline is reserved for future content. | None | Ambient presentation, fishing feedback |
| BUG-005 | P3 | Fishing Balance | Real long-wait fields are not formally stored per fish. | Inspect fish config for explicit min/max wait fields. | MVP can use shortened wait mapping while preserving future long-wait capability. | Current wait curve uses rarity-based MVP mapping. | Deferred | Pack 28 limited scope to balance validation and small fixes. | None | Fishing pacing |
| BUG-006 | P3 | Economy | 高频 30 天模拟余额偏高，后续长期消费内容接入前需要继续观察。 | Run `tool/balance_validation.py`. | Economy should not hard-block early play or explode in short sessions. | No short-term blocker; long-term high-frequency balance needs future content. | Deferred | Long-term sinks are not in V1.0 MVP scope. | None | Economy long-tail |

## P0 / P1 Status

No P0 or P1 issues were found in the current report set or in Pack 29 validation.
