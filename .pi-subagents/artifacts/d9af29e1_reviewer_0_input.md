# Task for reviewer

[Read from: /Users/drongous/workspace/experemental/FishCounter/fish_counter/plan.md, /Users/drongous/workspace/experemental/FishCounter/fish_counter/progress.md]

Review-loop round 3 final — verify only the remaining blocker after parent patch. Inspect repo directly. Do NOT edit. Do NOT run subagents.

Scope: current working tree diff vs HEAD (`git diff HEAD`).

Check:
- `AnalyticsDashboardSection` now takes `isCoach` and hides readiness/forecast/phase/weather context for athletes.
- `AnalyticsScreenBody` passes `isCoach`.
- tests cover athlete no Readiness / no 7-day forecast.
- Parent validation after patch: `flutter analyze --no-pub` clean; `flutter test` 84/84.

Return blockers only + fixes worth doing now. Short.

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