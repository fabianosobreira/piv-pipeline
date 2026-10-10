# Issue tracker — markdown example

**This file is an example**, not this project's issue tracker: it shows what `docs/ISSUE-TRACKER.md` looks like for a project that keeps its tickets in local markdown files instead of on a tracker. A project that wants this arrangement copies it over `docs/ISSUE-TRACKER.md`; the skills read that name and only that name.

Where this project's plans and tickets live. The skills read this file instead of asking the user.

Contents: *The seven words* · *Where tickets live* · *Header block* · *Paths — always local* · *Creating a ticket* · *Finding a review's deferrals* · *Intent-slug* · *Ticket id form* · *Ticket status* · *The breakdown file*.

## The seven words

One name per artifact, used the same way across every skill:

- **intent** — the *what and why*: a PRD, an idea, or a brief.
- **architecture** — the *how*: the decision doc written beside the intent.
- **epic** — none of its own: the ticket breakdown, born in `piv-create-tickets`, stands in for it; never an input to any skill.
- **ticket** — one provable unit of work, sliced out of the intent and the architecture.
- **implementation report** — what a finished ticket leaves behind: what was built, how it was validated, and what deviated.
- **review report** — what the review gate leaves behind: the findings that survived it, with a verdict.
- **fix report** — what the triage of a review leaves behind: which findings were fixed, deferred, flagged for a human, or dropped.

"Report" on its own is fine in prose when only one of the three is in play; name which one whenever more than one could be meant. "Plan", "slice" and "breakdown" are loose synonyms that show up in prose; when it matters which artifact is meant, use one of the seven.

## Where tickets live

**Tickets are blocks inside a local markdown breakdown** — `docs/.tickets/<intent-slug>.md`, one breakdown per intent. A ticket id names a block inside it; the breakdown file as a whole is never a ticket.

There is no epic of its own: the breakdown file stands in for it, its header block carrying the epic's fields. There is no separate system to reach — the breakdown is a file in this repo, read and written like any other.

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
- **Implementation reports** — `docs/.reports/<ticket-id>-report.md`.
- **Review reports** — `docs/.reports/<ticket-id>-review.md`, so a ticket's reports sit side by side.
- **Fix reports** — `docs/.reports/<ticket-id>-fixes.md`.

Plans stay local — `piv-create-tickets` publishes nothing, and the breakdown's header block points at their paths — so intent and architecture stay separable and get reviewed beside the code.

## Creating a ticket

Every ticket follows these rules, whichever skill creates it — `piv-create-tickets` slicing an intent, `piv-fix-findings` deferring a finding — so every ticket in the breakdown reads the same:

- **Where** — a block appended to the intent's breakdown file, in the form shown under *The breakdown file* — use it exactly — with the next free number. When the intent has no breakdown yet, create the file with its header block first.
- **Header block** — none of its own: the block inherits the breakdown's `Intent-slug`, `Intent` and `Architecture`.
- **Type** — a `Type:` line carrying exactly one of `bug`, `feature` and `task`. `bug` is behavior that diverges from what was specified or delivered; `feature` delivers a new capability; `task` is refactor, docs, chore or infra work.
- **Epic** — none of its own: the block belongs to the breakdown file that stands in for it.
- **Link** — a deferral's `Origin:` line carries the id of the ticket the review covered; that id is the link.
- **Status** — `Status: todo`.
- **Acceptance criteria** — a markdown checklist under the literal bold line `Acceptance criteria`.

The other lines of a block come from the creating skill's own template, one line per section of it — a deferral carries `Origin:`, `Evidence:` and `Suggested fix:` where a sliced ticket carries `Entry context:`, and both carry `Scope:` and `Out of scope:`. A section that is a list becomes one line, its fields separated by ` · `. The template's header block is dropped: the block inherits the breakdown's.

## Finding a review's deferrals

A deferral is a block in the intent's breakdown file whose `Origin:` line carries the reviewed ticket's id in its `Ticket` field. Read the `Origin:` lines of `docs/.tickets/<intent-slug>.md`; a block whose `Ticket` field matches the id exactly is one of that review's deferrals.

## Intent-slug

Every artifact of one intent carries the same `intent-slug` — the kebab-slug of the epic or product title, in lowercase ASCII with accents stripped. The PRD, the architecture doc, the ticket breakdown and every report carry it in their header block. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written as `user-auth.prd.md` never acquires an `authentication.architecture.md` beside it.

## Ticket id form

The id is **the intent-slug, uppercased, plus a number** — `PLUGGABLE-INGESTION-1`, `PLUGGABLE-INGESTION-2`. Commit subjects, branch names and PR titles carry that same form, and it needs no normalization to become a filename.

The prefix is what lets the id resolve to its own breakdown file: an implementation loop handed `PLUGGABLE-INGESTION-1` derives `docs/.tickets/pluggable-ingestion.md` from the id alone, with nothing else to go on. A hand-written breakdown may still carry bare `TICKET-<n>` ids; those have no prefix and have to be searched for across `docs/.tickets/*.md`, and a search that matches more than one file is ambiguous rather than resolved.

## Ticket status

A markdown ticket carries `Status: todo | in progress | in review | done` in its block — the field exists because a breakdown file has nowhere else to keep it. Each transition has exactly one owner:

- **`todo`** — written when the ticket is created: by `piv-create-tickets` for a sliced ticket, by `piv-fix-findings` for a deferral, one block per deferred finding.
- **`in progress`** — set by `piv-implement-ticket` as soon as it has read the ticket, before anything else runs, so a parallel wave doesn't pick up the same ticket twice.
- **`in review`** — set by `piv-create-pr` when the review request opens: it rewrites the `Status:` line in that ticket's block inside `docs/.tickets/<intent-slug>.md` and appends the PR URL beside it. There is no tracker to own this, so the breakdown file is what records it.
- **`done`** — set at the merge, which happens outside this loop.

## The breakdown file

```markdown
# Ticket breakdown — <intent name>

- **Intent-slug**: <intent-slug>
- **Intent**: <the PRD path these tickets trace to, or "none">
- **Architecture**: <the architecture doc path these tickets trace to, or "none">

## Summary
<the goal in 2–3 lines>

## Tickets

### <INTENT-SLUG>-1 — <title>
- Status: todo
- Type: <bug | feature | task>
- Description: <what and why>
- Root cause: <type bug only: the root cause, with path:line evidence>
- Reproduction: <type bug only: the input, the observed outcome and the expected one — concrete enough to become a failing test>
- Scope: <one provable concern: the surfaces it touches · rough size · the docs the change makes stale, or "none">
- Out of scope: <surfaces in the same role this ticket leaves alone, each with the ticket that owns it or why none does — or "none">
- Entry context: Decisions: <the architecture IDs, or the intent or architecture sections, this ticket implements, cited and never copied, plus any unsettled fact it depends on> · Starting code: <`path:line` inside this repository, and what that code does today> · External references: <references outside this repository, and every step another system or person owns, or "none"> · Neighbors: <what adjacent tickets own in the same files, or "none">
- Depends on: <none, or <INTENT-SLUG>-x>
- Testing strategy: <the test or check that proves each acceptance criterion, named per criterion — "project defaults" covers how the checks run, never which ones>

**Acceptance criteria**
- [ ] <criterion a reviewer can verify>
- [ ] <criterion a reviewer can verify>

### <INTENT-SLUG>-2 — ...

## Dependency graph
<text or mermaid graph showing the order + parallel groups>

## Suggested execution order
Wave 1 (parallel): <INTENT-SLUG>-1, <INTENT-SLUG>-3
Wave 2: <INTENT-SLUG>-2 (after <INTENT-SLUG>-1 is implemented)

## Not ticketed
<one line per item the plans left without a ticket: the plan section it comes from and why it got no ticket, without restating it>
```

The **Acceptance criteria** heading is the contract an implementation loop reads as the ticket's task list, and the dependency graph lives here because no single ticket carries it. With no epic of its own, the breakdown file stands in for the epic's body: what a skill writes to the epic's *Dependency graph and execution order* goes under *Dependency graph* and *Suggested execution order*, what it writes to the epic's *Not ticketed* goes under *Not ticketed*, and what it writes to the epic's *Context* goes under *Summary*. The epic's *Tickets* list is the blocks' own `### <INTENT-SLUG>-<n> — <title>` headings: no line is added for them.
