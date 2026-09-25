# Issue tracker

Where this project's plans and tickets live. The skills read this file instead of asking the user.

## The six words

One name per artifact, used the same way across every skill:

- **intent** — the *what and why*: a PRD, an epic, or a brief.
- **architecture** — the *how*: the decision doc written beside the intent, and published onto the epic alongside it.
- **ticket** — one provable unit of work, sliced out of the two above.
- **implementation report** — what a finished ticket leaves behind: what was built, how it was validated, and what deviated.
- **review report** — what the review gate leaves behind: the findings that survived it, with a verdict.
- **fix report** — what the triage of a review leaves behind: which findings were fixed, deferred, flagged for a human, or dropped.

"Report" on its own is fine in prose when only one of the three is in play; name which one whenever more than one could be meant. "Epic", "plan", "task", "slice" and "breakdown" are loose synonyms that show up in prose; when it matters which artifact is meant, use one of the six.

## Where tickets live

**Tickets are GitHub issues in this repo**, reached with `gh`. An epic is an issue carrying the `epic` label, and a ticket links back to its epic.

When GitHub is unreachable, say so and stop. There is nowhere else this project keeps tickets, so writing them anywhere else puts a backlog where nobody will look for it.

## Header block

The PRD, the architecture doc, the epic and every ticket open with one **header block** — one bold label per line, directly under the title — carrying the fields that tie them to each other:

- **`Intent-slug`** — the key defined below. Every artifact of one intent carries the same one.
- **`Intent`** — where the *what and why* lives: the PRD's path until the plans are published, its comment URL from then on. The PRD is itself the intent, so the PRD alone carries no `Intent` field.
- **`Architecture`** — where the *how* lives: the architecture doc's path until published, its comment URL from then on, or "none".

Once the plans are published, the comment URL is the value: every ticket, implementation report and PR copies it verbatim, even where the local file is at hand.

The three reports use the same header block, with the fields their own templates name.

**A markdown list, not YAML front matter.** These artifacts are read as GitHub issue bodies and comments, where front matter renders as a stray heading instead of as metadata. A list renders the same in a file and in an issue, and one field per line keeps each one greppable.

## Where plans live — written locally, published on the epic

The PRD and the architecture doc are **written as local files** while the plan is still moving, which is what keeps them cheap to revise: `docs/.plans/<intent-slug>.prd.md` and `docs/.plans/<intent-slug>.architecture.md`.

**`piv-create-tickets` is what publishes them.** Before it creates any ticket, it:

1. **Creates the epic** — an issue carrying the `epic` label, filled from the epic template — unless it was handed one that already exists. It never creates a second epic for an intent that already has one.
2. **Posts the PRD and the architecture doc as two separate comments** on that epic. Each opens with its own heading — `# PRD — <title>`, `# Architecture — <title>` — and that heading is how a later reader tells the two apart among the epic's other comments.
3. **Writes the two comment URLs into the epic's `Intent` and `Architecture` fields**, replacing the local paths the epic was born with.

An issue body — the epic's, a ticket's — carries no heading of its own, because the issue title already is one. Only comments carry a heading, because a comment has no title.

A plan too large for one comment splits across several, each still opening with its own heading; a doc from these templates never comes close to the limit.

Published this way, the plans travel with the epic rather than with the machine that wrote them.

## Paths

- **Plans** — `docs/.plans/<intent-slug>.prd.md`, `docs/.plans/<intent-slug>.architecture.md`. Written locally, then published onto the epic as above.
- **Implementation reports** — `docs/.reports/<ticket-id>-report.md`, or `docs/.reports/<intent-slug>-report.md` when the work has no ticket. Normalize the id for filenames first: `#123` → `123`.
- **Review reports** — `docs/.reports/<ticket-id>-review.md`, or `docs/.reports/<intent-slug>-review.md` when there is no ticket. Same normalization, so a ticket's reports sit side by side.
- **Fix reports** — `docs/.reports/<ticket-id>-fixes.md`, or `docs/.reports/<intent-slug>-fixes.md` when there is no ticket. Same normalization again.

## Intent-slug

Every artifact of one intent carries the same `intent-slug` — the kebab-slug of the epic or product title. The PRD, the architecture doc, the epic, every ticket and every report carry it in their header block. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written as `user-auth.prd.md` never acquires an `authentication.architecture.md` beside it.

## Ticket id form

Write the id the way GitHub writes it — `#123`. Commit subjects, branch names and PR titles carry that same form.

## Ticket status

**GitHub owns a ticket's status**: an issue is open until the merge closes it. No status field lives in this project's own artifacts. Three loop steps leave a mark on the issue anyway, and each has exactly one owner:

- **Assignee** — `piv-implement-ticket` assigns the issue to the user running it once the branch exists, so a parallel wave doesn't pick up the same ticket twice.
- **Deferral issues** — `piv-fix-findings` opens one issue per deferred finding, linked back to the ticket the review covered.
- **PR link** — `piv-create-pr` links the pull request to the issue, which is what carries it into review and closes it at the merge.
