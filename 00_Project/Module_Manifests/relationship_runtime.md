# relationship_runtime

## Purpose
Evolve player-resident and resident-resident relationships.

## Main files
- `fishing_office_flutter/lib/core/managers/relationship_runtime_manager.dart`
- `fishing_office_flutter/lib/core/engine/resident_relationship_engine.dart`
- `fishing_office_flutter/lib/models/resident_relationship_config.dart`
- `fishing_office_flutter/lib/models/friendship_state.dart`
- `fishing_office_flutter/lib/models/office_group.dart`

## Data files
- `fishing_office_flutter/assets/config/resident_relationship.json`

## Public interfaces
- `updateResidentRelationships()`
- `getRelationshipBetweenResidents(a, b)`
- `getPlayerRelationshipWithResident(id)`
- `applyRelationshipChange(source, target, reason, amount)`
- `getFriendshipState(residentId)`
- `getAllFriendshipStates()`
- `getAvailableInteractions(residentId)`
- `applyFriendshipChange(...)`
- `generateOfficeGroups(...)`
- `getActiveOfficeGroups()`
- `getGroupsForResident(residentId)`
- `getPrimaryGroupForResident(residentId)`
- `applyOfficeGroupInteraction(groupId, ...)`

## Direct dependencies
- Resident, Personality, Resident Decision, Rumor, Story, Daily Simulation, Save.

## Consumers
- Dialogue, Story, Dynamic Event, Achievement, Second World.

## Save fields
- `relationshipRuntimeState`
- `residentRelationship`
- `friendshipStates`
- `processedSocialSourceIds`
- `socialInteractionHistory`
- `socialCooldowns`
- `conflictStates`
- `dailySocialSummary`
- `officeGroupState`
- `activeGroups`
- `recentGroups`
- `groupHistory`

## Invariants
- Relationship changes are gradual and explainable.
- No mechanical personality conflict table.
- Friendship changes are source-deduped and capped at `-10..10`.
- One interaction cannot jump more than one friendship stage.
- Conflict is recoverable and never becomes an enemy system.
- Office groups stay small, bounded, and location-bucketed.
- Group interactions must use existing friendship, relationship, skill, and save APIs.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Resident-resident relationship UI is not present.
- Office group activity is runtime context only; no group UI exists yet.
