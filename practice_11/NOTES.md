# Practice 11 — NOTES

## Level 1: Postman

### GET https://jsonplaceholder.typicode.com/users
- Status: **200 OK**
- Content-Type: `application/json; charset=utf-8`
- Body: a JSON **list** of **10 users**
- Nested objects: `address`, `company`
- Nested twice: `address.geo` (`lat`, `lng` — **strings**, not numbers!)
- Absent / null: in this API no field is missing; `website` is the one
  we treat as optional (`String?`)

### GET …/users/1
Status 200, one object (not a list).

### User (top level)

| field    | JSON type | Dart type                 | nullable? |
|----------|-----------|---------------------------|-----------|
| id       | number    | int                       | no        |
| name     | string    | String                    | no        |
| username | string    | String                    | no        |
| email    | string    | String                    | no        |
| address  | object    | Address                   | no        |
| phone    | string    | String                    | no        |
| website  | string    | String?                   | yes       |
| company  | object    | ({String name, String catchPhrase, String bs}) | no |

### address

| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | String    | no        |
| suite   | string    | String    | no        |
| city    | string    | String    | no        |
| zipcode | string    | String    | no        |
| geo     | object    | Geo       | no        |

### address.geo

| field | JSON type           | Dart type                    | nullable? |
|-------|---------------------|------------------------------|-----------|
| lat   | string ("-37.3159") | double (via double.parse)    | no        |
| lng   | string ("81.1496")  | double (via double.parse)    | no        |

### company

| field       | JSON type | Dart type | nullable? |
|-------------|-----------|-----------|-----------|
| name        | string    | String    | no        |
| catchPhrase | string    | String    | no        |
| bs          | string    | String    | no        |

### GET …/users/999
- Status: **404 Not Found**
- Body: `{}` (an empty object)
- → `NotFoundException` in `_check`

### POST …/users  (Content-Type: application/json)
Body sent: `{"name": "Test", "username": "test", "email": "t@t.kz"}`
- Status: **201 Created**
- The server returns what we sent **plus `"id": 11`**
  (nothing is really saved — it is a fake server)

### GET …/users?id=3
- Status 200, a **list of one** user `[ {...} ]`, not an object.
  Query parameters → `Uri.https(host, '/users', {'id': '3'})`.

## Status → exception
| status | exception               |
|--------|-------------------------|
| 401    | UnauthorizedException   |
| 404    | NotFoundException       |
| >= 500 | ServerException(status) |
| no response / timeout | NoConnectionException |
| bad JSON / bad cast | BadResponseException |

## Level 5: two kinds of "no network"
| test                            | time to Offline view |
|---------------------------------|----------------------|
| Airplane mode                   | ___ s (≈ < 1 s)      |
| Wi-Fi without internet (hotspot)| ___ s (≈ 10 s)       |

> Fill in the numbers you measured with a clock.

Screenshots: `screenshot_timeout.png`, `screenshot_200.png`.
