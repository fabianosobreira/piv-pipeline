# Review report — <ticket title>

- **Intent-slug**: <intent-slug>
- **Ticket**: <id>
- **Branch**: <branch>
- **Round**: <n>
- **Base**: <hash of the base commit the diff was taken against>
- **Diff**: <the hash `scripts/diff-hash.sh` prints for that commit: the full diff against it, untracked files included, the loop's own artifacts left out>
- **Verdict**: PASS | CHANGES REQUESTED

## Scope
<every file read, one per line — `path/to/file.py` (MODIFIED/ADDED/DELETED). Say here when the reading was dispatched across subagents, and which group each took.>

## Findings

### Blocking
- **<one-line claim: the red, missing or weakened test, or the untested behavior — its kind named>** — <the test's `file:line`, or the code's for an absent test or an untested behavior>
  - **Evidence**: <the failing output, the test the Testing strategy names, the diff line that weakened it, or the acceptance criterion or interface naming the untested behavior>
  - **Impact**: <what the missing proof leaves unguarded>
  - **Fix**: <the concrete change>

### Critical
- **<one-line claim>** — `path/to/file.py:42` · <the Step 5 class: logic, security, performance, quality, standards or coverage>
  - **Evidence**: <the quoted line or the traced path that proves it>
  - **Impact**: <what breaks, and for whom>
  - **Fix**: <the concrete change>

### High
<findings in the Critical form, or "No findings.">

### Medium
<findings in the Critical form, or "No findings.">

### Low
<findings in the Critical form, or "No findings.">

## Dropped by prior ruling
<one per line: the candidate (`path/to/file.py:42` and its claim) — the filter that dropped it (prior decision, or mitigation by a *Noise / won't-fix* reason) — the deferral ticket or the *Noise / won't-fix* reason, or "None.">

## Checks run
<the full test suite on the branch, each red test re-run on the base, type-check / lint — what was run and what it returned; with no test suite, "no test suite" and the behaviors left untested>
