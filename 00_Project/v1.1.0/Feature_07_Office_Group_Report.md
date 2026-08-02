# Feature 07 Office Group & Social Events Integration Report

## Status

Implemented locally. Pending product review.

## Scope

Feature 07 adds small office group behaviour on top of existing runtime systems.

No UI, homepage, map, JSON type, standalone Manager, standalone Engine, or standalone Repository was added.

## Modified Modules

- Relationship Runtime
- Dialogue Runtime
- Story Runtime
- Dynamic Event Runtime
- Second World Engine
- World Save
- Smoke Tests
- Project navigation documents

## OfficeGroup Model

`OfficeGroup` is a lightweight runtime model.

Fields:

- `groupId`
- `locationId`
- `members`
- `leaderId`
- `topic`
- `mood`
- `activity`
- `startTime`
- `expectedEndTime`
- `createdReason`
- `importance`
- `tags`

Rules:

- Minimum members: 2
- Maximum members: 6
- Invalid groups are ignored by save and query helpers
- Groups are temporary runtime context, not a permanent social graph

## Group Formation Algorithm

Groups are formed by `RelationshipRuntimeManager.generateOfficeGroups(...)`.

Algorithm:

1. Read all enabled resident current states once.
2. Bucket residents by normalized location.
3. Ignore non-groupable states such as empty location, home, and sleep.
4. Score candidates using friendship, personality, mood, activity, and player skill context.
5. Sort inside each location bucket.
6. Slice each location bucket into groups of at most 6.
7. Bound active groups to avoid runaway group counts.
8. Save active, recent, and historical groups through `WorldSaveManager`.

Performance principle:

- Grouping is location-bucketed.
- It does not perform full O(n^2) resident matching.

## Supported Group Activities

Implemented compatible activities:

- `coffee_break`
- `lunch`
- `meeting`
- `weekend_fishing`
- `office_chat`
- `rumor_discussion`
- `festival_gathering`
- `project_review`

Reserved by model/tags for future content:

- Birthday
- Celebration
- Emergency Meeting
- Story Discussion

## Group Dialogue Mechanism

`ResidentDialogueConditions` now supports optional group fields:

- `groupActivity`
- `groupTopic`
- `groupMood`
- `groupTags`
- `groupSizeMin`

Dialogue Runtime builds group context from resident location and nearby residents. Existing JSON without group fields keeps the same behaviour.

## Group Story Mechanism

`ResidentStoryConditions` now supports optional group fields:

- `groupActivity`
- `groupTopic`
- `groupMood`
- `groupTags`
- `groupSizeMin`

Story Runtime can now make stories require small gatherings without direct UI or JSON type changes.

## Group Event Mechanism

`DynamicEventConditions` now supports optional group fields:

- `groupActivity`
- `groupTopic`
- `groupLocation`
- `groupTags`
- `groupSizeMin`

Dynamic Event Runtime receives active office group context from Relationship Runtime. Existing events continue to work unchanged.

## Relationship Updates

`applyOfficeGroupInteraction(...)` updates group members through existing systems:

- Player-resident friendship
- Resident-resident relationship
- Skill experience
- Daily social summary
- World save

Updates are source-deduped and bounded by existing friendship rules.

## Save

World Save now stores:

- `officeGroupState`
- `activeGroups`
- `recentGroups`
- `groupHistory`

Daily social summary now includes:

- `todayOfficeEvents`
- `todaysGroups`
- `todaysConversations`
- `todaysGatherings`

Old saves remain compatible because missing fields load as empty defaults.

## Tests

Added smoke coverage:

- `office group behaviour batches residents dialogue story and save`

Covered:

- 100 resident runtime input
- Small group size bounds
- Coffee group
- Meeting or project review group
- Group dialogue condition
- Group story condition
- Group relationship/friendship update
- Skill gain through group interaction
- Save and restore of active groups

## Performance Result

Measured by smoke test path:

- 100 residents can be grouped without full pair matching.
- Active groups are bounded below total resident count.
- Existing smoke suite passed after Feature 07 changes.

## Validation

Current local validation:

- `dart format lib test`: PASS
- `flutter analyze`: PASS
- `flutter test`: PASS, 45 tests
- `flutter test test/framework_smoke_test.dart`: PASS
- `flutter build web --release`: PASS

## Known Limitations

- No UI displays office groups yet.
- Group history is bounded but not shown in profile or daily summary UI.
- Birthday and celebration require future content conditions.
- Meeting room capacity can route some residents into `project_review` compatible groups.
- Relationship Runtime still owns both friendship and group coordination; no new top-level Runtime was added by design.

## Next Step

Recommended next Feature:

Feature 08: Living Office World.
