---
name: piv-create-tickets
description: Decomposes a PRD, an architecture doc, or both into agent-sized tickets with acceptance criteria and a dependency graph, then creates the epic and the tickets on the project's tracker.
argument-hint: "[PRD path] · [architecture doc path] (either or both; blank = starts by asking for them)"
disable-model-invocation: true
---

# Create Tickets: Intent → Provable Units of Work

This is part of the **plan** step of the PIV loop `docs/PIV-LOOP.md` describes.

## Input — a PRD, an architecture doc, or both

`$ARGUMENTS` carries the path of a PRD written by `piv-create-prd`, the path of an architecture doc written by `piv-create-architecture`, or both — local files where `docs/ISSUE-TRACKER.md` says plans live. Nothing passed → ask for them. **GATE.** Handed anything else — an idea, a brief, a research doc → **STOP**: it is not sliceable yet, and `piv-create-prd` or `piv-create-architecture` turns it into a plan first.

Read what you were handed, end to end. An architecture doc handed alone names its intent in its `Intent` field: when that field names a PRD, read it too — you are holding both, and only a field that says "none" puts you in the *architecture only* row below. **What you end up holding is the one branch that changes how you slice**, so establish it before anything else:

| What you have | What it means for slicing |
|---|---|
| **PRD + architecture** (the strong case) | The architecture is **load-bearing**: it names the seams, the data model, the boundaries, and the missing pieces the slices must respect. Slice along those seams. |
| **PRD only** | You have the *what*, not the *how*. Slice by outcome — see the guard below. |
| **architecture only** | No PRD — the work was architected straight from an idea, a brief or a research doc. Slice along the architecture's seams same as the strong case; the architecture's *Problem & goals* stands in for the intent wherever it doesn't cover one. |

**The epic is this skill's output, never its input.** Step 6 creates it and publishes the plans onto it, the way `docs/ISSUE-TRACKER.md` says, before any ticket exists.

## Guard

Slice from what the intent states, never from a guessed *how*. If no architecture exists, you are decomposing intent alone. Name that out loud, keep the tickets outcome-shaped rather than implementation-shaped, and when the work has real technical uncertainty, **offer `piv-create-architecture` first — before Step 1**, so no slicing is spent against a guess: slicing against a guessed architecture produces a backlog that quietly encodes decisions nobody made. **GATE.** If the user wants to proceed anyway, do it, and flag which tickets are most likely to move once the architecture is decided.

## Interaction mode: non-interactive until the GATE

**Steps 1-4 are work you do, not questions you ask.** Decompose, then stop once at the Step 5 GATE. Besides asking for an intent when none was passed, ask before or mid-process only in two cases: the *Guard*'s offer of `piv-create-architecture` when you hold a PRD only, and an intent too vague to decompose (see Step 1).

## Process

### Step 1 — Read the sources

**From the PRD** — a problem-first PRD gives you no build plan, so decompose from what it does carry:

- **MVP** — the thinnest line that proves the hypothesis end to end. The primary source of tickets: what has to exist for that line to work?
- **Target user & JTBD** — each job-to-be-done becomes one or more tickets, phrased as user-visible outcomes.
- **Success metrics** — anything that has to be measured is itself work; a metric with no way to observe it is a missing ticket.
- **Non-goals** — the boundary every ticket stays inside.
- **Open questions** — surface them, or track them as explicit decision tickets with a decision rule; keep them out of every implementation ticket. A ticket built on an unanswered question is a guess.

**From the architecture, when it exists** — *Recommended approach*, the *Key decisions* sub-sections (*Building blocks*, *Data model*, *Boundaries & contracts*, **Operational shape** — deploy, observability, failure modes, usually its own ticket or two — *Testability* and *Other eng-lead calls*), *Missing pieces*, and **Spikes & experiments** and its own *Open questions* (the architecture's risky and unsettled calls; same rule as the PRD's *Open questions* — never an implementation ticket). The slicing has to respect those calls — a call labeled **(decided-by-default)** included — and **every named missing piece is usually a ticket**.

If the intent carries explicit phases, use them as the grouping. If it doesn't, **group by outcome** and say which grouping you chose. The grouping organizes the breakdown and the execution order; it is never written onto a ticket.

**Too vague to decompose → flag it.** That's a gap in the intent, not a ticket-writing problem: name the section and what it would need to become sliceable. **GATE.**

**Done when** every MVP line, JTBD, success metric, non-goal and open question — and, with an architecture, every named missing piece and *Spikes & experiments* entry — maps to a candidate slice, a decision ticket, or a note for Step 7's *not ticketed* list.

### Step 2 — Orient on the existing surface

Slicing needs enough awareness of what already exists to judge what's independent vs dependent — overlap between slices, shared seams. **Explore it yourself**, unless the session is already oriented — that skips the reading, never the list below: starting from the architecture's named seams (or, with a PRD only, from wherever this work would land), read the relevant surfaces to see what exists, what's reused, and where the new work goes. **Done when**, for every symbol a slice changes, you have listed every caller found by searching the code — the search named — and, for every surface in the same role the slice leaves alone, why it stays out. Counts in a ticket come from that list, never from an estimate. The list also shows where the slices overlap. Greenfield with nothing built yet: skip it, and say so.

### Step 3 — Decompose into agent-sized slices

**Scope these for whoever picks them up.** An agent loop carries far more than a traditional human ticket — a small-to-medium implementation *phase* rather than a single task — so size each ticket as a phase when agents will run it. A small intent might be a single ticket, and on greenfield the same slicing applies to MVP phases instead of epic tickets.

The size test is **behavioral, not numeric**. A well-sized ticket:

- Is **one provable concern** — easy to verify, review, and prove on its own.
- Is one coherent unit — a vertical slice of behavior, not a horizontal layer.
- Has clear acceptance criteria of its own.
- Is small enough that **one focused loop can finish it without losing the thread** — not so large that the work drifts and returns diminish.
- Fits on one screen when described — the enumerated *Scope* and *Out of scope* lists aside. A ticket whose description doesn't is two tickets.

Split by **dependency**, by **concern**, or as a **tracer bullet** — a slim end-to-end slice that proves the whole flow thinly, fattened next loop — whatever makes each ticket easiest to prove. The *planning detail* stays high regardless — it's the *scope* that's larger.

**Done when** every candidate slice from Step 1 either became a ticket or was folded into one, each ticket passes the size test above, and every field below is drafted.

*Calibration, not a rule:* for code work with a current-generation agent, this has tended to land around 500–1500 lines of change (a healthy share of it tests) and roughly 8–10 subtasks. Treat those numbers as a sanity check on your own judgment, and recalibrate for the agent, the domain, and work that produces no code at all.

For every ticket, draft:
- **Title** — imperative and specific (`Add token refresh endpoint`, not `Auth`).
- **Description** — what and why, traced back to the intent section it came from.
- **Root cause** and **Reproduction** — type `bug` only, left out of every other type: taken from the intent or architecture section that states the defect, or from the code read in Step 2, with `path:line` evidence.
- **Acceptance criteria** — a checklist a reviewer can verify.
- **Scope** — the surfaces it touches, enumerated from Step 2, and a rough size.
- **Out of scope** — the surfaces in the same role this ticket leaves alone, each with the ticket that owns it or why none does.
- **Per-ticket context** — the doc sections, guides, and seams this ticket needs. This is what lets a loop pick the ticket up later without re-reading the whole epic. Every reference it carries resolves from the ticket alone — the repository named when it isn't this one — and every literal is quoted in full. One that can't be resolved or completed from the sources goes on the Step 5 *Unsettled* list.
- **Testing strategy** — the tests this ticket needs and the checks that prove it, or "project defaults" when the project's own testing standard and checks are enough. "Project defaults" never waives the tests: every behavior the ticket adds or alters still gets one.
- **Type** — `bug`, `feature` or `task`, as `docs/ISSUE-TRACKER.md` defines them under *Creating a ticket*.

### Step 4 — Map dependencies and parallelism

**Independent tickets** — ones that don't touch the same surfaces or rely on each other's output — **can run in parallel**, in whatever isolation the project supports (separate checkouts, branches, environments). Mark which tickets are independent and which form a dependency chain. Slicing along vertical seams maximizes independence.

**Plan just-in-time:** a dependent ticket waits until its dependency is *implemented*, not just sliced — building the dependency informs the dependent's plan, so planning it early plans against a guess. Independent tickets can be planned and run in parallel; dependent ones wait their turn.

**Retire every absorbed symbol exactly once.** For every existing symbol the architecture absorbs or replaces, name the ticket that removes it, and write that ticket into the dependency graph. Every ticket that touches the symbol, other than the one that removes it, says under *Out of scope* that it keeps the symbol, and for which callers. When the sources don't say which ticket removes it, the symbol goes on the Step 5 *Unsettled* list — never pick one here, since a removal picked without a source invents a dependency between tickets.

With a PRD only and no architecture, keep this graph coarse and say so — real dependencies usually surface from the seams the architecture names.

**Done when** every ticket is marked independent or placed in a dependency chain, with nothing left unclassified, and every absorbed or replaced symbol has a removing ticket or a line on the *Unsettled* list, and every ticket touching it says what it keeps.

### Step 5 — GATE: confirm the breakdown

The destination is already settled: `docs/ISSUE-TRACKER.md` says where tickets live. Say which one you are writing to.

**GATE** — post the ticket titles, their types, their grouping and rough sizes, and the dependency graph. Post, under **Unsettled**, every fact a ticket needs that the sources leave open — a surface in the same role that no ticket owns, an absorbed or replaced symbol whose removing ticket no source names, and the root cause of a `bug` slice that no source or code read supports with `path:line` evidence, among others — for the user to rule on. Nothing on that list is decided by this run. Then **stop. End the turn and hand the decision to the user.** Their approval is the only thing that moves this forward — never roll into creating the tickets on your own, and never treat your own judgment as their approval.

**If they skip the GATE** ("just create them"): honor it, but name the calls you made on their behalf — the types, the grouping, the sizing, the dependency graph — and record them as **(decided-by-default)** wherever Step 6 writes the dependency graph down, repeated in the Step 7 report — never as though the user had ruled on them. The *Unsettled* list goes to the epic's *Open questions* and to the *Per-ticket context* of each ticket it affects, never resolved silently.

## Output — create the tickets

### Step 6 — Create the epic, publish the plans, create the tickets

**The epic comes first.** Create it where `docs/ISSUE-TRACKER.md` says tickets live, filling the template at `templates/epic.md`. Then **publish the plans onto it** and fill its `Intent` and `Architecture` fields — `docs/ISSUE-TRACKER.md` owns that procedure, because it changes with the tracker; follow what it says rather than assuming this project's one. This is the single point in the loop that publishes the plans: `piv-create-prd` and `piv-create-architecture` write their doc and stop.

Then create one ticket per slice, in the same place, reaching that system with whatever tool fits. Fill the body from `templates/ticket.md`. **Every ticket follows the rules `docs/ISSUE-TRACKER.md` gives under *Creating a ticket*** — where it lives, its header block, its type, its epic, its `Acceptance criteria` heading — the same rules `piv-fix-findings` follows for a deferral, so every ticket in the backlog reads the same and one filter finds them all. What those rules mean for a sliced ticket, and what it carries besides:

- Acceptance criteria go in the ticket body as a markdown checklist under the literal `Acceptance criteria` heading *Creating a ticket* names. That heading is the contract: an implementation loop reads the checklist under it as the ticket's task list.
- The Step 3 context this ticket needs goes in the template's *Per-ticket context* field — that's what makes later orientation optional.
- Preserve the dependency information — each ticket's *Depends on*, plus whatever blocking link the system offers.
- Fill the header block's `Intent-slug`, `Intent` and `Architecture` from the epic's own fields, copied verbatim once the epic's fields point at the published plans — a ticket picked up cold still resolves both plans.
- Capture each created ticket's id and URL as you go, in the id form `docs/ISSUE-TRACKER.md` defines, and, when the tracker keeps an epic of its own, add its line to the epic's *Tickets* list. That id is what every later step is handed.

**Then write the dependency graph and the execution order down** — in the epic's *Dependency graph and execution order* section, or wherever `docs/ISSUE-TRACKER.md` says it lives when the tracker keeps no epic of its own. It is the one part of the breakdown no single ticket carries, and unwritten it dies with this conversation.

**Done when** every candidate slice from Step 3 is a created ticket, each id and URL is captured, the epic's *Tickets* list is complete, and the dependency graph is written.

### Step 7 — Report

- A table: ticket title → type → created id and URL.
- The intent (and architecture) the backlog was generated from.
- The execution order — which tickets can start now, in parallel, and which are waiting.
- **What you deliberately did *not* ticket** — open questions, non-goals, anything blocked on a spike.

## Hand off

Confirm where the tickets landed, then offer the next move and let the user run it — this skill does not chain into the next one:

- **Start the first ticket** — run `piv-implement-ticket <ticket-id>`, in a session of its own, one per ticket.
- **Run a wave in parallel** — the independent tickets from Step 4 can start at the same time, each in a session of its own.

## Success criteria

- ✅ **Every ticket traces back to a specific section** of the intent or architecture.
- ✅ **One provable concern each**, with verifiable acceptance criteria and enough context to be picked up cold.
- ✅ **Every ticket was created by the tracker doc's *Creating a ticket* rules**, carrying exactly one type.
- ✅ **Every ticket carries an enumerated *Scope* and an *Out of scope*,** and every unsettled fact is on the *Unsettled* list — with the GATE skipped, also in the *Per-ticket context* of each ticket it affects.
- ✅ **Every `bug` ticket carries a *Root cause* with `path:line` evidence and a *Reproduction* — or its root cause is on the *Unsettled* list, and with the GATE skipped, also in the ticket's *Per-ticket context*.**
- ✅ **Dependencies mapped**, with the parallelizable tickets marked, and every absorbed or replaced symbol has a removing ticket in the graph or a line on the *Unsettled* list — with each ticket that touches it, other than the one that removes it, stating under *Out of scope* what it keeps.
- ✅ **The user confirmed the breakdown** before anything was created — or skipped the GATE, and the calls made for them are recorded as **(decided-by-default)**.
- ✅ **No ticket crosses a stated non-goal**, rests on an open question, or invents an architecture decision.
- ✅ **Every ticket resolves `Intent-slug`, `Intent` and `Architecture` through the header block *Creating a ticket* gives it**, the epic carries the published plans in its own, and the dependency graph is written down.
