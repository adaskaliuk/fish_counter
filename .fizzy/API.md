# Fizzy API notes for FishCounter

Source reviewed: https://github.com/basecamp/fizzy
Board: Fish cathcing
Public board URL: https://app.fizzy.do/6128892/public/boards/Y79hjW8dhUyf1h4iVC5viN2u

## Auth

Fizzy supports JSON API access with bearer tokens.

Header:

```http
Authorization: Bearer $FIZZY_TOKEN
Accept: application/json
Content-Type: application/json
```

Bearer token auth only works for JSON requests.

## Known public columns

From the public board page:

- `not_now` — Not Now
- `stream` — Maybe?
- `closed` — Done

The requested active-work column should be created as:

- name: `In Todo`
- id: `03g9kpnnzqevbchfx0a92so82`

## Useful API routes from Fizzy source

Assuming:

```env
FIZZY_API_ENDPOINT=https://app.fizzy.do
FIZZY_ACCOUNT_ID=6128892
FIZZY_BOARD_ID=03g9hcxgsooou3nem4gl9n4rn
```

### List boards

```bash
curl -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Accept: application/json" \
  "$FIZZY_API_ENDPOINT/$FIZZY_ACCOUNT_ID/boards.json"
```

Use this to find the internal board id for `Fish cathcing`.

### Create column

```bash
curl -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"column":{"name":"In Todo"}}' \
  "$FIZZY_API_ENDPOINT/$FIZZY_ACCOUNT_ID/boards/$FIZZY_BOARD_ID/columns.json"
```

### Create card

```bash
curl -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"card":{"title":"Task title","description":"Task details"}}' \
  "$FIZZY_API_ENDPOINT/$FIZZY_ACCOUNT_ID/boards/$FIZZY_BOARD_ID/cards.json"
```

### Move card into a column

Fizzy cards are looked up by card number in many routes.

```bash
curl -X POST \
  -H "Authorization: Bearer $FIZZY_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"column_id":"<column-id>"}' \
  "$FIZZY_API_ENDPOINT/$FIZZY_ACCOUNT_ID/cards/<card-number>/triage.json"
```

## Local safety

Do not commit `.env`. Store real token only locally.
