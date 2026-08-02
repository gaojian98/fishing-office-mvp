# Feature 02 Office Locations Integration Report

## Unified Location List

Office locations:

- `office`
- `workstation`
- `meeting_room`
- `pantry`
- `printing_area`
- `manager_room`
- `balcony`
- `elevator`
- `restroom`
- `reception`

External locations:

- `home`
- `park`
- `coffee_shop`
- `shop`
- `seaside`
- `dock`
- `residential_area`

## Compatibility Mapping

The new `LocationContext` value object normalizes legacy aliases without rewriting existing JSON.

Examples:

- `meetingRoom`, `meeting-room` -> `meeting_room`
- `managerroom`, `boss_room`, `director_room` -> `manager_room`
- `printingarea`, `printer` -> `printing_area`
- `office_front`, `office_gate`, `office_lounge`, `front_desk` -> `reception`
- `workplace_*`, `desk_*`, `station_*` -> `workstation`
- `home_*`, `house`, `guard_room` -> `home`
- `pier`, `harbor`, `dock_*` -> `dock`
- `cafe_*`, `coffee_*` -> `coffee_shop`

## Location And Schedule Rules

Schedule phase compatibility now validates locations:

- `commute` -> `elevator`, `reception`, `home`, `residential_area`
- `work_start` -> `workstation`
- `working` -> `workstation`, `meeting_room`, `printing_area`, `manager_room`, `office`
- `coffee_break` -> `pantry`, `balcony`, `coffee_shop`
- `lunch` -> `pantry`, `coffee_shop`, `shop`, `balcony`
- `afternoon_work` -> `workstation`, `meeting_room`, `printing_area`, `manager_room`, `office`
- `overtime` -> `workstation`, `manager_room`, `office`
- `off_work` -> `elevator`, `reception`, `home`, `residential_area`
- `sleep` -> `home`
- `weekend` -> `home`, `park`, `coffee_shop`, `seaside`, `dock`, `shop`

Invalid combinations are rebuilt through deterministic fallback.

## Capacity Rules

Default capacities:

- `workstation`: resident-specific capacity model, currently 120 for batch state.
- `meeting_room`: 8
- `pantry`: 12
- `printing_area`: 4
- `manager_room`: 3
- `balcony`: 6
- `elevator`: 8
- `restroom`: 6
- `reception`: 10

`ResidentRuntimeManager.getAllResidentCurrentStates()` applies deterministic fallback when a shared location exceeds capacity. For break states, overflow falls back to `coffee_shop`; for working states, overflow falls back to `workstation` or `office`.

## Weather And Festival Influence

Weather and festival remain context providers only.

- Weather does not directly mutate resident locations.
- Resident decisions use weather to prefer indoor locations during rain, storm, typhoon, hurricane, or fog.
- Festival context increases related location preference but does not force all residents to one place.
- Ocean/fish festival tags bias non-working residents toward `dock`, `seaside`, or office `balcony`.
- Office/community tags bias toward `reception`, `meeting_room`, `pantry`, or `park` when appropriate.

## Dialogue Story Event Integration

Dialogue:

- `DialogueRuntimeManager` now matches `residentLocation` through normalized `LocationContext`.
- `locationTags` are supported for coffee, rumor, meeting, weather, office, sea, and similar content tags.
- Fallback dialogue remains safe when no location-specific dialogue matches.

Story:

- `StoryRuntimeManager` now matches `residentLocation`, `requiredLocation`, `excludedLocations`, and `locationTags` through `LocationContext`.
- Old `location` and `residentLocation` conditions remain compatible.

Dynamic event:

- `DynamicEventRuntimeManager` now includes normalized location IDs, location types, and location tags in `DynamicEventContext.locations`.
- Events can match broad tags such as `office`, `sea`, `dock`, `printer`, or exact IDs.

SecondWorldEngine:

- `ResidentContext` now includes `location`.
- `InteractionResult` now includes `locationId`, `locationName`, `locationTags`, `nearbyResidentIds`, and `availableInteractions`.

Quest:

- `QuestRuntimeManager.recordLocationEvent()` supports existing metric-style location counters such as `visit_location_pantry`.
- No new task JSON type was added.

## Save Compatibility

`WorldSaveManager` now serializes:

- `residentCurrentLocation`
- `temporaryLocationOverride`
- `overrideReason`
- `overrideExpiresAt`
- `lastLocationChange`
- limited `locationVisitHistory`

`ResidentRuntimeManager.loadRuntimeStates()` reads new `residentCurrentLocation` and old `location`. Missing fields from v1.0.0 saves are rebuilt from schedule phase and current runtime defaults.

## Performance Results

Local test baseline:

- 100-resident schedule state test remains under 250 ms.
- 20-resident pantry capacity overflow test passes with deterministic split.
- No new top-level Manager, Engine, Repository, Runtime, page, or JSON type was added.

## Test Results

- `flutter test`: PASS
- Feature 01 regression: PASS
- Feature 02 smoke coverage:
  - Stable location ID normalization.
  - Lunch residents prefer `pantry` / `coffee_shop`.
  - Capacity overflow fallback.
  - Dialogue selection by location tags.
  - Story selection by required location and tags.
  - Dynamic event location matching.
  - SecondWorldEngine interaction location fields.
  - Quest location metric support.
  - Save and old-location restore compatibility.

## Known Limits

- Location capacities are enforced in batch state snapshots; single-resident state calls remain direct and deterministic.
- Location display names are embedded in `LocationContext` for now, not externalized to JSON.
- No map page, live map animation, or pathfinding was added.

## Next Step

Recommended next feature: Feature 03 Resident Personality Integration.

Focus:

- Let personality influence preferred office locations and interactions.
- Keep location rules centralized through `LocationContext`.
- Avoid adding new top-level managers or new UI.
