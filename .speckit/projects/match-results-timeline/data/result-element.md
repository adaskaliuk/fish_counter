# result-element / Результатний елемент

- Check whether `GameSession` already has final weight/count fields.
- If missing, add nullable/backward-compatible fields.
- Support three modes: weight only, count only, weight + count.
- Persist through JSON/storage/export.
- Decide display unit for weight (kg by default unless app already uses another unit).
