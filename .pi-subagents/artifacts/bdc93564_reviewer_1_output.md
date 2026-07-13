## Review
- Blocker: none.
- Fixes worth doing now: none.
- Evidence: `finalCount` null preserved via omitted JSON + guarded read in `lib/game_session.dart:302-329`; tests cover old sessions, weight-only, count-only, both, and clear flags in `test/game_session_test.dart:129-193`.
- Evidence: timeline buckets are minimal/in-place: insertion-ordered buckets by `HH:mm` in `lib/widgets/analytics_timeline_section.dart:57-68`; widget test verifies bucket labels + event labels/timestamps in `test/match_results_timeline_test.dart:15-33`.
- Residual risk: timeline bucket order assumes `activityLogs` already chronological; current app appends logs that way. No fix worth doing now.