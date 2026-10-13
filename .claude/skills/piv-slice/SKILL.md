---
name: piv-slice
description: Decomposes a PRD, an architecture doc, or both into agent-sized tickets with acceptance criteria and a dependency graph, then creates the tickets on the project's tracker, under an epic when there is more than one.
argument-hint: "[PRD path] · [architecture doc path] (either or both; blank = starts by asking for them)"
disable-model-invocation: true
---

# Slice: Intent → Provable Units of Work

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes. Write the epic and the tickets in the intent's language — the `Language` of the PRD, or of the architecture doc when there is no PRD; template labels stay as written.

## Input — a PRD, an architecture doc, or both

`$ARGUMENTS` carries the path of a PRD written by `piv-write-prd`, the path of an architecture doc written by `piv-architect`, or both — local files where `docs/issue-tracker.md` says plans live. Read `docs/issue-tracker.md` first: Steps 5 and 6 follow its *Creating a ticket* rules. Nothing passed → ask for the plans. **GATE.** Handed anything else — an idea, a brief, a research doc → **STOP**: it is not sliceable yet, and `piv-write-prd` or `piv-architect` turns it into a plan first.

Read what you were handed, end to end. An architecture doc handed alone names its intent in its `Intent` field: when that field names a PRD, read it too — only a field that says "none" leaves you with the architecture only. Below, **the plans** are the documents you end up holding, and **the intent** is the PRD — or, with no PRD, the architecture's *Problem & goals*. **What you hold is the one branch that changes how you slice**, so establish it before anything else:

- **PRD + architecture** (the strong case) — the architecture is **load-bearing**: it names the seams, the data model, the boundaries, and the missing pieces the slices must respect. Slice along those seams.
- **PRD only** — you have the *what*, not the *how*. Slice by outcome, under the *Guard* below.
- **Architecture only** — the work was architected straight from an idea, a brief or a research doc. Slice along the architecture's seams as in the strong case; Step 1 reads its *Problem & goals* in place of the PRD sections.

**The epic is this skill's output, never its input, and it exists only when the breakdown has more than one ticket.** Step 6 creates it and publishes the plans onto it, the way `docs/issue-tracker.md` says, before any ticket exists. A breakdown of one ticket has no epic: the plans are published on the ticket itself.

## Guard

Slice from what the intent states, never from a guessed *how*. If no architecture exists, you are decomposing intent alone. Name that out loud and keep the tickets outcome-shaped rather than implementation-shaped. With a PRD only, offer `piv-architect` before Step 1 when the PRD's MVP door is one-way, or its constraints or open questions name a technical unknown, so no slicing is spent against a guess. **GATE.** If the user wants to proceed anyway, do it, and flag which tickets are most likely to move once the architecture is decided.

**Steps 1-4 are work you do, not questions you ask.** Decompose, then stop once at the Step 5 GATE. Besides asking for the plans when none were passed, ask before or mid-process only in two cases: the offer of `piv-architect` above, and an intent too vague to decompose (see Step 1).

Copy this checklist into your task list. Tick an item only when its step's **Done when** holds.

- [ ] 1. Read the plans
- [ ] 2. Orient on the existing surface
- [ ] 3. Decompose into agent-sized slices
- [ ] 4. Map dependencies and parallelism
- [ ] 5. GATE: confirm the breakdown
- [ ] 6. Publish the plans and create the tickets, under an epic when there is more than one
- [ ] 7. Report

## Success criteria

- ✅ **Every ticket traces to a section of the plans**, and none crosses a non-goal, rests on an open question, or invents an architecture decision.
- ✅ **One provable concern per ticket**, with an enumerated *Scope* and *Out of scope*, and an *Entry context* that cites the plans instead of copying them.
- ✅ **Every `bug` ticket has a *Root cause* with `path:line` evidence and a *Reproduction*** — or its root cause is on the *Unsettled* list.
- ✅ **Every acceptance criterion** pins the edges of each comparison, names each current check it removes or relaxes, cites an architecture rule it enforces by ID with a concrete case and outcome or quotes it verbatim, can be met inside the repository, and maps to a named test or check in the *Testing strategy*.
- ✅ **Every *Scope* names the docs the change makes stale, or "none"**, and every step another system or person owns sits under the ticket's *External references* and in a *Not ticketed* section.
- ✅ **Dependencies mapped** — each ticket independent or in a chain — and every absorbed or replaced symbol has one removing ticket in the graph or a line on the *Unsettled* list, with every other ticket that touches it stating under *Out of scope* what it keeps.
- ✅ **Every fact a ticket needs that the plans leave open is on the *Unsettled* list**, never decided in the ticket — and, with the GATE skipped, also in the *Entry context › Decisions* of each ticket it affects.
- ✅ **The user confirmed the breakdown** before anything was created — or skipped the GATE, and the calls made for them are recorded as **(decided-by-default)**.
- ✅ **Every ticket was created by the *Creating a ticket* rules of `docs/issue-tracker.md`**, with exactly one type and a header block that resolves `Intent-slug`, `Language`, `Intent` and `Architecture`; the published plans sit on the epic, or on the ticket when there is no epic; with an epic, the dependency graph is written down.

## Process

### Step 1 — Read the plans

Decompose from the sections below, by the rule given for each one.

**From the PRD** — a problem-first PRD gives you no build plan, so decompose from what it does carry:

- **MVP** — the thinnest line that proves the hypothesis end to end. The primary source of tickets: what has to exist for that line to work?
- **Target user & JTBD** — each job-to-be-done becomes one or more tickets, phrased as user-visible outcomes.
- **Success metrics** — anything that has to be measured is itself work; a metric with no way to observe it is a missing ticket.
- **Constraints** — a boundary every ticket respects, like the non-goals; a constraint the code enforces becomes an acceptance criterion of each ticket that touches it.
- **Non-goals** — the boundary every ticket stays inside.
- **Open questions** — never inside an implementation ticket: a ticket built on an unanswered question is a guess. Make one a decision ticket, with a decision rule, when a slice waits on its answer and work inside the repository — a spike, a measurement — can settle it; otherwise it becomes a *Not ticketed* note.

**From the architecture, when it exists** — the slicing respects every call it makes, one labeled **(decided-by-default)** included:

- *Recommended approach*.
- The *Key decisions* sub-sections — *Building blocks*, *Data model*, *Boundaries & contracts*, *Operational shape* (deploy, observability, failure modes; usually a ticket or two of its own), *Testability* and *Other eng-lead calls*.
- *Behavior changes vs today* — the checks each replaced rule keeps, changes or drops; every one lands in a ticket's acceptance criteria.
- *Missing pieces* — each one is usually a ticket.
- *Spikes & experiments* and the architecture's own *Open questions* — its risky and unsettled calls, under the PRD's *Open questions* rule: never an implementation ticket.

If the intent carries explicit phases, use them as the grouping. If it doesn't, **group by outcome** and say which grouping you chose. The grouping organizes the breakdown and the execution order; it is never written onto a ticket.

**Too vague to decompose → flag it.** That's a gap in the intent, not a ticket-writing problem: name the section and what it would need to become sliceable. **GATE.**

**Done when** every item the sections you read carry — each MVP line, JTBD, success metric, constraint, non-goal and open question, or each point of *Problem & goals*; with an architecture, each missing piece and *Spikes & experiments* entry — maps to a candidate slice, a decision ticket, or a *Not ticketed* note. Step 6 decides which *Not ticketed* section a note lands in; Step 7 reports every note.

### Step 2 — Orient on the existing surface

Slicing needs to know what already exists to judge which slices are independent and where they overlap. **Explore it yourself.** Start from the architecture's named seams — with a PRD only, from wherever this work would land — and read the relevant surfaces: what exists, what's reused, and where the new work goes. A session that has already read those surfaces skips the reading, never the list below.

For every symbol a candidate slice changes, list:

- every caller, found by searching the code, with the search named. A search the tool truncates is rerun in parts — directory by directory — until it covers the code; one that still can't be exhausted is named incomplete in the ticket.
- every surface in the same role the slice leaves alone, and why it stays out.

Counts in a ticket come from that list, never from an estimate. The list also shows where the slices overlap. Greenfield with nothing built yet: skip this step, and say so.

**Done when** the list covers every symbol a candidate slice changes.

### Step 3 — Decompose into agent-sized slices

Size each ticket by the behavioral size test under *Sizing* below, and split the way it gives. For every ticket, draft its title, its type and every field `templates/ticket.md` names except *Depends on* (Step 4) and *Not ticketed* (Step 6), by the rules under *Ticket fields* below.

**Done when** every candidate slice from Step 1 either became a ticket or was folded into one, each ticket passes the size test, and every field is drafted by its rule.

#### Sizing

The size test is **behavioral, not numeric**. A well-sized ticket:

- Is **one provable concern** — easy to verify, review, and prove on its own.
- Is one coherent unit — a vertical slice of behavior, not a horizontal layer.
- Has clear acceptance criteria of its own.
- Is small enough that **one focused loop can finish it without losing the thread** — not so large that the work drifts and returns diminish.
- Its *Description* fits in one short paragraph — the *Scope* and *Out of scope* lists aside. A ticket whose description doesn't is two tickets.

Split by **dependency**, by **concern**, or as a **tracer bullet** — a slim end-to-end slice that proves the whole flow thinly, fattened next loop — whatever makes each ticket easiest to prove.

*Calibration, not a rule:* for code work, a ticket this size lands around 500–1500 lines of change (a healthy share of it tests) and roughly 8–10 subtasks. Treat those numbers as a sanity check on your own judgment, and recalibrate for the agent, the domain, and work that produces no code at all.

#### Ticket fields

- **Title** — imperative and specific (`Add token refresh endpoint`, not `Auth`).
- **Description** — what and why. The sections it traces to go under *Entry context › Decisions*, never here.
- **Root cause** and **Reproduction** — type `bug` only, left out of every other type: taken from the plan section that states the defect, or from the code read in Step 2, with `path:line` evidence. A root cause neither supports goes on the Step 5 *Unsettled* list.
- **Acceptance criteria** — a checklist a reviewer can verify. The criterion is the implementation run's task list, so a paraphrase that changes a rule gets built.
  - A criterion that enforces an architecture rule takes one of two forms: it cites the rule's ID — `D<n>`, or `D<n>·<row label>` for a table row — and states a check that stands on its own, a concrete case with its expected outcome; or it quotes the rule verbatim.
  - A criterion that compares values pins its edges — inclusive or exclusive bounds, date vs datetime, null values, ties — from the plans. An edge no plan settles goes on the Step 5 *Unsettled* list, never decided here.
  - A criterion that removes or relaxes a check the code applies today names that check, taken from the architecture's *Behavior changes vs today* when it has one.
  - Every criterion is one the implementation run can meet with what this repository and its tooling reach.
  - A step another system or person owns — a schema change applied to a database, a regeneration run against one, an entry in another system, an edit to a file the repository ignores — goes under *External references* and a *Not ticketed* note, never into a criterion or the *Testing strategy*.

  For a rule `D3` that says a token is valid while the request time is before its `exp`:

  - Vague: `Expired tokens are rejected.`
  - Pinned: `D3: a request made at exactly the token's exp is rejected with 401.`
- **Scope** — the surfaces it touches, enumerated from Step 2, a rough size, and the docs the change makes stale — comments, docstrings, guides — found by searching for what the change overturns, or "none".
- **Out of scope** — the surfaces in the same role this ticket leaves alone, each with the ticket that owns it or why none does.
- **Entry context** — the four fields of the template: *Decisions*, *Starting code*, *External references* and *Neighbors*.
  - It cites the plans and never copies text from them, because a copy can drift from its source. It holds only what is the ticket's own — starting code, external references, and how the work splits with its neighbors.
  - *Starting code* holds only files inside this repository; every reference to a file outside it goes under *External references*, because the implementation run drift-checks the starting code and cannot open a file outside the repository.
  - For a dependent ticket, *Starting code* records the code as it is today; add under *Decisions*: "re-check after <dependency id>".
  - Every reference resolves from the ticket alone — the repository named when it isn't this one. One that the plans can't resolve or complete goes on the Step 5 *Unsettled* list.
- **Testing strategy** — the test or check that proves each acceptance criterion, named per criterion. "Project defaults" covers how the checks run, never which ones, and never waives the tests: every behavior the ticket adds or alters still gets one.
- **Type** — `bug`, `feature` or `task`, as `docs/issue-tracker.md` defines them under *Creating a ticket*.

### Step 4 — Map dependencies and parallelism

**Independent tickets** — ones that don't touch the same surfaces or rely on each other's output — **can run in parallel**. Mark which tickets are independent and which form a dependency chain, and draft each ticket's *Depends on* from its chain. With a PRD only and no architecture, keep this graph coarse and say so — real dependencies usually surface from the seams the architecture names.

**Retire every absorbed symbol exactly once.** For every existing symbol the architecture absorbs or replaces, name the ticket that removes it, and write that ticket into the dependency graph. Every ticket that touches the symbol, other than the one that removes it, says under *Out of scope* that it keeps the symbol, and for which callers. When the plans don't say which ticket removes it, the symbol goes on the Step 5 *Unsettled* list — never pick one here, since a removal picked without a plan behind it invents a dependency between tickets.

**Done when** every ticket is marked independent or placed in a dependency chain and has its *Depends on* drafted, and every absorbed or replaced symbol has a removing ticket or a line on the *Unsettled* list, with every ticket touching it saying what it keeps.

### Step 5 — GATE: confirm the breakdown

The destination is already settled: `docs/issue-tracker.md` says where tickets live. Say which tracker you are writing to and whether the breakdown gets an epic — it does when it has more than one ticket — then **GATE** — post the ticket titles, their types, their grouping and rough sizes, and the dependency graph. Post, under **Unsettled**, every fact a ticket needs that the plans leave open, for the user to rule on, including:

- a surface in the same role that no ticket owns
- an absorbed or replaced symbol whose removing ticket no plan names
- a compared edge no plan settles
- a name or value the code must match that only a step outside the repository fixes (a table name, an enum value)
- the root cause of a `bug` slice that no plan or code read supports with `path:line` evidence
- a reference the plans can't resolve or complete

Nothing on that list is decided by this run. Then **stop. End the turn and hand the decision to the user.** Their approval is the only thing that moves this forward — never roll into creating the tickets on your own, and never treat your own judgment as their approval.

**If they skip the GATE** ("just create them"): honor it, but name the calls you made on their behalf — the types, the grouping, the sizing, the dependency graph — and record them as **(decided-by-default)** in the epic's *Dependency graph and execution order* (with no epic, in the ticket's *Entry context › Decisions*), repeated in the Step 7 report — never as though the user had ruled on them. Each *Unsettled* item goes to the *Not ticketed* section — the epic's, or the ticket's when there is no epic — and to the *Entry context › Decisions* of each ticket it affects, never resolved silently.

**Done when** the user approved the breakdown and ruled on every *Unsettled* item — or skipped the GATE, and the calls made for them are named.

## Output — create the tickets

### Step 6 — Publish the plans and create the tickets

Write the epic and the tickets in the intent's language; template labels stay as written. Before creating anything, confirm you can reach the tracker `docs/issue-tracker.md` names, with the tool it names or whatever fits when it names none. If nothing reaches it → **STOP** and say so: a run that fails midway leaves a partial backlog.

The ticket count from Step 4 picks the branch:

- **More than one ticket — the epic comes first.** Create it where `docs/issue-tracker.md` says, filling the template at `templates/epic.md` — use it exactly. Then **publish the plans onto it** and fill its `Intent` and `Architecture` fields, the way `docs/issue-tracker.md` says. Only then create the tickets, each a sub-ticket of the epic, by the rules below — their header block copies the epic's fields, which must already point at the published plans.
- **One ticket — no epic.** Create the ticket by the rules below, its `Intent` and `Architecture` still the local paths. **Publish the plans on it**, as two comments, the way `docs/issue-tracker.md` says, then edit its body to replace both paths with the comment URLs. Its *Not ticketed* section holds every *Not ticketed* note. A run that stops between the creation and the edit leaves local paths in the header: say so, and finish the edit first on resuming.

Every ticket, in either branch:

- Its body is `templates/ticket.md` — use it exactly, leaving out *Root cause* and *Reproduction* on every type but `bug`, and *Not ticketed* on a ticket that has an epic or no notes for it. The template's placeholders say how each header field is filled.
- It follows the rules `docs/issue-tracker.md` gives under *Creating a ticket* — where it lives, its header block, its type, its epic when it has one.
- Its acceptance criteria are a markdown checklist under the literal `Acceptance criteria` heading *Creating a ticket* names. That heading is the contract: an implementation loop reads the checklist under it as the ticket's task list.
- Its dependencies are kept twice: in its *Depends on*, and in whatever blocking link the tracker offers.
- Its id and URL are captured as soon as it exists, in the id form `docs/issue-tracker.md` defines, and, with an epic, its line is added to the epic's *Tickets* list. That id is what every later step is handed.

**With an epic, then write the dependency graph and the execution order down** in the epic's *Dependency graph and execution order* section. It is the one part of the breakdown no single ticket carries.

**Done when** every ticket drafted in Step 3 is created with its id and URL captured; with an epic, its *Tickets* list is complete and the dependency graph is written; with one ticket, its header holds the two comment URLs.

### Step 7 — Report

Report a table of ticket title → type → created id and URL; the plans the backlog was generated from; the execution order — which tickets can start now, in parallel, and which are waiting; **what you deliberately did *not* ticket** — open questions, non-goals, anything blocked on a spike; and, with the GATE skipped, the **(decided-by-default)** calls.

**Done when** every created ticket is in the table and every *Not ticketed* note is in the report.

## Hand off

Confirm the epic's id, when there is one, and where the tickets landed, then offer the next move and let the user run it — this skill does not chain into the next one:

- **Start the first ticket** — run `piv-implement <ticket-id>`, in a session of its own, one per ticket.
- **Run a wave in parallel** — the independent tickets from Step 4 can start at the same time, each in a session of its own.

Plan just-in-time: a dependent ticket waits until its dependency is *implemented*, because its *Starting code* was recorded before that dependency existed.
