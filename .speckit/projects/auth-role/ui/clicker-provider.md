# clicker-provider / Провайдер

**Status:** N/A — provider holds no coach-only UI state. Coach fields on the
session record (`coachName`, `defaultTrainingType`, `defaultFishingMethod`)
are populated from `AthleteProfile` which stays empty for athletes (no UI
input). Downstream consumers (`session_edit_dialog`, `analytics_coach_dashboard_section`,
`report_exporter`) already gate on `isCoach`. Nothing to filter at the provider level.
