# Authentication API

## Responsibilities

- Register player account
- Login
- Change password
- Read current player profile
- Update profile

## Endpoints

### `POST /api/auth/register`

Request:

```json
{
  "username": "string",
  "password": "string",
  "referralCode": "string?"
}
```

Response:

```json
{
  "token": "string",
  "user": {}
}
```

### `POST /api/auth/login`

Request:

```json
{
  "username": "string",
  "password": "string"
}
```

Response:

```json
{
  "token": "string",
  "user": {}
}
```

### `POST /api/auth/change-password`

Auth required.

Request:

```json
{
  "oldPassword": "string",
  "newPassword": "string"
}
```

### `GET /api/me`

Auth required.

Returns the current player profile.

### `POST /api/me/profile`

Auth required.

Request:

```json
{
  "phone": "string",
  "displayName": "string"
}
```

## Rules

- Passwords are never returned.
- Staff/admin accounts must respect approval status.
- Profile update only covers allowed personal fields.

