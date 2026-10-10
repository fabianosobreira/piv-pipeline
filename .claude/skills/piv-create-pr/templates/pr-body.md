- **Intent-slug**: <intent-slug>
- **Intent**: <the ticket's `Intent`, copied verbatim, or "none">
- **Architecture**: <the ticket's `Architecture`, copied verbatim, or "none">

## Summary
<1–2 sentences: what this branch delivers, from the implementation report's *Summary*>

## What changed
<the commit subjects ahead of the base branch, one per line>

## Validation
- Tests / type-check / lint / build: <green/red from the fix report's *Checks run*, else the implementation report's *Validation results*, else a fresh run>
- Review verdict: <PASS | CHANGES REQUESTED | "no review report available">
- Implementation report: <COMPLETE | PARTIAL | "no implementation report available">

## Notes for the reviewer

### Deviations
<the implementation report's *Deviations from the ticket* — intentional decisions, not defects — or "none", or "unknown — no implementation report available">

### Flagged for a manual check
<the fix report's *Needs a human look* items — raised by the triage, not confirmed as checked — or "none">

### Surviving findings
<every finding the review report left standing — on a PASS, its medium and low ones — one per line, blocking first, as **<blocking or severity>** — <one-line claim> — `<path>:<line>`, or "none">

## Open problems
<the implementation report's *Problems encountered* — what it left unfinished — or "none", or "unknown — no implementation report available"; a PARTIAL status names them here, and after a fix round and a PASS review that followed it each one is marked "reported by the implementation before the PASS review">

## Linked
<the ticket id, in the link form the **Ticket status** section of `docs/ISSUE-TRACKER.md` gives, or the bare id when it gives none>
<with a fix report: "Findings deferred during review live on the tracker as tickets linked to <ticket id>.">

<_Ready for review._ | _Draft — waiting on the open problems above._>
