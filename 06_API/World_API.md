# World API

## Responsibilities

- Read world state
- Read weather state
- Read global world bridge state

## Current contract

World is not tied to a single player session.
The API layer should read world-level state and present it to the client.

## Reserved endpoint categories

- World snapshot
- Weather snapshot
- World calendar
- Festival data
- World event feed

## Rules

- World continues running even when a player is offline.
- Public world data can be consumed by home and today systems.

