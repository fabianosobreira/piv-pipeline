# Issue tracker

Where this project's plans and tickets live. The skills read this file instead of asking the user.

Contents: *The seven words* · *Where tickets live* · *Header block* · *Paths — always local* · *Creating a ticket* · *Finding a review's deferrals* · *Intent-slug* · *Ticket id form* · *Ticket status* · *The epic file*.

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

**Tickets are local markdown files, one per ticket**, in the folder of their intent: `docs/.tickets/[intent-slug]/[ticket-id].md`. The epic is the folder's `epic.md`, and a ticket belongs to the epic by living in the same folder. There is no separate system to reach — the files are read and written like any other in this repo.

## Header block

The PRD, the epic and every ticket open with one **header block** — one bold label per line, directly under the title — carrying the fields that tie them to each other:

- **`Intent-slug`** — the key defined below. Every artifact of one intent carries the same one.
- **`Language`** — the BCP 47 tag of the intent's language, such as `pt-BR`: set by the PRD — or, with no PRD, the spec — and copied verbatim into every other artifact that carries it.

A sliced ticket adds the fields `piv-slice` writes, in this order: `Part of` (the epic's id, when there is an epic), `Spec` (the spec's path and the hash of its revision, as `[path] @ [hash]`), `Slice` (the spec's task it carries), `Blocked by` (the tickets that must land first, or `none`) and `Size`. The spec keeps `Intent-slug` and `Language` in its own header lines.

The three reports use the same header block, with the fields their own templates name.

**A markdown list, not YAML front matter.** Everything here is a local file, where front matter would work — but the same artifact templates serve trackers that render an issue body, where it does not. The form stays uniform so the templates don't fork.

## Paths — always local

- **Plans** (PRDs, specs) — `docs/.plans/[intent-slug].prd.md`, `docs/.plans/[intent-slug].spec.md`.
- **Epic** — `docs/.tickets/[intent-slug]/epic.md`.
- **Tickets** — `docs/.tickets/[intent-slug]/[ticket-id].md`.
- **Implementation reports** — `docs/.reports/[ticket-id]-report.md`.
- **Review reports** — `docs/.reports/[ticket-id]-review.md`, so a ticket's reports sit side by side.
- **Fix reports** — `docs/.reports/[ticket-id]-fixes.md`.
- **Exclude globs** — `docs/.plans/*.spec.md` `docs/.plans/*.prd.md` `docs/.tickets/*/*.md` `docs/.reports/*-report.md` `docs/.reports/*-review.md` `docs/.reports/*-fixes.md`: the paths above, in the form `diff-hash.sh` takes them.

Plans stay local — `piv-slice` publishes nothing, and each ticket carries the part of the spec its task needs — so intent and spec stay separable and get reviewed beside the code.

## Creating a ticket

Every ticket follows these rules, whichever skill creates it — `piv-slice` slicing an intent, `piv-fix` deferring a finding — so every ticket in the folder reads the same:

- **Where** — a file `docs/.tickets/[intent-slug]/[ticket-id].md`, its body filled from the creating skill's own template, with the next free number. When the intent has no folder yet, create it with its `epic.md` first.
- **Title** — the file's first line is `# [ticket-id] — [title]`: a file has no issue title to stand in for one.
- **Header block** — a sliced ticket's is the one `piv-slice`'s ticket template writes. A deferral's carries `Intent-slug` and `Language`, copied verbatim from the ticket the review covered.
- **Type** — a `Type:` line under the header block carrying exactly one of `bug`, `feature` and `task`. `bug` is behavior that diverges from what was specified or delivered; `feature` delivers a new capability; `task` is refactor, docs, chore or infra work.
- **Epic** — the folder the file lives in.
- **Link** — a deferral's `## Origin` carries the id of the ticket the review covered; that id is the link.
- **Status** — a `Status: todo` line under the header block.
- **Acceptance criteria** — a sliced ticket carries them as the `AC` lines of its `## 5. Acceptance criteria` section; a deferral, as a markdown checklist under the literal heading `Acceptance criteria`.

The sections of the body come from the creating skill's template, headings as the template writes them. The `Type:` and `Status:` lines sit right under the header block, in the same list.

## Finding a review's deferrals

A deferral is a file in the reviewed ticket's folder whose `## Origin` section carries the reviewed ticket's id in its `Ticket` field. Read the `## Origin` sections of `docs/.tickets/[intent-slug]/*.md`; a file whose `Ticket` field matches the id exactly is one of that review's deferrals.

## Intent-slug

Every artifact of one intent carries the same `intent-slug` — the kebab-slug of the epic or product title, in lowercase ASCII with accents stripped. The PRD, the spec, the epic, every ticket and every report carry it in their header block. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written as `user-auth.prd.md` never acquires an `authentication.spec.md` beside it.

## Ticket id form

The id is **the intent-slug, uppercased, plus a number** — `PLUGGABLE-INGESTION-1`, `PLUGGABLE-INGESTION-2`. Commit subjects, branch names and PR titles carry that same form, and it needs no normalization to become a filename.

The prefix is what lets the id resolve to its own file: an implementation loop handed `PLUGGABLE-INGESTION-1` derives `docs/.tickets/pluggable-ingestion/PLUGGABLE-INGESTION-1.md` from the id alone, with nothing else to go on. A hand-written ticket may still carry a bare `TICKET-[n]` id; it has no prefix and has to be searched for across `docs/.tickets/*/TICKET-[n].md`, and a search that matches more than one file is ambiguous rather than resolved.

## Ticket status

A markdown ticket carries `Status: todo | in progress | in review | done` in its file — the field exists because a file has nowhere else to keep it. Each transition has exactly one owner:

- **`todo`** — written when the ticket is created: by `piv-slice` for a sliced ticket, by `piv-fix` for a deferral, one file per deferred finding.
- **`in progress`** — set by `piv-implement` as soon as it has read the ticket, before anything else runs, so a parallel wave doesn't pick up the same ticket twice.
- **`in review`** — set by `piv-open-pr` when the review request opens: it rewrites the `Status:` line in that ticket's file and appends the PR URL beside it. There is no tracker to own this, so the ticket file is what records it.
- **`done`** — set at the merge, which happens outside this loop.

## The epic file

`docs/.tickets/[intent-slug]/epic.md`, filled from the creating skill's epic template. The tickets are the other files in its folder, and the epic's *Tickets* list names each one as `[ticket id] — [ticket title]`.
