- **Intent-slug**: [the epic's `Intent-slug`]
- **Spec**: [the epic's `Spec`: the spec path @ the hash of the revision the issue published]

Closes #[N]

## Summary
[1–2 sentences: what this branch delivers, from the *Summary* of each task's implementation report]

## What changed
[the commit subjects ahead of the base branch, one per line]

## Validation
### [T-xx] — [the task's title]
- [one line per check — its name (tests, type-check, lint, build, …) and whether it passed — from the validation results Step 3 settled on for this task]
- Review verdict: [the task's review report verdict, as it writes it, or "no review report available"]
- Implementation report: [COMPLETE | PARTIAL | "no implementation report available"]

[one subsection per task of the epic, in the epic's order]

## Notes for the reviewer

### Deviations
[per task, as **[T-xx]** — the implementation report's *Deviations from the ticket* — intentional decisions, not defects — or "none", or "unknown — no implementation report available"]

### Flagged for a manual check
[per task, as **[T-xx]** — the fix report's *Needs a human look* items — raised by the triage, not confirmed as checked — or "none"]

### Surviving findings
[the findings the review reports left standing — on a PASS, their pre-existing ones; never an introduced or aggravated low one, nor a finding the fix report of the same Round settled as a deferral, as noise or as a manual check — one per line, blocking first and then by severity, as **[T-xx]** **[blocking or severity]** — [one-line claim] — `[path]:[line]`, or "none"]

## Deferred findings
[every deferral of the intent, in full, one block per file under `deferrals/`, in D-xx order — or "None."]

### [D-xx] — [title]
- **Type**: [bug or none]
- **Origin**: [T-xx], review round [n]
- **Claim**: [the deferral's *Claim*, as written]
- **Impact**: [the deferral's *Impact*, as written]
- **Location**: `[path]:[line]`
- **Evidence**: [the deferral's *Evidence*, as written]
- **Proposed fix**: [the deferral's *Proposed fix*, as written]
- **Acceptance criteria**: [the deferral's checklist items, as written, separated by semicolons]

## Open problems
[per task, as **[T-xx]** — the implementation report's *Problems encountered* — what it left unfinished — or "none", or "unknown — no implementation report available"; a PARTIAL status names them here, and after a fix round and a PASS review that followed it each one is marked "reported by the implementation before the PASS review"]

[_Ready for review._ | _Draft — waiting on the open problems above._]
