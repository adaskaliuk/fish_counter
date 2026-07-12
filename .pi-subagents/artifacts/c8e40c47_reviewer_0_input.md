# Task for reviewer

Second review round for auth-role speckit project. First round flagged 2 blockers, both fixed. Re-verify.

Scope: uncommitted changes (`git diff HEAD`). Spec: `.speckit/projects/auth-role/`.

Blockers to verify fixed:
1. `lib/auth_gate.dart` — RoleSetupScreen must exit to clicker after save. AuthGate is now Stateful with cached future + `onSaved` callback triggering setState.
2. `lib/auth_gate.dart` RoleSetupScreen — must preserve existing profile fields on save. Now uses `existing.copyWith(role: _role!)`.

Also verify:
- `lib/models/athlete_profile.dart` new `copyWith` covers all fields.
- `test/auth_role_test.dart` new test `role save preserves existing profile fields` actually exercises the copyWith path (seed → save → assert non-role fields survived).
- Full test suite (80 tests) passes.

Deliverable: SHORT bullet list. Blocking issues only. No essays, no re-listing prior nits unless they now cause a regression.

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