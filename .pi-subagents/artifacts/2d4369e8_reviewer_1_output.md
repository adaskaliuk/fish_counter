## Review

### Blockers
- **blocker: `lib/game_session.dart:329`** — weight-only result cannot round-trip cleanly. `toJson()` always emits `"finalCount": null` (`lib/game_session.dart:303`), then `fromJson()` sees the key and calls `TypeUtils.safeInt(null)`, which returns `0` (`lib/utils/type_utils.dart:12-13`). Result: a weight-only session reloads as `finalCount == 0`, violating “weight, count, or both” and showing/exporting a fake count.

### Fixes worth doing now
- **fix-now: `lib/widgets/analytics_timeline_section.dart:40-70`** — timeline still renders a flat event list. Spec requires readable time buckets (`.speckit/projects/match-results-timeline/requirements.md:8`; test plan `.speckit/projects/match-results-timeline/tests/timeline-buckets.md:3`). Minimal fix: group existing logs by minute/window, no new model/dependency.

### Optional / defer
- Do not commit untracked `.pi-subagents/artifacts/*`.
- Root `/plan.md` was missing; reviewed `.speckit/projects/match-results-timeline/plan.md` plus `progress.md`.