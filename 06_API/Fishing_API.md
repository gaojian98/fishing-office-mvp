# Fishing API

## Responsibilities

- Start a fishing session
- Cast / pull result
- Return fishing settings snapshot

## Endpoints

### `GET /api/fishing/settings`

Auth required.

Returns the current fishing balance/settings snapshot.

### `POST /api/fishing/start`

Auth required.

Starts a new fishing session.

Response:

```json
{
  "round": {},
  "settings": {}
}
```

### `POST /api/fishing/cast`

Auth required.

Request:

```json
{
  "roundId": "uuid"
}
```

Response should contain cast result, session progress, and settlement info.

## Rules

- Fishing result is server-side authoritative.
- Client must not decide fish outcome.
- Settings snapshot should be attached to the session result.

