# Architecture Standard

## Status

Active

## Highest Product Specification

- [../SecondWorld_Product_Bible.md](../SecondWorld_Product_Bible.md)

## Development Principles

- [../Development_Principles.md](../Development_Principles.md)

## Core Rule

Manager 少，Module 多。

产品描述能力，工程决定实现。

禁止为每个小功能新建 Manager。

## Purpose

This document defines the engineering direction for long-term development of `上班摸鱼`.

The project should grow as a living second world, but the codebase must stay simple, testable, extensible, and JSON-driven.

## Layer Direction

Product capability should flow through this structure:

```text
JSON
↓
Repository
↓
Module / Service / Model
↓
Manager
↓
Provider
↓
UI
```

## Manager Rule

Managers coordinate modules.

Managers should not become containers for every small feature.

A Manager may:

- coordinate multiple modules
- manage lifecycle
- expose state to Provider
- handle cross-module orchestration

A Manager should not:

- represent one small field
- exist only because a product capability has a name
- duplicate another Manager
- contain all business details directly

## Module Rule

Modules carry focused capabilities.

Examples:

- World Clock
- World Timeline
- Season
- Weather
- Resident Schedule
- Resident Activity
- Dialogue Context
- Memory Trigger
- Event Trigger
- Relationship Rules

These should usually be Module / Service / Model first, not new Manager classes.

## Product-To-Code Rule

Product documents define what the world should be able to do.

Engineering decides the smallest maintainable implementation shape.

A product term does not automatically become a class name.

## JSON Rule

All world, resident, story, memory, relationship, dialogue, and event capabilities must stay JSON-driven.

UI must not read JSON directly.

## Extension Rule

Before adding a new Manager, check whether the capability belongs inside:

- an existing Module
- an existing Service
- an existing Model
- an existing Repository
- an existing Manager coordination layer

Only create a new Manager when there is a real lifecycle or orchestration boundary.

## Current Direction

Living Second World uses:

- `LivingWorldManager` as the coordinator
- `WorldCapabilityModule` for World Clock / Timeline / future Weather / Season
- `ResidentCapabilityModule` for Resident Life / Relationship / Dialogue / Memory
- `EventCapabilityModule` for Event Trigger rules

This keeps the architecture aligned with the principle:

Manager 少，Module 多。
