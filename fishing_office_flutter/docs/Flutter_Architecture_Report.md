# Flutter Architecture Report

Sprint 002

## Goal

Establish the Flutter framework layer without changing game rules, product logic, database schema, or API contracts.

## What was added

### 1. Riverpod foundation

- Added `flutter_riverpod`
- Root app now starts inside `ProviderScope`
- App bootstrap loads config through Riverpod `FutureProvider`

### 2. Core manager layer

Provider-backed manager views were added for:

- `BalanceManager`
- `FishingManager`
- `WaitingManager`
- `RelationshipManager`
- `LifeManager`
- `MeaningManager`
- `WorldManager`
- `TodayManager`
- `WeatherManager`
- `WalletManager`
- `InventoryManager`
- `CompanionManager`

### 3. Repository layer

Added a repository abstraction layer:

- `Repository<T>`
- `JsonSource`
- `JsonConfigRepository<T>`
- Home config repository bundle
- Store config repository bundle

### 4. JSON loader layer

Config loading is kept centralized so pages do not read JSON directly.

### 5. Navigation foundation

Added route guard and deep-link abstractions:

- `AppRouter`
- `RouteGuard`
- `DeepLinkParser`

Current app still uses the existing route pipeline, but the abstraction layer now exists.

### 6. Runtime entry

`main.dart` now boots through Riverpod and still renders the current Home flow.

## Verification

- `flutter analyze` passed

## Scope kept unchanged

- No gameplay rules changed
- No economy rules changed
- No database changes
- No API changes
- No new product features added

## Current status

Framework base is in place.
Home and Store continue to run through the existing config-driven flow.

