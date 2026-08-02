# Feature 08 Living Office World Integration Report

## Scope
Feature 08 integrates existing v1.1 office-life systems into one shared office-wide runtime state. It does not add UI, a new top-level manager, a new engine, a new repository, or a new JSON type.

## Modified Modules
- `SecondWorldEngine`: builds and exposes `LivingOfficeState` and bounded office history entries.
- `WorldTickManager`: extends `WorldSimulationContext` and refreshes Living Office state once per Tick.
- `DailySimulationManager`: includes Living Office data in `DailyWorldSummary` and daily changes.
- `WorldSaveManager` / `WorldSaveData`: saves Living Office state, history, processed office event ids, and cooldowns.
- `DialogueRuntimeManager`: can filter and prioritize by office mood, level thresholds, and office tags.
- `StoryRuntimeManager`: can filter and prioritize by office mood, level thresholds, group count, popular location, and office tags.
- `DynamicEventRuntimeManager`: can filter by office mood, level thresholds, and office tags.
- `RelationshipRuntimeManager`: avoids unnecessary player relationship refresh during group candidate scoring and friendship snapshots.
- `AchievementRuntimeManager`: reads saved friendship state for relationship progress scanning instead of refreshing all resident relationships.
- `App Providers`: exposes Living Office state and history for future UI consumers.

## LivingOfficeState Model
Fields:
- `date`
- `timeOfDay`
- `officeMood`
- `activityLevel`
- `productivityLevel`
- `socialLevel`
- `tensionLevel`
- `activeResidentCount`
- `workingResidentCount`
- `breakResidentCount`
- `overtimeResidentCount`
- `activeGroupCount`
- `activeEventCount`
- `activeStoryCount`
- `popularLocations`
- `popularTopics`
- `dominantRumors`
- `currentFestival`
- `currentWeather`
- `importantChanges`
- `worldTags`
- `lastUpdatedAt`

## Context Sharing
`WorldSimulationContext` now carries shared clock, weather, festival, rumor, resident, location, personality, friendship, office group, story, event, career, skill, quest, achievement, and Living Office snapshots.

Each Tick builds this context once and passes derived Living Office state into Dialogue, Story, and Dynamic Event runtime filters. Pages should read through providers or `SecondWorldEngine`, not assemble office state directly.

## Office State Rules
- `officeMood` is derived from festival, weather severity, tension, time of day, social level, activity level, productivity, and active resident count.
- `activityLevel` rises with work, breaks, groups, events, stories, and festivals; night and severe weather reduce activity.
- `productivityLevel` rises with working residents and meetings; negative moods, conflicts, festivals, and excessive overtime reduce it.
- `socialLevel` rises with breaks, groups, rumors, happy moods, and festivals; conflicts reduce it.
- `tensionLevel` rises with negative moods, overtime, conflicts, and severe weather, and changes smoothly to avoid sudden jumps.

## Module Collaboration
- Dialogue can react to office mood, activity, tension, and tags.
- Story can react to office mood, activity, tension, group count, popular location, and tags.
- Dynamic Event can react to office mood, activity, tension, and tags.
- Daily Simulation records the office as part of today's world summary.
- World Save persists runtime office state only, not config JSON.

## Daily Summary
`DailyWorldSummary` now includes:
- `livingOfficeState`
- `dominantOfficeMood`
- `averageActivityLevel`
- `averageProductivityLevel`
- `averageSocialLevel`
- `averageTensionLevel`
- `importantOfficeEvents`
- `groupActivities`
- `relationshipChanges`
- `popularLocations`
- `popularTopics`
- `rumorSummary`
- `storySummary`
- `careerSummary`
- `recommendedPlayerActions`

## History And Save
`OfficeWorldHistoryEntry` records date, dominant mood, four office levels, important events, stories, groups, rumors, relationship changes, tags, and whether the entry should be kept forever.

History is bounded to avoid save growth. Legacy saves without Living Office fields fall back to empty safe defaults.

## Performance
Feature 08 keeps the existing Tick orchestration and avoids a new coordinator. Relationship full daily evolution is restricted to Day Tick. Group candidate scoring caches each resident's score during generation. Batch snapshot paths avoid refreshing all player relationships.

Observed Feature 08 smoke run after optimization: the targeted test passes. Remaining verbose debug output comes mainly from Dialogue/Story full-resident scans in the shared smoke test.

## Tests
Added smoke coverage for:
- 100 resident Living Office state.
- Office levels in valid range.
- Popular locations and tags.
- Dialogue/Story/Dynamic Event office context conditions.
- No duplicate friendship reward on repeated Hour Tick.
- Lunch social level difference.
- Night activity decrease.
- Festival context injection.
- Weather disruption context.
- Daily summary office fields.
- Office world history bounds.
- Save/restore and legacy fallback.

## Known Limitations
- No Living Office UI is included in this feature.
- Office state weights are conservative heuristics and should be tuned during playtest.
- Debug logging from existing runtimes remains noisy in smoke tests.
- Full Dialogue/Story cache splitting should be considered in a later stabilization task.

## Recommendation
Feature 08 is ready for review after full validation. Suggested next step: Feature 09 v1.1.0 release validation, unless product wants one more office-life tuning pass first.
