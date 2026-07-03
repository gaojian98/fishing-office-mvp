# Companion API

## Responsibilities

- Expose companion-related profiles and companion-facing state

## Current contract

The current codebase already models companions through the database and the engine layer.
This API module is reserved for future companion endpoints once the companion flow is exposed in UI.

## Reserved endpoint categories

- Companion list
- Companion detail
- Companion memory
- Companion return messages
- Companion gift actions

## Rules

- Companion is a long-term asset.
- Companion data must not be reduced to simple inventory rows.
- Companion endpoints must not expose internal balance logic.

