# Wallet API

## Responsibilities

- Read wallet-facing economy settings
- Create recharge and withdraw applications
- Expose payment channels

## Endpoints

### `GET /api/payment-channels`

Auth required.

### `GET /api/finance-settings`

Auth required.

### `POST /api/recharge`

Auth required.

Request:

```json
{
  "amount": 100,
  "channel": "bank",
  "note": "string?",
  "proof": "string?"
}
```

### `POST /api/withdraw`

Auth required.

Request:

```json
{
  "amount": 100,
  "account": "string",
  "method": "bank",
  "note": "string?"
}
```

## Rules

- Wallet displays and records assets.
- Balance mutation must remain server-side.
- Recharge and withdraw are reviewable ledger actions.

