# office_group_runtime

## Purpose
Represent small, bounded office group behaviour inside the existing Relationship runtime.

Residents can temporarily form groups for coffee, lunch, meetings, office chat, rumor discussion, festival gathering, project review, celebration, birthday, emergency meeting, or weekend fishing.

## Main files
- `fishing_office_flutter/lib/models/office_group.dart`
- `fishing_office_flutter/lib/core/managers/relationship_runtime_manager.dart`
- `fishing_office_flutter/lib/core/managers/world_save_manager.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/models/resident_dialogue_config.dart`
- `fishing_office_flutter/lib/models/resident_story_config.dart`
- `fishing_office_flutter/lib/models/dynamic_event_config.dart`

## Data files
- Existing resident, dialogue, story, event, weather, festival, rumor, and save data.
- No new JSON type.

## Public interfaces
- `RelationshipRuntimeManager.generateOfficeGroups(...)`
- `RelationshipRuntimeManager.getActiveOfficeGroups()`
- `RelationshipRuntimeManager.getGroupsForResident(residentId)`
- `RelationshipRuntimeManager.getPrimaryGroupForResident(residentId)`
- `RelationshipRuntimeManager.applyOfficeGroupInteraction(groupId, ...)`
- `WorldSaveManager.activeGroups`
- `WorldSaveManager.recentGroups`
- `WorldSaveManager.groupHistory`
- `WorldSaveManager.groupForResident(residentId)`
- `SecondWorldEngine.getResidentContext(id).officeGroup`
- `InteractionResult.officeGroup*`

## Direct dependencies
- Resident Runtime
- Resident Decision
- Relationship Runtime
- Friendship state
- Rumor Runtime
- Story Runtime
- Daily Simulation
- World Save
- Second World Engine

## Consumers
- Dialogue Runtime
- Story Runtime
- Dynamic Event Runtime
- Daily Social Summary
- Second World Engine
- Future office ambience and resident interaction UI

## Save fields
- `officeGroupState`
- `activeGroups`
- `recentGroups`
- `groupHistory`
- `dailySocialSummary.todayOfficeEvents`
- `dailySocialSummary.todaysGroups`
- `dailySocialSummary.todaysConversations`
- `dailySocialSummary.todaysGatherings`

## Invariants
- Groups are small: minimum 2, maximum 6 members.
- Group formation is bucketed by location and time; it must not run full O(n^2) matching for 100 residents.
- Groups are temporary runtime state, not permanent social graph state.
- Group interactions use existing friendship, relationship, skill, and save APIs.
- A group activity must not directly mutate UI.
- A group cannot replace base resident schedule; it is context on top of runtime location/activity.
- No new page, map, chat room, or JSON type is introduced.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`
  - `office group behaviour batches residents dialogue story and save`

## Known limitations
- Group activities are not visible in UI yet.
- Birthday and celebration events depend on future content conditions.
- Group history is bounded in save, but long-term social analytics are still future work.
