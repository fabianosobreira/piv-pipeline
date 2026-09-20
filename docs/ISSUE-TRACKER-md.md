# Issue tracker — markdown example

**This file is an example**, not this project's issue tracker: it shows what `docs/ISSUE-TRACKER.md` looks like for a project that keeps its tickets in local markdown files instead of on a tracker. A project that wants this arrangement copies it over `docs/ISSUE-TRACKER.md`; the skills read that name and only that name.

Where this project's plans and tickets live. The skills read this file instead of asking the user.

## The six words

One name per artifact, used the same way across every skill:

- **intent** — the *what and why*: a PRD, an epic, or a brief.
- **architecture** — the *how*: the decision doc written beside the intent.
- **ticket** — one provable unit of work, sliced out of the two above.
- **implementation report** — what a finished ticket leaves behind: what was built, how it was validated, and what deviated.
- **review report** — what the review gate leaves behind: the findings that survived it, with a verdict.
- **fix report** — what the triage of a review leaves behind: which findings were fixed, deferred, flagged for a human, or dropped.

"Report" on its own is fine in prose when only one of the three is in play; name which one whenever more than one could be meant. "Epic", "plan", "task", "slice" and "breakdown" are loose synonyms that show up in prose; when it matters which artifact is meant, use one of the six.

## Where tickets live

**Tickets are blocks inside a local markdown breakdown** — `docs/.tickets/<intent-slug>.md`, one breakdown per intent. A ticket id names a block inside it; the breakdown file as a whole is never a ticket.

An epic is the intent doc itself, under `docs/.plans/`. There is no separate system to reach — the breakdown is a file in this repo, read and written like any other.

## Header block

The PRD, the architecture doc and the ticket breakdown open with one **header block** — one bold label per line, directly under the title:

- **`Intent-slug`** — the key defined below. Every artifact of one intent carries the same one.
- **`Intent`** — the path the *what and why* lives at. The PRD is itself the intent, so the PRD alone carries no `Intent` field.
- **`Architecture`** — the architecture doc's path, or "none".

The three reports use the same header block, with the fields their own templates name. Each ticket block inside the breakdown inherits the breakdown's header rather than repeating it.

**A markdown list, not YAML front matter.** Everything here is a local file, where front matter would work — but the same artifact templates serve trackers that render an issue body, where it does not. The form stays uniform so the templates don't fork.

## Paths — always local

- **Plans** (architecture docs, PRDs) — `docs/.plans/<intent-slug>.architecture.md`, `docs/.plans/<intent-slug>.prd.md`.
- **Tickets** — `docs/.tickets/<intent-slug>.md`.
- **Implementation reports** — `docs/.reports/<ticket-id>-report.md`, or `docs/.reports/<intent-slug>-report.md` when the work has no ticket.
- **Review reports** — `docs/.reports/<ticket-id>-review.md`, or `docs/.reports/<intent-slug>-review.md` when there is no ticket, so a ticket's reports sit side by side.
- **Fix reports** — `docs/.reports/<ticket-id>-fixes.md`, or `docs/.reports/<intent-slug>-fixes.md` when there is no ticket.

Plans stay local, so intent and architecture stay separable and get reviewed beside the code.

## Intent-slug

Every artifact of one intent carries the same `intent-slug` — the kebab-slug of the epic or product title. The PRD, the architecture doc, the ticket breakdown and every report carry it in their header block. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written as `user-auth.prd.md` never acquires an `authentication.architecture.md` beside it.

## Ticket id form

The id is **the intent-slug, uppercased, plus a number** — `PLUGGABLE-INGESTION-1`, `PLUGGABLE-INGESTION-2`. Commit subjects, branch names and PR titles carry that same form, and it needs no normalization to become a filename.

The prefix is what lets the id resolve to its own breakdown file: an implementation loop handed `PLUGGABLE-INGESTION-1` derives `docs/.tickets/pluggable-ingestion.md` from the id alone, with nothing else to go on. A hand-written breakdown may still carry bare `TICKET-<n>` ids; those have no prefix and have to be searched for across `docs/.tickets/*.md`, and a search that matches more than one file is ambiguous rather than resolved.

## Ticket status

A markdown ticket carries `Status: todo | in progress | in review | done` in its block — the field exists because a breakdown file has nowhere else to keep it. Each transition has exactly one owner:

- **`todo`** — written by `piv-create-tickets` when the ticket is created.
- **`in progress`** — set by `piv-implement-ticket` once the branch exists, so a parallel wave doesn't pick up the same ticket twice.
- **`in review`** — set by `piv-create-pr` when the review request opens: it rewrites the `Status:` line in that ticket's block inside `docs/.tickets/<intent-slug>.md` and appends the PR URL beside it. There is no tracker to own this, so the breakdown file is what records it.
- **`done`** — set at the merge, which happens outside this loop.

## The breakdown file

```markdown
# Ticket Breakdown — <intent name>

- **Intent-slug**: <intent-slug>
- **Intent**: <the PRD path these tickets trace to>
- **Architecture**: <the architecture doc path these tickets trace to, or "none">

## Summary
The goal in 2-3 lines.

## Tickets

### <INTENT-SLUG>-1 — <title>
- Status: todo
- Group: <the phase or outcome this ticket belongs to>
- Description: <what and why> — traced to <the intent or architecture section it came from>
- Scope: one provable concern · surfaces touched (estimate) · rough size
- Per-ticket context: e.g. "source-adapter guide · seam: adapter interface · acceptance criteria 2 and 4 from the epic"
- Depends on: <none, or <INTENT-SLUG>-x>

**Acceptance criteria**
- [ ] <criterion a reviewer can verify>
- [ ] <criterion a reviewer can verify>

### <INTENT-SLUG>-2 — ...

## Dependency graph
<text or mermaid graph showing the order + parallel groups>

## Suggested execution order
Wave 1 (parallel): <INTENT-SLUG>-1, <INTENT-SLUG>-3
Wave 2: <INTENT-SLUG>-2 (after <INTENT-SLUG>-1 is implemented)
```

The **Acceptance criteria** heading is the contract an implementation loop reads as the ticket's task list, and the dependency graph lives here because no single ticket carries it.
