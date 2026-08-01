# Fairy Event Runtime Report

## Scope

Phase 5 Pack 25 established `FairyEventService` as a light coordination service for fairy-style waiting events.

No new Engine, top-level Manager, UI, JSON type, gameplay rule, or Git push was added.

## Data Sources

The service only coordinates existing runtime data and existing content:

- `events.json`
- `resident_story.json` through existing Story Runtime context
- `resident_dialogue.json` through existing Dialogue Runtime context
- `fish_catalog.json` through existing Fish Runtime context
- `DynamicEventRuntimeManager`
- `SecondWorldEngine`

## Event Categories

Supported runtime categories:

- `FishTalk`
- `FishCry`
- `FishJoke`
- `FishEscape`
- `ResidentEncounter`
- `WeatherWonder`
- `FestivalSurprise`
- `OfficeHumor`
- `OceanMystery`
- `SilentMoment`

## Rhythm Rules

Implemented selection rhythm:

- Waiting 2 to 5 minutes: `light`
- Waiting 5 to 10 minutes: `surprise`
- Waiting 20 minutes or more: `fairy`

The service scores available events against the current rhythm tier and existing world context.

## Anti-Repetition

Implemented:

- Recent 10-minute event IDs are avoided.
- The same fairy event category cannot be selected more than twice consecutively when alternatives exist.
- The final selected event must still be valid according to `DynamicEventRuntimeManager`.

## Runtime Result Path

Event result execution stays inside existing Runtime:

`FairyEventService`
-> `DynamicEventRuntimeManager.triggerEvent`
-> `DynamicEventRuntimeManager.resolveEvent`
-> existing Memory / Relationship / Rumor / Story / Quest / Achievement update paths

The service does not directly modify UI or player state.

## Fishing Waiting Integration

The existing `FishingProvider` now accepts an optional `FairyEventService`.

When a waiting session starts, it asks the service for a light fairy event and converts the selected dynamic event into the existing `WaitingEvent` format.

The UI remains unchanged because it already renders waiting events.

The waiting event list is capped at 5 items to preserve the current MVP pacing contract.

## SecondWorldEngine Integration

`SecondWorldEngine` now exposes light proxy methods:

- `selectFairyEvent`
- `triggerFairyEvent`

This allows future waiting flow code to call fairy event selection through the unified world entry without page-level runtime fan-out.

## Validation Stats

Smoke test coverage triggered 3 fairy selections:

- Trigger count: 3
- Repeat rate: less than 1.0
- Average interval: covered through 3, 7, and 21 minute simulated waits
- Category distribution: more than 1 category

Validated behavior:

- Light event selection works.
- Surprise event selection works.
- Fairy-tier event selection works.
- Recent event ID de-duplication works.
- Category repetition guard works when alternatives exist.
- Different weather context changes available event pool through existing DynamicEventRuntimeManager.
- SecondWorldEngine can invoke FairyEventService.

## Test Results

- `flutter analyze`: PASS
- `flutter test`: PASS
- `flutter build web --release`: PASS

## Known Follow-Up

- Current waiting integration triggers one light fairy event when the waiting session begins. Longer real-time sessions should later call the same service again at 5 to 10 minutes and 20 minutes or more.
- Sound and animation are still reserved via existing feedback metadata from Pack 24.
