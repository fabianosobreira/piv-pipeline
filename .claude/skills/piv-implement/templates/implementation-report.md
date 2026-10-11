# Implementation report — <ticket title>

- **Intent-slug**: <intent-slug>
- **Intent**: <the ticket's `Intent`, copied verbatim, or "none">
- **Architecture**: <the ticket's `Architecture`, copied verbatim, or "none">
- **Ticket**: <id>
- **Branch**: <branch>
- **Status**: COMPLETE | PARTIAL

## Summary
<what was built or fixed, 2–4 sentences — **Repair:** lead with the root cause in one line>

## Tasks completed
- <task> → `path/to/file` (MODIFIED/ADDED/DELETED)

## Tests added
<test files + cases + results, or "none — the project has no test suite">

## Validation results
<tests / type-check / lint / build — green/red with counts, naming each test that was already red on the baseline>

## Deviations from the ticket
<what changed vs the ticket and why, or "none" — the reviewer's signal of intent; a test changed while the ticket left its behavior unchanged is listed here too, and the review still blocks it>

## Problems encountered
<each check still red — the check, the failure and what was tried — and each success criterion that isn't true, named; or "none". A PARTIAL status names its causes here>
