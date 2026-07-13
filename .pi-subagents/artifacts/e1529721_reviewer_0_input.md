# Task for reviewer

[Read from: /Users/drongous/workspace/experemental/FishCounter/fish_counter/plan.md, /Users/drongous/workspace/experemental/FishCounter/fish_counter/progress.md]

Review gate for match-results-timeline implementation. Inspect repo directly. Do NOT edit. Do NOT run subagents.

Scope: current working tree diff vs HEAD. Focus on new match results timeline/weather/result fields changes, but note existing auth_gate fix if relevant.

Check blockers:
- GameSession finalWeightKg/finalCount backward compatibility, copyWith, JSON.
- AnalyticsScreenBody wiring of existing timeline and new WeatherDuringMatchSection.
- WeatherDuringMatchSection correctness/fallback/trend summary; no crashes on empty data.
- SessionEditDialog result inputs preserve/save values.
- History details and ReportExporter show result values.
- Tests cover key paths.
Parent validation: `flutter analyze --no-pub` clean, `flutter test` all 88 passed.

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