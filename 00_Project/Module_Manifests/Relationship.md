# Relationship Module Manifest

## Purpose

Evolve player-resident and resident-resident relationships through memory, location, stories, rumors, and personality.

## Main files

- `fishing_office_flutter/lib/core/managers/relationship_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/resident_relationship_engine.dart`
- `fishing_office_flutter/lib/models/resident_relationship_config.dart`

## Data files

- `fishing_office_flutter/assets/config/resident_relationship.json`

## Public interfaces

- `updateResidentRelationships()`
- `getRelationshipBetweenResidents(a, b)`
- `getPlayerRelationshipWithResident(id)`
- `applyRelationshipChange(source, target, reason, amount)`

## Dependencies

- Resident
- Personality
- Resident Decision
- Rumor
- Story
- Daily Simulation
- Save

## Consumers

- Dialogue
- Story
- Dynamic Event
- Achievement
- Second World
- Save

## Save fields

- `relationshipRuntimeState`
- `residentRelationship`

## Invariants

- Relationship changes should be gradual and explainable.
- Do not use a mechanical personality conflict table.
- Single negative events must not cause large relationship drops.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
