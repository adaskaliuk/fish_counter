## Review
- Blocker: none.
- Fixes worth doing now: none for scoped fixes.

Evidence:
- `lib/game_session.dart:302-329` keeps `finalCount` nullable on JSON read; null no longer falls through `safeInt(null) => 0`.
- `test/game_session_test.dart:129-158` covers old JSON nulls, weight-only, count-only, both.
- `lib/widgets/analytics_timeline_section.dart:40-68` groups logs by `HH:mm` bucket while keeping event tiles.
- `test/match_results_timeline_test.dart:15-33` asserts timeline labels, timestamps, and minute headers.
- `git diff --check` clean; no staged files.

Note: requested root `plan.md` missing; reviewed `.speckit/projects/match-results-timeline/plan.md` and root `progress.md`. Did not rerun Flutter; relied on parent validation.