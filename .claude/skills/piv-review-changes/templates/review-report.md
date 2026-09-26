# Review report — <feature or ticket title>

- **Intent-slug**: <intent-slug>
- **Ticket**: <id or "none">
- **Branch**: <branch>
- **Verdict**: PASS | CHANGES REQUESTED

## Scope
Files modified: <n> · added: <n> · deleted: <n> · lines +<n> / -<n>
<every file read, one per line — `path/to/file.py` (MODIFIED/ADDED/DELETED). Say here when the reading was dispatched across subagents, and which group each took.>

## Findings

### blocking
- **<one-line claim: the red, missing or weakened test, or the untested behavior — its kind named>** — <the test's `file:line`, or the code's for an absent test or an untested behavior>
  - **Evidence**: <the failing output, the test the Testing strategy names, the diff line that weakened it, or the acceptance criterion or interface naming the untested behavior>
  - **Impact**: <what the missing proof leaves unguarded>
  - **Fix**: <the concrete change>

### critical
- **<one-line claim>** — `path/to/file.py:42` · <the Step 5 class: logic, security, performance, quality, standards or coverage>
  - **Evidence**: <the quoted line or the traced path that proves it>
  - **Impact**: <what breaks, and for whom>
  - **Fix**: <the concrete change>

### high
No findings.

### medium
…

### low
…

## Checks run
<the full test suite on the branch, each red test re-run on the base, type-check / lint — what was run and what it returned; with no test suite, "no test suite" and the behaviors left untested>
