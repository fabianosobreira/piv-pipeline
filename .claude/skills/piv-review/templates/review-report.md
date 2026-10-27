# Review report — [T-xx] — [the task's title]

- **Intent-slug**: [intent-slug]
- **Issue**: [#N]
- **Task**: [T-xx]
- **Branch**: [branch]
- **Round**: [n]
- **Base**: [hash of the commit the diff was taken against: `HEAD` when the task started, the last commit before its work]
- **Diff hash**: [the hash `scripts/diff-hash.sh` prints for that commit: the full diff against it, untracked files included, ignored files left out]
- **Verdict**: PASS | CHANGES REQUESTED

## Scope
[every file in the change under review, one per line — `path/to/file.py` (MODIFIED/ADDED/DELETED). Say here when the reading was dispatched across subagents, and which group each took.]

## Findings

### Test facts
- **[one-line claim: the red, missing or weakened test, or the untested behavior — its kind named]** — [the test's `file:line`, or the code's for an absent test or an untested behavior]
  - **Evidence**: [the failing output, the test the ticket's verification names, the diff line that weakened it, or the acceptance criterion or interface naming the untested behavior]
  - **Impact**: [what the missing proof leaves unguarded]
  - **Fix**: [the concrete change]
[or "No findings."; the same holds for every severity heading below]

### Critical
- **[one-line claim]** — `path/to/file.py:42` · [the Step 5 class: logic, security, performance, quality, standards or coverage] · [the origin, last on the line: introduced, aggravated or pre-existing]
  - **Evidence**: [the quoted line or the traced path that proves it]
  - **Impact**: [what breaks, and for whom]
  - **Fix**: [the concrete change]

### High
[findings in the Critical form, or "No findings."]

### Medium
[findings in the Critical form, or "No findings."]

### Low
[findings in the Critical form, or "No findings."]

## Dropped by prior ruling
[one per line: the candidate (`path/to/file.py:42` and its claim) — the filter that dropped it (prior decision, or mitigation by a *Noise / won't-fix* reason) — the deferral (`D-xx`) or the *Noise / won't-fix* reason; or "None."]

## Checks run
[the tests in scope, run once on the branch — each test file and why it is in scope — and type-check / lint — what was run and what it returned; every failing test outside the change, with the assertion it fails and why the change does not reach it; every check not run, and why; with no test suite, "no test suite" and the behaviors left untested; with no type-checker or linter configured, say so]
