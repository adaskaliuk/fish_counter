# fizzy

Use when working with Fizzy board/task flow in FishCounter.

## Rules
- Keep exactly one active task.
- Put the active task in `In Todo`.
- Keep backlog in `Maybe?`.
- Never write real `FIZZY_TOKEN` into repo files.
- Use only local env var for token.
- Check `.fizzy/BOARD.md` only as fallback if API is unavailable.
- Prefer the real Fizzy API/board for task tracking.

## If updating project docs
- Keep `PROJECT_KNOWLEDGE.md` and `QWEN.md` aligned.
- Mirror any workflow changes in both files.
