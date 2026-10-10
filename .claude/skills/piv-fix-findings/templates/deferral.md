- **Intent-slug**: <intent-slug>
- **Language**: <the reviewed ticket's `Language`, copied verbatim>
- **Intent**: <the reviewed ticket's `Intent`, copied verbatim, or "none">
- **Architecture**: <the reviewed ticket's `Architecture`, copied verbatim, or "none">

## Description
<the finding's one-line claim> — <its impact: what breaks, and for whom>

## Scope
<the surfaces the fix touches, starting from the finding's location · rough size · the docs the fix makes stale, or "none">

## Out of scope
<the surfaces in the same role this fix leaves alone, the rest of the finding's file included, or "none">

## Origin
- **Ticket**: <the id of the ticket the review covered>
- **Severity**: <the finding's severity>
- **Location**: `path/to/file.py:42`

## Evidence
<the finding's evidence, copied verbatim from the review report — the quoted line or the traced path that proves it>

## Suggested fix
<the finding's fix, copied from the review report>

## Depends on
<the id of the ticket the review covered>

## Testing strategy
<the test or check that proves each acceptance criterion, named per criterion — "project defaults" covers how the checks run, never which ones>

## Acceptance criteria
- [ ] <bug: the defect at `path/to/file.py:42` no longer reproduces, and a test fails without the fix and passes with it | task: the finding's claim no longer holds at `path/to/file.py:42`, and the project's checks stay green>
- [ ] <any criterion the finding itself calls for>
