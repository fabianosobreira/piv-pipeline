# Issue tracker — Jira (example)

**This file is an example, not this project's configuration.** It shows what `docs/ISSUE-TRACKER.md` looks like when the tickets live in Jira instead of GitHub. Nothing reads it: to actually run the loop on Jira, copy it over `docs/ISSUE-TRACKER.md` and fill in the project key.

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

**Tickets are Jira issues in project `<KEY>`**, reached with whatever Atlassian tooling this project has — an MCP server, a CLI, or the REST API. An epic is an issue of type **Epic**, and a ticket is linked to its epic as a child.

Jira issue types other than Epic are interchangeable here: create tickets as whatever type the project's workflow expects (`Story`, `Task`), and keep it consistent across one breakdown.

When Jira is unreachable, say so and stop. There is nowhere else this project keeps tickets, so writing them anywhere else puts a backlog where nobody will look for it.

## Header block

The PRD, the architecture doc, the epic and every ticket open with one **header block** — one bold label per line, directly under the title:

- **`Intent-slug`** — the key defined below. Every artifact of one intent carries the same one.
- **`Intent`** — where the *what and why* lives: the PRD's path until the plans are on the epic, its attachment URL from then on. The PRD is itself the intent, so the PRD alone carries no `Intent` field.
- **`Architecture`** — the architecture doc's path until it is on the epic, its attachment URL from then on, or "none".

Once the plans are on the epic, the attachment URL is the value: every ticket, implementation report and PR copies it verbatim, even where the local file is at hand.

The three reports use the same header block, with the fields their own templates name.

**A markdown list, not YAML front matter.** An epic and a ticket are read as Jira descriptions, which do not render front matter as metadata. A list survives the conversion into Jira's own format, and one field per line keeps each one greppable.

## Where plans live — written locally, attached to the epic

The PRD and the architecture doc are **written as local files** while the plan is still moving, which is what keeps them cheap to revise: `docs/.plans/<intent-slug>.prd.md` and `docs/.plans/<intent-slug>.architecture.md`.

**`piv-create-tickets` is what publishes them.** Before it creates any ticket, it:

1. **Creates the epic** — an issue of type **Epic** — unless it was handed one that already exists. It never creates a second epic for an intent that already has one.
2. **Attaches the PRD and the architecture doc to that epic**, uploading each as its own file under its local name, so a reader sees `<intent-slug>.prd.md` and `<intent-slug>.architecture.md`. **The file name is the identifier** — an attachment has no position in a thread to be recognized by, so the name is all a later reader has to tell the two apart.
3. **Writes the two attachment URLs into the epic's `Intent` and `Architecture` fields**, replacing the local paths the epic was born with, and links both from the epic's description so a reader meets them without going through the attachment list.

An attachment is the raw markdown file, which is what makes this the right shape on Jira in particular: **Jira does not store markdown.** A description or a comment becomes Atlassian Document Format on the way in, and that conversion is lossy — an attachment goes in and comes back out byte for byte.

**A revised plan is attached again under the same name**, and the epic's field and description are repointed at the new attachment. Jira keeps the superseded one, so the field is the only thing that says which is current.

Published this way, the plans travel with the epic rather than with the machine that wrote them.

## Paths

- **Plans** — `docs/.plans/<intent-slug>.prd.md`, `docs/.plans/<intent-slug>.architecture.md`. Written locally, then published onto the epic as above.
- **Implementation reports** — `docs/.reports/<ticket-id>-report.md`, or `docs/.reports/<intent-slug>-report.md` when the work has no ticket. A Jira key is already filename-safe: write it as it is, `PROJ-123-report.md`.
- **Review reports** — `docs/.reports/<ticket-id>-review.md`, or `docs/.reports/<intent-slug>-review.md` when there is no ticket. Same form, so a ticket's reports sit side by side.
- **Fix reports** — `docs/.reports/<ticket-id>-fixes.md`, or `docs/.reports/<intent-slug>-fixes.md` when there is no ticket. Same form again.

## Intent-slug

Every artifact of one intent carries the same `intent-slug` — the kebab-slug of the epic or product title. The PRD, the architecture doc, the epic, every ticket and every report carry it in their header block. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written as `user-auth.prd.md` never acquires an `authentication.architecture.md` beside it.

The slug is not the Jira key and never replaces it: the key names one ticket, the slug groups everything belonging to one intent.

## Ticket id form

Write the id the way Jira writes it — `PROJ-123`, the project key and the issue number. Commit subjects, branch names and PR titles carry that same form, which is also what a Jira/Git integration matches on to link the branch back to the issue.

## Ticket status

**Jira's workflow owns a ticket's status**, and no status field lives in this project's own artifacts. Each transition has exactly one owner:

- **In Progress** — `piv-implement-ticket` transitions the issue and assigns it to the user running it once the branch exists, so a parallel wave doesn't pick up the same ticket twice.
- **In Review** — `piv-create-pr` transitions the issue and puts the pull request URL on it.
- **Done** — set at the merge, which happens outside this loop.

When the project's workflow names these states differently, map them to the nearest equivalent and say which mapping you used; when a transition is unavailable from the issue's current state, leave the status alone, comment on the issue instead, and report it.
