- **Intent-slug**: <intent-slug>
- **Intent**: <the reviewed ticket's `Intent` — the implementation report's when there is no ticket — copied verbatim, or "none">
- **Architecture**: <the reviewed ticket's `Architecture` — the implementation report's when there is no ticket — copied verbatim, or "none">

## Description
<the finding's one-line claim> — <its impact: what breaks, and for whom>

## Origin
- **Ticket**: <the id of the ticket the review covered, or "none">
- **Review**: <path of the review report>
- **Severity**: <the finding's severity>
- **Location**: `path/to/file.py:42`

## Evidence
<the finding's evidence, copied verbatim from the review report — the quoted line or the traced path that proves it>

## Suggested fix
<the finding's fix, copied from the review report>

## Depends on
<the id of the ticket the review covered, or "none">

## Testing strategy
<the test that proves the fix and the checks that cover it, or "project defaults">

## Acceptance criteria
- [ ] <bug: the defect at `path/to/file.py:42` no longer reproduces, and a test fails without the fix and passes with it | task: the finding's claim no longer holds at `path/to/file.py:42`, and the project's checks stay green>
- [ ] <any criterion the finding itself calls for>
