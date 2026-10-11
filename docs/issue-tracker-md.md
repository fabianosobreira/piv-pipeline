# Issue tracker — markdown example

**This file is an example**, not this project's issue tracker: it shows what `docs/issue-tracker.md` looks like for a project that keeps its tickets in local markdown files instead of on a tracker. A project that wants this arrangement copies it over `docs/issue-tracker.md`; the skills read that name and only that name.

Where this project's plans and tickets live. The skills read this file instead of asking the user.

Contents: *The seven words* · *Where tickets live* · *Header block* · *Paths — always local* · *Creating a ticket* · *Finding a review's deferrals* · *Intent-slug* · *Ticket id form* · *Ticket status* · *The epic file*.

## The seven words

One name per artifact, used the same way across every skill:

- **intent** — the *what and why*: a PRD, an idea, or a brief.
- **architecture** — the *how*: the decision doc written beside the intent.
- **epic** — the tracker item that groups an intent's tickets: born in `piv-create-tickets`, never an input to any skill.
- **ticket** — one provable unit of work, sliced out of the intent and the architecture.
- **implementation report** — what a finished ticket leaves behind: what was built, how it was validated, and what deviated.
- **review report** — what the review gate leaves behind: the findings that survived it, with a verdict.
- **fix report** — what the triage of a review leaves behind: which findings were fixed, deferred, flagged for a human, or dropped.

"Report" on its own is fine in prose when only one of the three is in play; name which one whenever more than one could be meant. "Plan", "slice" and "breakdown" are loose synonyms that show up in prose; when it matters which artifact is meant, use one of the seven.

## Where tickets live

**Tickets are local markdown files, one per ticket**, in the folder of their intent: `docs/.tickets/<intent-slug>/<ticket-id>.md`. The epic is the folder's `epic.md`, and a ticket belongs to the epic by living in the same folder. There is no separate system to reach — the files are read and written like any other in this repo.

## Header block

The PRD, the architecture doc, the epic and every ticket open with one **header block** — one bold label per line, directly under the title — carrying the fields that tie them to each other:

- **`Intent-slug`** — the key defined below. Every artifact of one intent carries the same one.
- **`Intent`** — the path the *what and why* lives at. The PRD is itself the intent, so the PRD alone carries no `Intent` field.
- **`Architecture`** — the architecture doc's path, or "none".
- **`Language`** — the BCP 47 tag of the intent's language, such as `pt-BR`: set by the PRD — or, with no PRD, the architecture doc — and copied verbatim into every other artifact that carries it.

The three reports use the same header block, with the fields their own templates name.

**A markdown list, not YAML front matter.** Everything here is a local file, where front matter would work — but the same artifact templates serve trackers that render an issue body, where it does not. The form stays uniform so the templates don't fork.

## Paths — always local

- **Plans** (architecture docs, PRDs) — `docs/.plans/<intent-slug>.architecture.md`, `docs/.plans/<intent-slug>.prd.md`.
- **Epic** — `docs/.tickets/<intent-slug>/epic.md`.
- **Tickets** — `docs/.tickets/<intent-slug>/<ticket-id>.md`.
- **Implementation reports** — `docs/.reports/<ticket-id>-report.md`.
- **Review reports** — `docs/.reports/<ticket-id>-review.md`, so a ticket's reports sit side by side.
- **Fix reports** — `docs/.reports/<ticket-id>-fixes.md`.
- **Exclude globs** — `docs/.plans/*.architecture.md` `docs/.plans/*.prd.md` `docs/.tickets/*/*.md` `docs/.reports/*-report.md` `docs/.reports/*-review.md` `docs/.reports/*-fixes.md`: the paths above, in the form `diff-hash.sh` takes them.

Plans stay local — `piv-create-tickets` publishes nothing, and the epic's header block points at their paths — so intent and architecture stay separable and get reviewed beside the code.

## Creating a ticket

Every ticket follows these rules, whichever skill creates it — `piv-create-tickets` slicing an intent, `piv-fix-findings` deferring a finding — so every ticket in the folder reads the same:

- **Where** — a file `docs/.tickets/<intent-slug>/<ticket-id>.md`, its body filled from the creating skill's own template, with the next free number. When the intent has no folder yet, create it with its `epic.md` first.
- **Title** — the file's first line is `# <ticket-id> — <title>`: a file has no issue title to stand in for one.
- **Header block** — `Intent-slug`, `Language`, `Intent` and `Architecture`, copied verbatim from the epic — for a deferral, from the ticket the review covered.
- **Type** — a `Type:` line under the header block carrying exactly one of `bug`, `feature` and `task`. `bug` is behavior that diverges from what was specified or delivered; `feature` delivers a new capability; `task` is refactor, docs, chore or infra work.
- **Epic** — the folder the file lives in.
- **Link** — a deferral's `## Origin` carries the id of the ticket the review covered; that id is the link.
- **Status** — a `Status: todo` line under the header block.
- **Acceptance criteria** — a markdown checklist under the literal heading `## Acceptance criteria`.

The sections of the body come from the creating skill's template, headings as the template writes them. The `Type:` and `Status:` lines sit right under the header block, in the same list.

## Finding a review's deferrals

A deferral is a file in the reviewed ticket's folder whose `## Origin` section carries the reviewed ticket's id in its `Ticket` field. Read the `## Origin` sections of `docs/.tickets/<intent-slug>/*.md`; a file whose `Ticket` field matches the id exactly is one of that review's deferrals.

## Intent-slug

Every artifact of one intent carries the same `intent-slug` — the kebab-slug of the epic or product title, in lowercase ASCII with accents stripped. The PRD, the architecture doc, the epic, every ticket and every report carry it in their header block. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written as `user-auth.prd.md` never acquires an `authentication.architecture.md` beside it.

## Ticket id form

The id is **the intent-slug, uppercased, plus a number** — `PLUGGABLE-INGESTION-1`, `PLUGGABLE-INGESTION-2`. Commit subjects, branch names and PR titles carry that same form, and it needs no normalization to become a filename.

The prefix is what lets the id resolve to its own file: an implementation loop handed `PLUGGABLE-INGESTION-1` derives `docs/.tickets/pluggable-ingestion/PLUGGABLE-INGESTION-1.md` from the id alone, with nothing else to go on. A hand-written ticket may still carry a bare `TICKET-<n>` id; it has no prefix and has to be searched for across `docs/.tickets/*/TICKET-<n>.md`, and a search that matches more than one file is ambiguous rather than resolved.

## Ticket status

A markdown ticket carries `Status: todo | in progress | in review | done` in its file — the field exists because a file has nowhere else to keep it. Each transition has exactly one owner:

- **`todo`** — written when the ticket is created: by `piv-create-tickets` for a sliced ticket, by `piv-fix-findings` for a deferral, one file per deferred finding.
- **`in progress`** — set by `piv-implement-ticket` as soon as it has read the ticket, before anything else runs, so a parallel wave doesn't pick up the same ticket twice.
- **`in review`** — set by `piv-create-pr` when the review request opens: it rewrites the `Status:` line in that ticket's file and appends the PR URL beside it. There is no tracker to own this, so the ticket file is what records it.
- **`done`** — set at the merge, which happens outside this loop.

## The epic file

`docs/.tickets/<intent-slug>/epic.md`, filled from the creating skill's epic template. The tickets are the other files in its folder, and the epic's *Tickets* list names each one as `<ticket id> — <ticket title>`. The epic's `Intent` and `Architecture` fields keep the local plan paths, since nothing is published.
