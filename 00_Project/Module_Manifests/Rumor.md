# Rumor Module Manifest

## Purpose

Run world rumors as lightweight changing context for residents, dialogue, stories, events, and relationships.

## Main files

- `fishing_office_flutter/lib/core/managers/rumor_runtime_manager.dart`
- `fishing_office_flutter/lib/core/repository/rumor_repository.dart`
- `fishing_office_flutter/lib/models/rumor_config.dart`

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

## Dependencies

- World Clock
- Festival
- Weather
- Resident
- Personality

## Consumers

- Dialogue
- Story
- Relationship
- Dynamic Event
- Quest
- Achievement
- Save

## Save fields

- `rumorRuntime`

## Invariants

- Rumors may influence choices but must not become mandatory tasks.
- Personality may order rumors but must not fully decide propagation.
- Expired or archived rumors must not become active again unless explicitly re-added.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
