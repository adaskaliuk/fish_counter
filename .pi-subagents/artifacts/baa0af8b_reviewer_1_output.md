## Review
- Correct: role preservation uses existing profile, not replacement (`lib/auth_screen.dart:65`, `lib/auth_gate.dart:107`).
- Correct: athlete exports now omit coach-only sections/details (`lib/services/report_exporter.dart:35`, `:52`, `:101`, `:203`, `:265`, `:294`).
- Correct: athlete session edit hides coach-only fields while controllers preserve values (`lib/widgets/session_edit_dialog.dart:56`, `:101`, `:127`).
- Correct: UI coach dashboard/weather gated by role (`lib/widgets/analytics_screen_body.dart:45`).
- Blocker: none.
- Fixes worth now: none.
- Optional/defer: `lib/services/report_exporter.dart:16`, `:156` still computes forecast for athlete exports even when hidden; harmless, only optimize if export cost matters.
- Residual risk: untracked `.pi-subagents/` artifacts and `.kiro/skills/fizzy/` exist; avoid staging unless intentional.