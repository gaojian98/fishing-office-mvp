# Feature 04 Career & Promotion Report

## Career Model

Added `CareerState` as a lightweight model, not a top-level Manager or Engine.

Core fields:

- `careerLevel`
- `jobTitle`
- `departmentId`
- `performanceScore`
- `experience`
- `salary`
- `promotionProgress`
- `promotionEligible`
- `lastSalaryDate`
- `lastPromotionDate`
- `consecutiveWorkDays`
- `completedCareerTasks`
- `careerTags`
- `recentCareerChanges`

Default state:

- `careerLevel`: `intern`
- `jobTitle`: `实习生`
- `performanceScore`: `50`
- `experience`: `0`
- `promotionProgress`: `0`
- `promotionEligible`: `false`

## Career Levels

Order:

`intern -> junior_employee -> employee -> senior_employee -> team_lead -> supervisor -> manager -> senior_manager -> director`

No demotion is implemented in Feature 04.

## Promotion Requirements

Promotion is deterministic and requires combined conditions:

- work days
- career task count
- performance score
- career experience
- relationship rank for mid/high levels
- required achievement for high levels
- promotion reward not already claimed

The first promotions follow the requested shape:

- `intern -> junior_employee`: work days >= 3, career tasks >= 3, performance >= 55, experience >= 20.
- `junior_employee -> employee`: work days >= 7, career tasks >= 8, performance >= 60, experience >= 60.
- `employee -> senior_employee`: work days >= 15, career tasks >= 15, performance >= 65, experience >= 130, at least friend-rank relationship.

## Performance Rules

- Range is clamped to `0..100`.
- Ordinary career events are capped to small changes.
- Major changes are capped at `+/-8`.
- Daily settlement applies slow regression toward a calmer middle range.
- Fishing itself does not reduce performance.

## Experience Rules

- Career experience only increases.
- Every career reward uses a stable `sourceId`.
- Repeated source IDs do not grant experience again.
- Career experience is separate from wallet/profile experience.

## Salary Rules

- Salary is based on career level.
- Economy Runtime exposes salary lookup.
- Daily Simulation can trigger salary on a seven-day period when wallet and transaction managers are provided.
- Salary writes `fish_coin` and creates a transaction with `type: salary`.
- The salary transaction ID includes career level and period range.

## Cross-Module Integration

- `DailySimulationManager`: daily career settlement, summary fields, salary period call.
- `QuestRuntimeManager`: career task/event recognition and career progress source dedupe.
- `EconomyRuntimeManager`: salary calculation API.
- `AchievementRuntimeManager`: career metric collection.
- `WorldSaveManager`: career state, reward history, salary IDs, promotion history, daily settlement day.
- `SecondWorldEngine`: public career read, promotion, salary claim, and interaction result context.
- `app_providers.dart`: exposes `careerStateProvider` from existing `WorldSaveManager`.

## Save Compatibility

`WorldSaveData` save version is now `1.1`.

New fields:

- `careerState`
- `careerRewardHistory`
- `salaryTransactionIds`
- `promotionHistory`
- `lastCareerDailySettlement`

Old `1.x` saves migrate by applying default career fields when missing.

History limits:

- career reward records: latest 100
- salary records: latest 52 transaction IDs
- promotion records: bounded by career level count

## Duplicate Protection

Protected operations:

- duplicate career experience by `sourceId`
- duplicate salary by period transaction ID
- duplicate promotion reward by promotion record ID
- same-day daily career settlement by `lastCareerDailySettlement`
- repeated promotion submission by rechecking all requirements

## Test Results

- Targeted smoke test: `flutter test test/framework_smoke_test.dart` PASS.
- `dart format lib test` PASS.
- `flutter analyze` PASS.
- `flutter test` PASS, 43 tests.
- `flutter build web --release` PASS.

## Performance Result

Career state is player-singleton data.

- It is not calculated inside resident loops.
- Daily settlement is O(1).
- Promotion requirement checks are O(1) plus relationship rank lookup by existing resident list when called through `SecondWorldEngine`.
- Salary is checked only during daily settlement or explicit claim.
- Career daily settlement duration is recorded by `DailySimulationManager.lastCareerSettlementDurationMs`.
- No World Tick order changes were introduced.

## Known Limitations

- No career page has been added.
- No career JSON type has been added.
- Existing honor/identity JSON controls whether career metrics appear as visible achievements.
- Promotion rewards are currently fish_coin only.

## Next Suggestion

Proceed to Feature 05: Salary, Skills & Career Feedback after product review.
