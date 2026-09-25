# Issue tracker — GitLab (example)

**This file is an example, not this project's tracker.** It shows what `docs/ISSUE-TRACKER.md` looks like for a project whose tickets live on GitLab. Nothing reads this file: to use it, copy it over `docs/ISSUE-TRACKER.md` and adjust the project details.

Where a project's plans and tickets live. The skills read that file instead of asking the user.

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

**Tickets are GitLab issues in this project**, reached with `glab`. An epic is a group-level epic, and a ticket is linked to its epic.

When GitLab is unreachable, say so and stop. There is nowhere else this project keeps tickets, so writing them anywhere else puts a backlog where nobody will look for it.

## Header block

The PRD, the architecture doc, the epic and every ticket open with one **header block** — one bold label per line, directly under the title:

- **`Intent-slug`** — the key defined below. Every artifact of one intent carries the same one.
- **`Intent`** — where the *what and why* lives: the PRD's path until the plans are on the epic, its attachment URL from then on. The PRD is itself the intent, so the PRD alone carries no `Intent` field.
- **`Architecture`** — the architecture doc's path until it is on the epic, its attachment URL from then on, or "none".

Once the plans are on the epic, the attachment URL is the value: every ticket, implementation report and merge request copies it verbatim, even where the local file is at hand.

The three reports use the same header block, with the fields their own templates name.

**A markdown list, not YAML front matter.** An epic and a ticket are read as GitLab descriptions, where front matter renders as a stray heading instead of as metadata. A list renders the same in a file and in an issue, and one field per line keeps each one greppable.

## Where plans live — written locally, attached to the epic

The PRD and the architecture doc are **written as local files** while the plan is still moving, which is what keeps them cheap to revise: `docs/.plans/<intent-slug>.prd.md` and `docs/.plans/<intent-slug>.architecture.md`.

**`piv-create-tickets` is what publishes them.** Before it creates any ticket, it:

1. **Creates the epic** — a group-level epic — unless it was handed one that already exists. It never creates a second epic for an intent that already has one.
2. **Attaches the PRD and the architecture doc to that epic**, uploading each as its own file under its local name, so a reader sees `<intent-slug>.prd.md` and `<intent-slug>.architecture.md`. **The file name is the identifier** — an attachment has no position in a thread to be recognized by, so the name is all a later reader has to tell the two apart.
3. **Writes the two upload URLs into the epic's `Intent` and `Architecture` fields**, replacing the local paths the epic was born with, and links both from the epic's description so a reader meets them without going through the upload list.

An attachment is the raw markdown file: a plan of any size travels whole, there is nothing to split across comments, and nothing the tracker's renderer can mangle on the way in.

**A revised plan is uploaded again under the same name**, and the epic's field and description are repointed at the new upload. The superseded upload stays where it is — GitLab keeps every one — so the field is the only thing that says which is current.

Published this way, the plans travel with the epic rather than with the machine that wrote them. **The epic lives at the group level while the tickets are project issues**, so the plans sit one level above the backlog they generated — link the epic from each ticket so the trace survives that gap.

## Creating a ticket

Every ticket follows these rules, whichever skill creates it — `piv-create-tickets` slicing an intent, `piv-fix-findings` deferring a finding — so every ticket in the backlog reads the same and a filter finds all of them:

- **Where** — an issue in this project, its description filled from the creating skill's own template.
- **Header block** — `Intent-slug`, `Intent` and `Architecture`, copied verbatim from the epic — for a deferral, from the ticket the review covered.
- **Type** — exactly one label out of `bug`, `feature` and `task`. `bug` is behavior that diverges from what was specified or delivered; `feature` delivers a new capability; `task` is refactor, docs, chore or infra work.
- **Group** — the phase or outcome the ticket belongs to, as a label.
- **Epic** — linked to its epic, when the intent has one.
- **Link** — a deferral is linked to the ticket the review covered as *relates to*.
- **Acceptance criteria** — a markdown checklist under the literal heading `Acceptance criteria`.

A label that doesn't exist yet is created before the first ticket that needs it. When it can't be created, say so and stop: a ticket missing its type or group is one the filters never find.

## Finding a review's deferrals

With a ticket behind the review, its deferrals are the issues related to that ticket. With none, a deferral has nothing to link to, so it is found by the review report's path instead: every deferral carries that path verbatim on its *Origin* `Review` line. Search this project's issue descriptions for the path as text; an issue whose `Review` line matches it exactly is one of that review's deferrals.

## Paths

- **Plans** — `docs/.plans/<intent-slug>.prd.md`, `docs/.plans/<intent-slug>.architecture.md`. Written locally, then published onto the epic as above.
- **Implementation reports** — `docs/.reports/<ticket-id>-report.md`, or `docs/.reports/<intent-slug>-report.md` when the work has no ticket. Normalize the id for filenames first: `#123` → `123`.
- **Review reports** — `docs/.reports/<ticket-id>-review.md`, or `docs/.reports/<intent-slug>-review.md` when there is no ticket. Same normalization, so a ticket's reports sit side by side.
- **Fix reports** — `docs/.reports/<ticket-id>-fixes.md`, or `docs/.reports/<intent-slug>-fixes.md` when there is no ticket. Same normalization again.

## Intent-slug

Every artifact of one intent carries the same `intent-slug` — the kebab-slug of the epic or product title. The PRD, the architecture doc, the epic, every ticket and every report carry it in their header block. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written as `user-auth.prd.md` never acquires an `authentication.architecture.md` beside it.

## Ticket id form

Write the id the way GitLab writes it — `#123` for an issue, `&5` for an epic. Commit subjects, branch names and merge request titles carry that same form.

## Ticket status

**GitLab owns a ticket's status**: an issue is open until the merge closes it. No status field lives in this project's own artifacts. Three loop steps leave a mark on the issue anyway, and each has exactly one owner:

- **Assignee** — `piv-implement-ticket` assigns the issue to the user running it once the branch exists, so a parallel wave doesn't pick up the same ticket twice.
- **Deferral tickets** — `piv-fix-findings` opens one ticket per deferred finding, by the rules under *Creating a ticket*, and links it to this ticket.
- **Merge request link** — `piv-create-pr` links the merge request to the issue, which is what carries it into review and closes it at the merge.
