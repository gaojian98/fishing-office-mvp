# rumor_runtime

## Purpose
Expose active rumors and resident rumor context, including content metadata for discovery, verification, and story/event references.

## Main files
- `fishing_office_flutter/lib/core/managers/rumor_runtime_manager.dart`
- `fishing_office_flutter/lib/models/rumor_config.dart`
- `fishing_office_flutter/lib/core/repository/rumor_repository.dart`

## Data files
- `fishing_office_flutter/assets/config/rumor.json`

## Public interfaces
- `getActiveRumors()`
- `getRumorsForResident(residentId)`
- `addRumor(rumorId)`
- `removeRumor(rumorId)`
- `isRumorActive(rumorId)`
- `getRumorTags()`
- `residentRumorContext(residentId)`
- `loadRecords(records)`

## Direct dependencies
- World Clock, Festival, Weather, Resident, Personality.

## Consumers
- Dialogue, Story, Relationship, Dynamic Event, Quest, Achievement, Save, Second World interactions.

## Save fields
- `rumorRuntime`

## Invariants
- Rumors are world flavor and context, not mandatory tasks.
- Personality may order rumors but not fully decide spread.
- Compatible fields such as `truthState`, `heat`, `spreadRules`, and `expireRules` describe content behavior without changing save structure.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`
- `fishing_office_flutter/test/content_integration_test.dart`

## Known limitations
- Rumor UI is projected through resident detail and Office Hub; no dedicated rumor page exists.
