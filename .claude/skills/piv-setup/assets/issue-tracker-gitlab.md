# Issue tracker

Where this project's plans and tickets live. The skills read this file instead of asking the user.

## The seven words

One name per artifact, used the same way across every skill:

- **intent** — the *what and why*: a PRD, an idea, or a brief.
- **spec** — the plan: requirements, design, tasks and verification in one file written by `piv-spec`, with a PRD as optional context. It stays local.
- **epic** — the tracker item that groups an intent's tickets, for a breakdown of more than one ticket: born in `piv-slice`, never an input to any skill. A one-ticket breakdown has none.
- **ticket** — one provable unit of work, a verbatim slice of the spec.
- **implementation report** — what a finished ticket leaves behind: what was built, how it was validated, and what deviated.
- **review report** — what the review gate leaves behind: the findings that survived it, with a verdict.
- **fix report** — what the triage of a review leaves behind: which findings were fixed, deferred, flagged for a human, or dropped.

"Report" on its own is fine in prose when only one of the three is in play; name which one whenever more than one could be meant. "Plan", "slice" and "breakdown" are loose synonyms that show up in prose; when it matters which artifact is meant, use one of the seven.

## Where tickets live

**Tickets are GitLab issues in this project**, reached with `glab`. An epic is a group-level epic, and a ticket is linked to its epic.

When GitLab is unreachable, say so and stop. There is nowhere else this project keeps tickets, so writing them anywhere else puts a backlog where nobody will look for it.

## Header block

The PRD, the epic and every ticket open with one **header block** — one bold label per line, directly under the title — carrying the fields that tie them to each other:

- **`Intent-slug`** — the key defined below. Every artifact of one intent carries the same one.
- **`Language`** — the BCP 47 tag of the intent's language, such as `pt-BR`: set by the PRD — or, with no PRD, the spec — and copied verbatim into every other artifact that carries it.

A sliced ticket adds the fields `piv-slice` writes, in this order: `Part of` (the epic's id, when there is an epic), `Spec` (the spec's path and the hash of its revision, as `[path] @ [hash]`), `Slice` (the spec's task it carries), `Blocked by` (the tickets that must land first, or `none`) and `Size`. The spec keeps `Intent-slug` and `Language` in its own header lines.

The three reports use the same header block, with the fields their own templates name.

**A markdown list, not YAML front matter.** An epic and a ticket are read as GitLab descriptions, where front matter renders as a stray heading instead of as metadata. A list renders the same in a file and in an issue, and one field per line keeps each one greppable.

## Where plans live — written locally, never published

The PRD and the spec are **written as local files** while the plan is still moving, which is what keeps them cheap to revise: `docs/.plans/[intent-slug].prd.md` and `docs/.plans/[intent-slug].spec.md`.

**Neither is published to the tracker.** `piv-slice` copies into each ticket the part of the spec its task needs, and the ticket's `Spec` field names the revision it was cut from. The epic carries no plan and no comment or attachment holds one.

## Creating a ticket

Every ticket follows these rules, whichever skill creates it — `piv-slice` slicing an intent, `piv-fix` deferring a finding — so every ticket in the backlog reads the same and a filter finds all of them:

- **Where** — an issue in this project, its description filled from the creating skill's own template.
- **Header block** — a sliced ticket's is the one `piv-slice`'s ticket template writes. A deferral's carries `Intent-slug` and `Language`, copied verbatim from the ticket the review covered.
- **Type** — exactly one label out of `bug`, `feature` and `task`. `bug` is behavior that diverges from what was specified or delivered; `feature` delivers a new capability; `task` is refactor, docs, chore or infra work.
- **Epic** — linked to its epic, when the intent has one.
- **Link** — a deferral is linked to the ticket the review covered as *relates to*.
- **Acceptance criteria** — a sliced ticket carries them as the `AC` lines of its `## 5. Acceptance criteria` section; a deferral, as a markdown checklist under the literal heading `Acceptance criteria`.

A type label that doesn't exist yet is created before the first ticket that needs it. When it can't be created, say so and stop: a ticket missing its type is one the filters never find. A ticket carries its type label and no other.

## Finding a review's deferrals

A review's deferrals are the issues related to the reviewed ticket whose *Origin* `Ticket` line names it.

## Paths

- **Plans** — `docs/.plans/[intent-slug].prd.md`, `docs/.plans/[intent-slug].spec.md`. Written locally and never published.
- **Implementation reports** — `docs/.reports/[ticket-id]-report.md`. Normalize the id for filenames first: `#123` → `123`.
- **Review reports** — `docs/.reports/[ticket-id]-review.md`. Same normalization, so a ticket's reports sit side by side.
- **Fix reports** — `docs/.reports/[ticket-id]-fixes.md`. Same normalization again.
- **Exclude globs** — `docs/.plans/*.prd.md` `docs/.plans/*.spec.md` `docs/.reports/*-report.md` `docs/.reports/*-review.md` `docs/.reports/*-fixes.md`: the paths above, in the form `diff-hash.sh` takes them.

## Intent-slug

Every artifact of one intent carries the same `intent-slug` — the kebab-slug of the product title — or, with no PRD, of the spec's goal — in lowercase ASCII with accents stripped. The PRD, the spec, the epic, every ticket and every report carry it in their header block. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written as `user-auth.prd.md` never acquires an `authentication.spec.md` beside it.

## Ticket id form

Write the id the way GitLab writes it — `#123` for an issue, `&5` for an epic. Commit subjects and merge request titles carry that same form; branch names carry it without the `#`, as `docs/git-conventions.md` says.

## Ticket status

**GitLab owns a ticket's status**: an issue is open until the merge closes it. No status field lives in this project's own artifacts. Three loop steps leave a mark on the issue anyway, and each has exactly one owner:

- **Assignee** — `piv-implement` assigns the issue to the user running it as soon as it has read the ticket, before anything else runs, so a parallel wave doesn't pick up the same ticket twice.
- **Deferral tickets** — `piv-fix` opens one ticket per deferred finding, by the rules under *Creating a ticket*, and links it to this ticket.
- **Merge request link** — `piv-open-pr` links the merge request to the issue with a closing pattern before the issue number in the merge request description, which is what carries it into review and closes it at the merge. A bare issue number only cross-references it and closes nothing.
