# [D-xx] — [title: imperative and specific, naming the defect and where it lives]

- **Intent-slug**: [the reviewed ticket's `Intent-slug`, copied verbatim]
- **Language**: [the reviewed ticket's `Language`, copied verbatim]
- **Type**: [bug or task]
- **Origin**: [the reviewed task's id, such as T-02], review round [the review report's Round]

## Claim
[the finding's one-line claim]

## Impact
[what breaks, and for whom]

## Evidence
[the finding's evidence, copied verbatim from the review report — the quoted line or the traced path that proves it]

## Location
`path/to/file.py:42`

## Proposed fix
[the finding's fix, copied from the review report]

## Acceptance criteria
- [ ] [bug: the defect at `path/to/file.py:42` no longer reproduces, and a test fails without the fix and passes with it | task: the finding's claim no longer holds at `path/to/file.py:42`, and the project's checks stay green]
- [ ] [any criterion the finding itself calls for]
