# Task for worker

You are a delegated subagent running from a fork of the parent session. Treat the inherited conversation as reference-only context, not a live thread to continue. Do not continue or answer prior messages as if they are waiting for a reply. Your sole job is to execute the task below and return a focused result for that task using your tools.

Task:
Apply review-loop fixes for auth-role only. You are the only writer. Do NOT run subagents.

Current target is latest commit `5b18bee Add auth role flow` plus working tree. Fix only blockers/fixes synthesized below; preserve scope.

Must fix:
1. `flutter analyze --no-pub` blockers:
   - replace deprecated `DropdownButtonFormField.value` with `initialValue` in auth role dropdowns.
   - fix `BuildContext` after async gap in `lib/history_screen.dart`.
2. Migration safety:
   - `lib/models/app_settings.dart` missing role must default to `''`, not `'athlete'`.
   - `lib/auth_screen.dart` signup path must preserve existing profile fields when saving role: load existing profile, save `existing.copyWith(role: _role!)`.
3. AuthScreen UX:
   - Role dropdown should only render in register mode (`_isRegister`), not login mode.
4. Athlete visibility leaks:
   - `defaultTrainingType` / `defaultFishingMethod` are coach-only per spec. Hide them from athlete session edit UI and athlete report exports. Do not wipe existing values when athlete edits.
5. Coach analytics summary:
   - Wire `AnalyticsCoachDashboardSection` into `AnalyticsScreenBody` only when `isCoach`. Do not show it to athletes. Keep base analytics for athletes if needed, but coach-specific dashboard/summary only for coach.
6. Report exporter:
   - Ensure weather/forecast/readiness/historical tuning/coach sections are only exported when `isCoach == true` if they are hidden in athlete UI.
7. Tests:
   - Add/update focused tests for: missing app_settings role default; AuthScreen signup preserves fields; role picker hidden on login; athlete report export hides coach-only fields/sections; coach analytics dashboard appears only when coach.

Validation required:
- `flutter analyze --no-pub`
- `flutter test`

Report changed files, commands + exit codes, and anything left undone.

## Acceptance Contract
Acceptance level: reviewed
Completion is not accepted from prose alone. End with a structured acceptance report.

Criteria:
- criterion-1: Implement the requested change without widening scope
- criterion-2: Return evidence sufficient for an independent acceptance review

Required evidence: changed-files, tests-added, commands-run, validation-output, residual-risks, no-staged-files

Review gate: required by reviewer.

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