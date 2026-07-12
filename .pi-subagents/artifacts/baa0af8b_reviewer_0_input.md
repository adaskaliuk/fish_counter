# Task for reviewer

[Read from: /Users/drongous/workspace/experemental/FishCounter/fish_counter/plan.md, /Users/drongous/workspace/experemental/FishCounter/fish_counter/progress.md]

Review-loop round 2 — correctness/regressions after worker fixes. Inspect repo directly. Do NOT edit. Do NOT run subagents.

Scope: current working tree diff vs HEAD (`git diff HEAD`). Focus only auth-role changes/fixes.

Verify prior blockers:
- `flutter analyze --no-pub` no issues (parent ran: no issues)
- `flutter test` all pass (parent ran: 84/84)
- missing app_settings role defaults to empty string
- AuthScreen signup preserves existing profile fields; role picker hidden on login
- session edit and report exports hide coach-only training/fishing/weather/forecast/tuning/dashboard for athlete
- AnalyticsCoachDashboardSection wired only for coach

Return blockers only, fixes worth doing now, optional/defer. Short.

## Acceptance Contract
Acceptance level: attested
Completion is not accepted from prose alone. End with a structured acceptance report.

Criteria:
- criterion-1: Return concrete findings with file paths and severity when applicable

Required evidence: review-findings, residual-risks

Finish with a fenced JSON block tagged `acceptance-report` in this shape:
Use empty arrays when no items apply; array fields contain strings unless object entries are shown.
```acceptance-report
{
  "criteriaSatisfied": [
    {
      "id": "criterion-1",
      "status": "satisfied",
      "evidence": "specific proof"
    }
  ],
  "changedFiles": [
    "src/file.ts"
  ],
  "testsAddedOrUpdated": [
    "test/file.test.ts"
  ],
  "commandsRun": [
    {
      "command": "command",
      "result": "passed",
      "summary": "short result"
    }
  ],
  "validationOutput": [
    "validation output or concise summary"
  ],
  "residualRisks": [
    "none"
  ],
  "noStagedFiles": true,
  "diffSummary": "short description of the diff",
  "reviewFindings": [
    "blocker: file.ts:12 - issue found, or no blockers"
  ],
  "manualNotes": "anything else the parent should know"
}
```