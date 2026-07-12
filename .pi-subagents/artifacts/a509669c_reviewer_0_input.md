# Task for reviewer

Code review gate for the auth-role speckit project.

Scope: uncommitted changes in this repo (run `git diff HEAD` to see them). Spec lives in `.speckit/projects/auth-role/` — treat it as the acceptance contract.

Focus:
1. Role gating correctness: athlete never sees coach fields/summaries; coach sees them; hidden fields don't block submit.
2. Role persistence: `AthleteProfile.role` round-trips via `PrefsRepository`; default empty → athlete.
3. Auth flow: `RoleSetupScreen` forces role before app entry; `AuthScreen` requires role on signup.
4. Test coverage in `test/auth_role_test.dart`: persistence, ui-visibility, integration (RoleSetupScreen), e2e with MockFirebaseAuth.
5. Any obvious ponytail over-engineering, dead branches, or missed edge cases in the role logic.

Out of scope: styling, unrelated refactors in files that only touched role-adjacent code.

Deliverable: short bullet list of blocking issues (if any) + non-blocking nits. No essay.

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