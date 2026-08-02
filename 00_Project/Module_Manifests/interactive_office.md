# interactive_office

## Purpose
Expose the existing living office runtime as a player-visible, UI-safe office hub with content-backed residents, groups, events, recommendations, and resident actions.

## Main files
- `fishing_office_flutter/lib/models/interactive_office.dart`
- `fishing_office_flutter/lib/core/engine/second_world_engine.dart`
- `fishing_office_flutter/lib/core/providers/app_providers.dart`
- `fishing_office_flutter/lib/core/dialog/dialog_manager.dart`
- `fishing_office_flutter/lib/widgets/office/office_hub_dialog.dart`
- `fishing_office_flutter/lib/pages/profile/profile_center_dialog_page.dart`

## Data files
- Uses existing resident, dialogue, story, event, rumor, world, inventory, and save runtime state.
- No new JSON type.

## Public interfaces
- `SecondWorldEngine.getInteractiveOfficeSnapshot(...)`
- `SecondWorldEngine.submitPlayerAction(request)`
- `interactiveOfficeSnapshotProvider`
- `playerInfluenceProvider`
- `activeOfficeGroupsProvider`
- `officeEventsProvider`
- `dailyOfficeSummaryProvider`
- `residentInteractionProvider`
- `ResidentDetailViewModel.shareFishOptions`
- `DialogManager.openById(..., 'office_hub')`

## Direct dependencies
- Second World Engine
- Living Office state
- Player Influence context
- Resident Runtime
- Inventory state
- Dialogue Runtime
- Story Runtime
- Relationship Runtime
- Dynamic Event Runtime
- Rumor Runtime
- Daily Simulation
- World Save

## Consumers
- Profile Center dialog
- Office Hub dialog
- Future resident detail and office status widgets

## Save fields
- Reads `livingOfficeState`
- Reads `playerInfluenceContext`
- Reads `careerState`
- Reads `playerSkillStates`
- Reads `activeGroups`
- Reads `officeWorldHistory`
- Writes recent player actions through existing save methods
- Uses processed office event ids for duplicate action protection and same-day share-fish limits

## Invariants
- UI does not call multiple resident runtimes directly.
- UI submits `PlayerActionRequest` and receives `PlayerActionResult`.
- No direct JSON reads from UI.
- No new homepage route or hotspot.
- Profile Center is the current entry point.
- Missing Daily Simulation state must return safe fallback summary fields.
- Share fish is submitted through `SecondWorldEngine.submitPlayerAction`.
- Resident action feedback is read through Dialogue Runtime when content is available.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`
- `fishing_office_flutter/test/widgets/resident_detail_dialog_test.dart`
- `fishing_office_flutter/test/content_integration_test.dart`

## Known limitations
- Office Hub is a compact one-screen dialog and not a full office page.
- Browser manual interaction is still recommended before product acceptance.

## Module 05 visual polish

- Office Hub UI keeps visual polish inside existing widget and model helpers.
- No new top-level UI manager, runtime, engine, repository, or JSON type.
- Related tests: `fishing_office_flutter/test/widgets/resident_detail_dialog_test.dart`.
