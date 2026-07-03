# 06_API

FishingOffice API Specification

## Scope

This directory defines the public API contract for the platform.

It is aligned to the current Node implementation in `server.js` and the frozen project documents.

## Covered modules

- Authentication
- Fishing
- Wallet
- Companion
- Relationship
- Store
- World
- Today

## Global rules

- All APIs are JSON over HTTP.
- Authenticated routes use `Authorization: Bearer <token>`.
- API behavior must not contradict frozen Product Guidelines.
- API design must not introduce new gameplay rules.
- Missing business logic should be returned as a stable placeholder, not invented.

## Common response shape

Success:

```json
{ "ok": true, "data": {} }
```

Error:

```json
{ "ok": false, "error": "message" }
```

## Current implementation status

The current `server.js` already exposes the core API routes.  
These documents define the contract for future API sprint work.

