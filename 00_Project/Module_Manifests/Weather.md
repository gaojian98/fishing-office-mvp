# Weather Module Manifest

## Purpose

Resolve current weather and expose weather context to world systems.

## Main files

- `fishing_office_flutter/lib/core/managers/weather_runtime_manager.dart`
- `fishing_office_flutter/lib/core/repository/weather_repository.dart`
- `fishing_office_flutter/lib/models/weather_config.dart`

## Data files

- `fishing_office_flutter/assets/config/weather.json`

## Public interfaces

- `getCurrentWeather()`
- `getWeatherTags()`
- `isWeatherActive(weatherId)`
- `applyWeatherContext(context)`
- `residentWeatherContext(residentId)`

## Dependencies

- World Clock
- Resident

## Consumers

- Resident
- Dialogue
- Story
- Rumor
- Fish
- Economy
- Dynamic Event
- Daily Simulation

## Save fields

- `weatherRuntime.currentWeatherId`
- `weatherRuntime.tags`

## Invariants

- Weather is world context, not UI decoration only.
- Weather should not directly mutate unrelated state outside existing runtime APIs.

## Tests

- `fishing_office_flutter/test/framework_smoke_test.dart`
