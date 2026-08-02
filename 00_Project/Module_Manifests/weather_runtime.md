# weather_runtime

## Purpose
Resolve current weather and weather tags.

## Main files
- `fishing_office_flutter/lib/core/managers/weather_runtime_manager.dart`
- `fishing_office_flutter/lib/models/weather_config.dart`
- `fishing_office_flutter/lib/core/repository/weather_repository.dart`

## Data files
- `fishing_office_flutter/assets/config/weather.json`

## Public interfaces
- `getCurrentWeather()`
- `getWeatherTags()`
- `isWeatherActive(weatherId)`
- `residentWeatherContext(residentId)`
- `applyWeatherContext(context)`

## Direct dependencies
- World Clock, Resident.

## Consumers
- Resident, Dialogue, Story, Rumor, Fish, Economy, Dynamic Event, Daily Simulation.

## Save fields
- `weatherRuntime`

## Invariants
- Weather is world context.
- UI should not read weather JSON directly.

## Relevant tests
- `fishing_office_flutter/test/framework_smoke_test.dart`

## Known limitations
- Weather visuals are separate from weather runtime.
