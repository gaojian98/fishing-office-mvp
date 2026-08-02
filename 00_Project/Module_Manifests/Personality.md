# Personality Module Manifest

## Purpose

Map existing resident personality values into stable runtime traits that influence existing systems without adding a standalone personality runtime.

## Main files

- `fishing_office_flutter/lib/models/resident_personality_context.dart`
- `fishing_office_flutter/lib/core/managers/resident_runtime_manager.dart`

## Data files

- Existing `personality` field in `residents.json` and `resident.json`.

## Public interfaces

- `getResidentPersonalityContext(id)`
- `getAllResidentPersonalityContexts()`
- `ResidentPersonalityContext.normalizeTrait(raw)`

## Dependencies

- Resident
- Location

## Consumers

- Resident Decision
- Dialogue
- Story
- Rumor
- Relationship
- Dynamic Event
- Second World
- Save

## Save fields

- `recentPersonalityInfluences`
- `lastPersonalityDecisionReason`
- `interactionPreferenceOverride`

## Invariants

- Do not save full personality config in world saves.
- Unknown tags must safely fall back to `calm`.
- Personality changes weights and preferences only; it must not override base schedule, capacity, weather, festival, or major story state.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
