# Implementation report — [T-xx] — [the task's title]

- **Intent-slug**: [intent-slug]
- **Issue**: [#N]
- **Task**: [T-xx]
- **Branch**: [branch]
- **Status**: COMPLETE | PARTIAL

## Summary
[what was built or fixed, 2–4 sentences — **Repair:** lead with the root cause in one line]

## Tasks completed
- [task] → `path/to/file` (MODIFIED/ADDED/DELETED)

## Tests added
[test files + cases + results, or "none — " and why: the project has no test suite, the change has no testable behavior, or the user waived them]

## Validation results
[tests / type-check / lint / build — green/red with counts, naming each test that was already red on the baseline]

## Deviations from the ticket
[what changed vs the ticket and why, or "none" — the reviewer's signal of intent. Each unsettled fact settled, with its value and source (precedent or user). A test changed while the ticket left its behavior unchanged is listed here too, and the review still blocks it]

## Problems encountered
[each check still red — the check, the failure and each hypothesis tried; each task skipped and the red task it depends on; each success criterion that isn't true, named; each out-of-scope problem found, as a candidate task; or "none". A PARTIAL status names its causes here]
