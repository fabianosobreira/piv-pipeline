- **Intent-slug**: <intent-slug>
- **Intent**: <the ticket's `Intent` — the implementation report's when there is no ticket — copied verbatim, or "none">
- **Architecture**: <the ticket's `Architecture` — the implementation report's when there is no ticket — copied verbatim, or "none">

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
<the review report's medium and low findings, one per line as **<severity>** — <one-line claim> — `<path>:<line>`, or "none">

## Open issues
<the implementation report's *Issues encountered* — what it left unfinished — or "none", or "unknown — no implementation report available"; a PARTIAL status names them here>

## Linked
<ticket / issue refs, or "none">
<with a ticket and a fix report: "Findings deferred during review live on the tracker as tickets linked to <ticket id>.">
<with no ticket and a fix report: "Findings deferred during review live on the tracker as tickets whose *Origin* names `<review report path>`.">

<_Ready for review._ | _Draft — waiting on the open issues above._>
