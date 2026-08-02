# v1.2.0 RC Performance Report

## Measured Commands

- `flutter analyze`: 1.6s reported by analyzer.
- `flutter test`: 58s, 78 tests.
- `flutter build web --release`: 13.2s compile time reported by Flutter.
- `build/web` size: 49M.
- `main.dart.js` size: 2.8M.

## Runtime Performance Evidence

Existing smoke tests cover:

- Hour Tick under 100-resident integration threshold.
- 100 resident snapshot creation.
- Office world history bounding.
- Simulation optimizer cache and stage skipping.
- Save deduplication and forced save paths.

## Not Precisely Measured In This Environment

- Real browser first input delay.
- Real browser Office Hub first-open frame timing.
- Memory trend under real browser runtime.
