# Fix report — [T-xx] — [the task's title]

- **Intent-slug**: [the reviewed ticket's `Intent-slug`]
- **Issue**: [#N]
- **Task**: [T-xx]
- **Branch**: [branch]
- **Review**: [path of the review report]
- **Round**: [the review report's Round]

## Fixed
- **[the finding's one-line claim]** — `path/to/file.py:42` → [what changed] · proof: [the test or check that proves it] | not fixed — pending | not fixed — [the hypotheses tried]

## Deferred
- **[the finding's one-line claim]** — `path/to/file.py:42` → [D-xx] | not created — pending | not created — [the error that stopped the run][, only for an introduced or aggravated finding of severity critical, high or medium: · ruled out of Fix now: [the user's reason]]

## Needs a human look
- **[the finding's one-line claim]** — `path/to/file.py:42` → [what to inspect or test by hand] | candidate task: [proposed title] — [why the repair outgrew this run]

## Noise / won't-fix
- **[the finding's one-line claim]** — `path/to/file.py:42` → [why it drops, in terms the code bears out][, only for a blocking finding, or an introduced or aggravated one of severity critical, high or medium: · ruled out of Fix now: [the user's reason]] | won't fix — low

## Checks run
- [check — test / type-check / lint / build]: [the command] → [green | red: the failure and what was tried]
