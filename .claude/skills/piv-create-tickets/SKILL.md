---
name: piv-create-tickets
description: Decomposes an intent into agent-sized tickets with acceptance criteria and a dependency graph, then creates them on the project's tracker.
argument-hint: "[intent: PRD path, epic id, or URL] · [optional: its architecture doc path] (blank = starts by asking for the intent)"
disable-model-invocation: true
---

# Create Tickets: Intent → Provable Units of Work

This is part of the **plan** step of the PIV loop `docs/PIV-LOOP.md` describes.

## Input — one intent, optionally with architecture

`$ARGUMENTS` carries the intent — a PRD's path, an epic id or URL, or a free-form brief — and optionally the path of the architecture doc written for it. Nothing passed → ask for the intent. **GATE.**

Read whatever you were handed, end to end. When the intent is an epic that already exists, read it and every plan published on it, the way `docs/ISSUE-TRACKER.md` says they get there. When the plans are still local files, read them from their paths. Either way, **what you end up holding is the one branch that changes how you slice** — establish it before anything else:

| What you have | What it means for slicing |
|---|---|
| **intent + architecture** (the strong case) | The architecture is **load-bearing**: it names the seams, the data model, the boundaries, and the missing pieces the slices must respect. Slice along those seams. |
| **intent only** | You have the *what*, not the *how*. Slice by outcome — see the guard below. |
| **architecture only** | No PRD — the work was architected straight from an idea. Slice along the architecture's seams same as the strong case; the architecture's *Problem & goals* stands in for the intent wherever it doesn't cover one. |

**The epic is this skill's output, not its input** — unless one was handed to you. `docs/ISSUE-TRACKER.md` says how the epic is created and how the plans are published onto it; Step 6 does both, before any ticket exists.

## Guard

Don't invent the *how*. If no architecture exists, you are decomposing intent alone. Name that out loud, keep the tickets outcome-shaped rather than implementation-shaped, and **offer `piv-create-architecture` first** when the work has real technical uncertainty — slicing against a guessed architecture produces a backlog that quietly encodes decisions nobody made. If the user wants to proceed anyway, do it, and flag which tickets are most likely to move once the architecture is decided.

## Interaction mode: non-interactive until the GATE

**Steps 1-4 are work you do, not questions you ask.** Decompose, then stop once at the Step 5 GATE. Ask mid-process only when the intent is too vague to decompose (see Step 1).

## Process

### Step 1 — Read the sources

**From the intent** — an epic this loop created gives you its context, the decisions every ticket respects, its non-goals and its success metrics; an epic created elsewhere gives you whatever it carries. A problem-first PRD gives you no build plan, so decompose from what it does carry:

- **MVP** — the thinnest line that proves the hypothesis end to end. The primary source of tickets: what has to exist for that line to work?
- **Target User & JTBD** — each job-to-be-done becomes one or more tickets, phrased as user-visible outcomes.
- **Success Metrics** — anything that has to be measured is itself work; a metric with no way to observe it is a missing ticket.
- **Non-goals** — the boundary. Never generate a ticket that crosses it.
- **Open Questions** — do **not** turn these into implementation tickets. Surface them, or track them as explicit decision tickets with a decision rule. A ticket built on an unanswered question is a guess.

**From the architecture, when it exists** — recommended approach, building blocks, data model, boundaries & contracts, **operational shape** (deploy, observability, failure modes — usually its own ticket or two), missing pieces, and **Spikes & experiments** (the architecture's name for the risky calls; same rule as Open Questions — never an implementation ticket). The slicing has to respect those calls — a call labeled **(decided-by-default)** included — and **every named missing piece is usually a ticket**.

If the intent carries explicit phases, use them as the grouping. If it doesn't, **group by outcome** and say which grouping you chose.

**Too vague to decompose → flag it.** That's a gap in the intent, not a ticket-writing problem: name the section and what it would need to become sliceable. **GATE.**

### Step 2 — Orient on the existing surface

Slicing needs enough awareness of what already exists to judge what's independent vs dependent — overlap between slices, shared seams. If the session is already oriented, skip this. Otherwise **explore it yourself rather than assuming a prior orientation step ran**: starting from the architecture's named seams (or, with intent only, from wherever this work would land), read the relevant surfaces to see what exists, what's reused, and where the new work goes. **Done when you can name, for every candidate slice, the surfaces it touches and where they overlap** — not a full re-derivation. Greenfield with nothing built yet: skip it, and say so.

### Step 3 — Decompose into agent-sized slices

**Scope these for whoever picks them up.** An agent loop carries far more than a traditional human ticket — a small-to-medium implementation *phase* rather than a single task — so size each ticket as a phase when agents will run it. A small intent might be a single ticket, and on greenfield the same slicing applies to MVP phases instead of epic tickets.

The size test is **behavioral, not numeric**. A well-sized ticket:

- Is **one provable concern** — easy to verify, review, and prove on its own.
- Is one coherent unit — a vertical slice of behavior, not a horizontal layer.
- Has clear acceptance criteria of its own.
- Is small enough that **one focused loop can finish it without losing the thread** — not so large that the work drifts and returns diminish.
- Fits on one screen when described. A ticket that doesn't is two tickets.

Split by **dependency**, by **concern**, or as a **slim end-to-end slice** (prove the whole flow thinly, then fatten it next loop) — whatever makes each ticket easiest to prove. The *planning detail* stays high regardless — it's the *scope* that's larger.

*Calibration, not a rule:* for code work with a current-generation agent, this has tended to land around 500–1500 lines of change (a healthy share of it tests) and roughly 8–10 subtasks. Treat those numbers as a sanity check on your own judgment, and recalibrate for the agent, the domain, and work that produces no code at all.

For every ticket, draft:
- **Title** — imperative and specific (`Add token refresh endpoint`, not `Auth`).
- **Description** — what and why, traced back to the intent section it came from.
- **Acceptance criteria** — a checklist a reviewer can verify.
- **Per-ticket context** — the doc sections, guides, and seams this ticket needs. This is what lets a loop pick the ticket up later without re-reading the whole epic.
- **Testing strategy** — the tests this ticket needs and the checks that prove it, or "project defaults" when the project's own checks are enough.
- **Group** — the phase or outcome it belongs to.
- **Type** — `bug`, `feature` or `task`, as `docs/ISSUE-TRACKER.md` defines them under *Creating a ticket*.

### Step 4 — Map dependencies and parallelism

**Independent tickets** — ones that don't touch the same surfaces or rely on each other's output — **can run in parallel**, in whatever isolation the project supports (separate checkouts, branches, environments). Mark which tickets are independent and which form a dependency chain. Slicing along vertical seams maximizes independence.

**Plan just-in-time:** a dependent ticket waits until its dependency is *implemented*, not just sliced — building the dependency informs the dependent's plan, so planning it early plans against a guess. Independent tickets can be planned and run in parallel; dependent ones wait their turn.

With intent only and no architecture, keep this graph coarse and say so — real dependencies usually surface from the seams the architecture names.

### Step 5 — GATE: confirm the breakdown

The destination is already settled: `docs/ISSUE-TRACKER.md` says where tickets live. Say which one you are writing to.

**GATE** — post the ticket titles, their types, their grouping and rough sizes, and the dependency graph, then **stop. End the turn and hand the decision to the user.** Their approval is the only thing that moves this forward — never roll into creating the tickets on your own, and never treat your own judgment as their approval.

**If they decline the GATE** ("just create them"): honor it, but name the calls you made on their behalf — the types, the grouping, the sizing, the dependency graph — and record them as decided-by-default in the epic's *Dependency graph and execution order* section, repeated in the Step 7 report — never as though the user had ruled on them.

## Output — create the tickets

### Step 6 — Create the epic, publish the plans, create the tickets

**The epic comes first.** Unless you were handed one that already exists, create it where `docs/ISSUE-TRACKER.md` says tickets live, filling the template at `templates/epic.md`. Then **publish the plans onto it** and fill its `Intent` and `Architecture` fields — `docs/ISSUE-TRACKER.md` owns that procedure, because it changes with the tracker; follow what it says rather than assuming this project's one. This is the single point in the loop that publishes the plans: `piv-create-prd` and `piv-create-architecture` write their doc and stop.

Then create one ticket per slice, in the same place, reaching that system with whatever tool fits (an MCP server, a CLI, an API). **Every ticket follows the rules `docs/ISSUE-TRACKER.md` gives under *Creating a ticket*** — where it lives, its header block, its type, its group, its epic, its `Acceptance criteria` heading — the same rules `piv-fix-findings` follows for a deferral, so every ticket in the backlog reads the same and one filter finds them all. What those rules mean for a sliced ticket, and what it carries besides:

- Acceptance criteria go in the ticket body as a markdown checklist under the literal `Acceptance criteria` heading *Creating a ticket* names. That heading is the contract: an implementation loop reads the checklist under it as the ticket's task list.
- **Every ticket carries its own context** (from Step 3) — that's what makes later orientation optional.
- Preserve the dependency information — each ticket's *Depends on*, plus whatever blocking link the system offers.
- Fill the header block the way *Creating a ticket* says — the epic's `Intent-slug`, `Intent` and `Architecture`, copied verbatim once the epic's fields point at the published plans, so a ticket picked up cold still resolves both plans.
- Capture each created ticket's id and URL as you go, in the id form `docs/ISSUE-TRACKER.md` defines. That id is what every later step is handed.

The ticket body: fill the template at `templates/ticket.md`.

**Then write the dependency graph and the execution order down** — in the epic's *Dependency graph and execution order* section, or at the end of the intent doc when the intent has no epic. It is the one part of the breakdown no single ticket carries, and unwritten it dies with this conversation.

### Step 7 — Report

- A table: ticket title → type → group → created id and URL.
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
- ✅ **Every ticket was created by the tracker doc's *Creating a ticket* rules**, carrying exactly one type and its group.
- ✅ **Dependencies mapped**, with the parallelizable tickets marked.
- ✅ **The user confirmed the breakdown** before anything was created.
- ✅ **No ticket crosses a stated non-goal**, rests on an open question, or invents an architecture decision.
- ✅ **Every ticket resolves `Intent-slug`, `Intent` and `Architecture` through the header block *Creating a ticket* gives it**, the epic carries the published plans in its own, and the dependency graph is written down.
