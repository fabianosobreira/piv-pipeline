---
name: piv-create-tickets
description: Decomposes a PRD, an architecture doc, or both into agent-sized tickets with acceptance criteria and a dependency graph, then creates the epic and the tickets on the project's tracker.
argument-hint: "[PRD path] · [architecture doc path] (either or both; blank = starts by asking for them)"
disable-model-invocation: true
---

# Create Tickets: Intent → Provable Units of Work

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes.

## Input — a PRD, an architecture doc, or both

`$ARGUMENTS` carries the path of a PRD written by `piv-create-prd`, the path of an architecture doc written by `piv-create-architecture`, or both — local files where `docs/issue-tracker.md` says plans live. Nothing passed → ask for them. **GATE.** Handed anything else — an idea, a brief, a research doc → **STOP**: it is not sliceable yet, and `piv-create-prd` or `piv-create-architecture` turns it into a plan first.

Read what you were handed, end to end. An architecture doc handed alone names its intent in its `Intent` field: when that field names a PRD, read it too — you are holding both, and only a field that says "none" leaves you with the architecture only. **What you end up holding — PRD + architecture, PRD only, or architecture only — is the one branch that changes how you slice**, so establish it before anything else:

- **PRD + architecture** (the strong case) — the architecture is **load-bearing**: it names the seams, the data model, the boundaries, and the missing pieces the slices must respect. Slice along those seams.
- **PRD only** — you have the *what*, not the *how*. Slice by outcome, under the *Guard* below.
- **Architecture only** — no PRD: the work was architected straight from an idea, a brief or a research doc. Slice along the architecture's seams as in the strong case; its *Problem & goals* stands in for the intent wherever it doesn't cover one.

**The epic is this skill's output, never its input.** Step 6 creates it and publishes the plans onto it, the way `docs/issue-tracker.md` says, before any ticket exists.

## Guard

Slice from what the intent states, never from a guessed *how*. If no architecture exists, you are decomposing intent alone. Name that out loud and keep the tickets outcome-shaped rather than implementation-shaped. With a PRD only, offer `piv-create-architecture` before Step 1 when the PRD's MVP door is one-way, or its constraints or open questions name a technical unknown, so no slicing is spent against a guess. **GATE.** If the user wants to proceed anyway, do it, and flag which tickets are most likely to move once the architecture is decided.

**Steps 1-4 are work you do, not questions you ask.** Decompose, then stop once at the Step 5 GATE. Besides asking for the plans when none were passed, ask before or mid-process only in two cases: the offer of `piv-create-architecture` above, and an intent too vague to decompose (see Step 1).

Copy this checklist into your task list. Tick an item only when its step's completion criterion holds.

- [ ] 1. Read the sources
- [ ] 2. Orient on the existing surface
- [ ] 3. Decompose into agent-sized slices
- [ ] 4. Map dependencies and parallelism
- [ ] 5. GATE: confirm the breakdown
- [ ] 6. Create the epic, publish the plans, create the tickets
- [ ] 7. Report

## Success criteria

- ✅ **Every ticket traces back to a specific section** of the intent or architecture, and **none crosses a stated non-goal**, rests on an open question, or invents an architecture decision.
- ✅ **One provable concern each**, with an enumerated *Scope* and *Out of scope* and an *Entry context* that cites its sources instead of copying them — and every unsettled fact is on the *Unsettled* list, with the GATE skipped also in the *Entry context › Decisions* of each ticket it affects.
- ✅ **Every `bug` ticket carries a *Root cause* with `path:line` evidence and a *Reproduction* — or its root cause is on the *Unsettled* list, and with the GATE skipped, also in the ticket's *Entry context › Decisions*.**
- ✅ **Every acceptance criterion pins the edges of every comparison from the sources, names each current check it removes or relaxes, and, when it enforces an architecture rule, cites its ID with a concrete case and outcome or quotes the rule verbatim** — an edge no source settles is on the *Unsettled* list, never decided in the criterion.
- ✅ **Every acceptance criterion maps to a named test or check in the *Testing strategy*, and each *Scope* names the docs the change makes stale, or "none".**
- ✅ **Every acceptance criterion is one the implementation run can meet inside the repository**, and every step another system or person owns is under the ticket's *External references* and the epic's *Not ticketed*.
- ✅ **Dependencies mapped**, with the parallelizable tickets marked, and every absorbed or replaced symbol has a removing ticket in the graph or a line on the *Unsettled* list — with each ticket that touches it, other than the one that removes it, stating under *Out of scope* what it keeps.
- ✅ **The user confirmed the breakdown** before anything was created — or skipped the GATE, and the calls made for them are recorded as **(decided-by-default)**.
- ✅ **Every ticket was created by the tracker doc's *Creating a ticket* rules with exactly one type, resolves `Intent-slug`, `Language`, `Intent` and `Architecture` through the header block *Creating a ticket* gives it**, the epic carries the published plans in its own, and the dependency graph is written down.

## Process

### Step 1 — Read the sources

Decompose from the PRD and architecture sections below, by the rule given for each one.

**From the PRD** — a problem-first PRD gives you no build plan, so decompose from what it does carry:

- **MVP** — the thinnest line that proves the hypothesis end to end. The primary source of tickets: what has to exist for that line to work?
- **Target user & JTBD** — each job-to-be-done becomes one or more tickets, phrased as user-visible outcomes.
- **Success metrics** — anything that has to be measured is itself work; a metric with no way to observe it is a missing ticket.
- **Constraints** — a boundary every ticket respects, like the non-goals; a constraint the code enforces becomes an acceptance criterion of each ticket that touches it.
- **Non-goals** — the boundary every ticket stays inside.
- **Open questions** — surface them, or track them as explicit decision tickets with a decision rule; keep them out of every implementation ticket. A ticket built on an unanswered question is a guess.

**From the architecture, when it exists** — *Recommended approach*, the *Key decisions* sub-sections (*Building blocks*, *Data model*, *Boundaries & contracts*, **Operational shape** — deploy, observability, failure modes, usually its own ticket or two — *Testability* and *Other eng-lead calls*), *Behavior changes vs today* (the checks each replaced rule keeps, changes or drops — every one lands in a ticket's acceptance criteria), *Missing pieces*, and **Spikes & experiments** and its own *Open questions* (the architecture's risky and unsettled calls; same rule as the PRD's *Open questions* — never an implementation ticket). The slicing has to respect those calls — a call labeled **(decided-by-default)** included — and **every named missing piece is usually a ticket**.

If the intent carries explicit phases, use them as the grouping. If it doesn't, **group by outcome** and say which grouping you chose. The grouping organizes the breakdown and the execution order; it is never written onto a ticket.

**Too vague to decompose → flag it.** That's a gap in the intent, not a ticket-writing problem: name the section and what it would need to become sliceable. **GATE.**

**Done when** every MVP line, JTBD, success metric, constraint, non-goal and open question — and, with an architecture, every named missing piece and *Spikes & experiments* entry — maps to a candidate slice, a decision ticket, or a note for the epic's *Not ticketed* section and Step 7's *not ticketed* list.

### Step 2 — Orient on the existing surface

Slicing needs enough awareness of what already exists to judge what's independent vs dependent — overlap between slices, shared seams. **Explore it yourself**, unless this session has already read those surfaces — that skips the reading, never the list below: starting from the architecture's named seams (or, with a PRD only, from wherever this work would land), read the relevant surfaces to see what exists, what's reused, and where the new work goes. **Done when**, for every symbol a slice changes, you have listed every caller found by searching the code — the search named — and, for every surface in the same role the slice leaves alone, why it stays out. Counts in a ticket come from that list, never from an estimate. A search the tool truncates is rerun in parts — directory by directory — until it covers the code; one that still can't be exhausted is named incomplete in the ticket. The list also shows where the slices overlap. Greenfield with nothing built yet: skip it, and say so.

### Step 3 — Decompose into agent-sized slices

Size each ticket by the behavioral size test under *Sizing* below, and split the way it gives. For every ticket, draft its title, its type and every field `templates/ticket.md` names, by the rules under *Ticket fields* below. **Done when** every candidate slice from Step 1 either became a ticket or was folded into one, each ticket passes the size test, and every field is drafted by its rule.

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
- **Root cause** and **Reproduction** — type `bug` only, left out of every other type: taken from the intent or architecture section that states the defect, or from the code read in Step 2, with `path:line` evidence.
- **Acceptance criteria** — a checklist a reviewer can verify. The criterion is the implementation run's task list, so a paraphrase that changes a rule gets built.
  - A criterion that enforces an architecture rule takes one of two forms: it cites the rule's ID — `D<n>`, or `D<n>·<row label>` for a table row — and states a check that stands on its own, a concrete case with its expected outcome; or it quotes the rule verbatim.
  - A criterion that compares values pins its edges — inclusive or exclusive bounds, date vs datetime, null values, ties — from the sources. An edge no source settles goes on the Step 5 *Unsettled* list, never decided here.
  - A criterion that removes or relaxes a check the code applies today names that check, taken from the architecture's *Behavior changes vs today* when it has one.
  - Every criterion is one the implementation run can meet with what this repository and its tooling reach.
  - A step another system or person owns — a schema change applied to a database, a regeneration run against one, an entry in another system, an edit to a file the repository ignores — goes under *External references* and the epic's *Not ticketed*, never into a criterion or the *Testing strategy*.
- **Scope** — the surfaces it touches, enumerated from Step 2, a rough size, and the docs the change makes stale — comments, docstrings, guides — found by searching for what the change overturns, or "none".
- **Out of scope** — the surfaces in the same role this ticket leaves alone, each with the ticket that owns it or why none does.
- **Entry context** — the four fields of the template: *Decisions*, *Starting code*, *External references* and *Neighbors*.
  - It cites the architecture and the intent and never copies text from them, because a copy can drift from its source. It holds only what is the ticket's own — starting code, external references, and how the work splits with its neighbors.
  - *Starting code* holds only files inside this repository; every reference to a file outside it goes under *External references*, because the implementation run drift-checks the starting code and cannot open a file outside the repository.
  - For a dependent ticket, *Starting code* records the code as it is today; add under *Decisions*: "re-check after <dependency id>".
  - Every reference resolves from the ticket alone — the repository named when it isn't this one. One that can't be resolved or completed from the sources goes on the Step 5 *Unsettled* list.
- **Testing strategy** — the test or check that proves each acceptance criterion, named per criterion. "Project defaults" covers how the checks run, never which ones, and never waives the tests: every behavior the ticket adds or alters still gets one.
- **Type** — `bug`, `feature` or `task`, as `docs/issue-tracker.md` defines them under *Creating a ticket*.

### Step 4 — Map dependencies and parallelism

**Independent tickets** — ones that don't touch the same surfaces or rely on each other's output — **can run in parallel**. Mark which tickets are independent and which form a dependency chain. With a PRD only and no architecture, keep this graph coarse and say so — real dependencies usually surface from the seams the architecture names.

**Retire every absorbed symbol exactly once.** For every existing symbol the architecture absorbs or replaces, name the ticket that removes it, and write that ticket into the dependency graph. Every ticket that touches the symbol, other than the one that removes it, says under *Out of scope* that it keeps the symbol, and for which callers. When the sources don't say which ticket removes it, the symbol goes on the Step 5 *Unsettled* list — never pick one here, since a removal picked without a source invents a dependency between tickets.

**Done when** every ticket is marked independent or placed in a dependency chain, with nothing left unclassified, and every absorbed or replaced symbol has a removing ticket or a line on the *Unsettled* list, and every ticket touching it says what it keeps.

### Step 5 — GATE: confirm the breakdown

The destination is already settled: `docs/issue-tracker.md` says where tickets live. Say which one you are writing to, then **GATE** — post the ticket titles, their types, their grouping and rough sizes, and the dependency graph. Post, under **Unsettled**, every fact a ticket needs that the sources leave open, for the user to rule on, including:

- a surface in the same role that no ticket owns
- an absorbed or replaced symbol whose removing ticket no source names
- a compared edge no source settles
- a name or value the code must match that only a step outside the repository fixes (a table name, an enum value)
- the root cause of a `bug` slice that no source or code read supports with `path:line` evidence

Nothing on that list is decided by this run. Then **stop. End the turn and hand the decision to the user.** Their approval is the only thing that moves this forward — never roll into creating the tickets on your own, and never treat your own judgment as their approval.

**If they skip the GATE** ("just create them"): honor it, but name the calls you made on their behalf — the types, the grouping, the sizing, the dependency graph — and record them as **(decided-by-default)** wherever Step 6 writes the dependency graph down, repeated in the Step 7 report — never as though the user had ruled on them. The *Unsettled* list goes to the epic's *Not ticketed* section and to the *Entry context › Decisions* of each ticket it affects, never resolved silently.

**Done when** the user approved the breakdown and ruled on every *Unsettled* item — or skipped the GATE, and the calls made for them are named.

## Output — create the tickets

### Step 6 — Create the epic, publish the plans, create the tickets

Write the epic and the tickets in the intent's language; template labels stay as written.

**The epic comes first.** Create it where `docs/issue-tracker.md` says, filling the template at `templates/epic.md` — use it exactly. Then **publish the plans onto it** and fill its `Intent` and `Architecture` fields, the way `docs/issue-tracker.md` says.

Then create one ticket per slice, in the same place, reaching that system with whatever tool fits. Fill the body from `templates/ticket.md` — use it exactly, leaving out *Root cause* and *Reproduction* on every type but `bug`. **Every ticket follows the rules `docs/issue-tracker.md` gives under *Creating a ticket*** — where it lives, its header block, its type, its epic, its `Acceptance criteria` heading. What those rules mean for a sliced ticket, and what it carries besides:

- Acceptance criteria go in the ticket body as a markdown checklist under the literal `Acceptance criteria` heading *Creating a ticket* names. That heading is the contract: an implementation loop reads the checklist under it as the ticket's task list.
- The Step 3 entry context goes in the template's *Entry context* section, cited rather than copied — the run reads the cited sources itself.
- Preserve the dependency information — each ticket's *Depends on*, plus whatever blocking link the system offers.
- Fill the header block's `Intent-slug`, `Language`, `Intent` and `Architecture` from the epic's own fields, copied verbatim once the epic's fields point at the published plans — a ticket picked up cold still resolves both plans.
- Capture each created ticket's id and URL as you go, in the id form `docs/issue-tracker.md` defines, and add its line to the epic's *Tickets* list. That id is what every later step is handed.

**Then write the dependency graph and the execution order down** in the epic's *Dependency graph and execution order* section. It is the one part of the breakdown no single ticket carries.

**Done when** every candidate slice from Step 3 is a created ticket, each id and URL is captured, the epic's *Tickets* list is complete, and the dependency graph is written.

### Step 7 — Report

Report a table of ticket title → type → created id and URL; the intent (and architecture) the backlog was generated from; the execution order — which tickets can start now, in parallel, and which are waiting; and **what you deliberately did *not* ticket** — open questions, non-goals, anything blocked on a spike. **Done when** every created ticket is in the table and every item in the epic's *Not ticketed* is in the report.

## Hand off

Confirm the epic's id and where the tickets landed, then offer the next move and let the user run it — this skill does not chain into the next one:

- **Start the first ticket** — run `piv-implement-ticket <ticket-id>`, in a session of its own, one per ticket.
- **Run a wave in parallel** — the independent tickets from Step 4 can start at the same time, each in a session of its own.

Plan just-in-time: a dependent ticket waits until its dependency is *implemented*, because its *Starting code* was recorded before that dependency existed.
