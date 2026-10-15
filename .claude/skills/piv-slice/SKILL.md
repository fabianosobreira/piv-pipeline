---
name: piv-slice
description: Cuts a ready spec into tickets, each a verbatim slice of the spec, then creates them on the project's tracker, under an epic when there is more than one.
argument-hint: "[spec path] (blank = starts by asking for it)"
disable-model-invocation: true
allowed-tools: Bash(sh ${CLAUDE_SKILL_DIR}/scripts/lint_ticket.sh *), Bash(git hash-object *)
---

# Slice: Spec → Provable Units of Work

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes. A ticket is a copy of the part of the spec its tasks need, never new text: the spec fixed every decision, and a ticket that adds or rewords one lets the implementation drift from what the user confirmed. Write the epic's free text in the spec's `Language`; the tickets inherit it by copying.

## Input — a spec with `Status: ready`

`$ARGUMENTS` carries the path of a spec written by `piv-spec`, a local file where `docs/issue-tracker.md` says plans live. Read `docs/issue-tracker.md` first: Step 6 follows its *Creating a ticket* rules. Nothing passed → ask for the spec. **GATE.** Handed anything else — a PRD, an idea, a brief → **STOP**: it is not sliceable, and `piv-spec` turns it into a spec first.

Read the spec end to end. Its header decides whether the run goes on:

- `Status: draft` → **STOP** and say that the spec has to be concluded in `piv-spec`. Nothing is created.
- No `Intent-slug` or `Language` field → **STOP** and say that the spec predates the format and has to be rewritten in `piv-spec`.
- `Status: ready` → go on.

**The epic is this skill's output, never its input, and it exists only when the breakdown has more than one ticket.** Neither the spec nor a PRD is published to the tracker: each ticket carries what it needs.

## Success criteria

- ✅ **The spec was `Status: ready`**; with `draft`, nothing was created.
- ✅ **Every task of section 8 is in exactly one ticket**, and no ticket holds a line the spec does not.
- ✅ **Every ticket passed `lint_ticket.sh` before any ticket was created.**
- ✅ **The user confirmed the breakdown** before anything was created — or skipped the GATE, and the calls made for them are recorded as **(decided-by-default)**.
- ✅ **Every ticket was created by the *Creating a ticket* rules of `docs/issue-tracker.md`**, with exactly one type, a `Blocked by` that names the ticket of each task it depends on, and, with an epic, a `Part of`.
- ✅ **With an epic, it lists the tickets, the dependency graph and the execution order, and what was not ticketed.**

## Process

Copy this checklist into your task list. Tick an item only when its step's **Done when** holds.

```
- [ ] Step 1 — Read the spec
- [ ] Step 2 — Orient on the existing surface
- [ ] Step 3 — Cut the slices
- [ ] Step 4 — Map the blockers
- [ ] Step 5 — GATE: confirm the breakdown
- [ ] Step 6 — Draft and validate every ticket, then create them
- [ ] Step 7 — Report
```

### Step 1 — Read the spec

List every task of section 8 with the IDs in its head (`FR`, `NFR`, `C`, `D`) and its `Depends on`. List every open question of section 10 with the IDs it cites.

**Done when** every task is listed and the spec's `Status`, `Intent-slug` and `Language` are read.

### Step 2 — Orient on the existing surface

Size needs a look at what exists. Explore it yourself: read the files and directories the tasks name, and where they land. Greenfield with nothing built yet: skip this step, and say so.

**Done when** each task has the surface it touches, enough to give it a rough size.

### Step 3 — Cut the slices

A slice is one task. Take one ticket per task by default; group tasks into one ticket only when the user asks at the Step 5 GATE or a task cannot be proved without its neighbor. A task is never split, because its line is the smallest thing a ticket copies.

For each slice draft what the header block and the tracker need — the content comes from the spec:

- **Title** — the task's description: the text between the head's colon and ` | Depends on`.
- **Type** — exactly one of `bug`, `feature` and `task`, as `docs/issue-tracker.md` defines them: from the task's text, `bug` when it repairs behavior the spec says diverges, `feature` when it adds a capability, `task` for refactor, docs, chore and infra.
- **Size** — `S`, `M` or `L`, judged from the surface listed in Step 2 and the number of lines of change one focused loop can finish.

**Done when** every task is in a slice, each slice has its title, type and size.

### Step 4 — Map the blockers

A slice is blocked by the ticket of each task its tasks list in `Depends on`, when that task sits in another slice. Slices with no such task are independent and can run in parallel. A grouping that makes two slices wait on each other is regrouped.

**Done when** every slice is independent or lists the slices that block it, and the creation order puts every blocker before the ticket it blocks.

### Step 5 — GATE: confirm the breakdown

Say which tracker you are writing to and whether the breakdown gets an epic — it does when it has more than one ticket — then **GATE** — post the ticket titles, their types, the task each carries, their sizes, the dependency graph, and, under **Not ticketed**, every open question that no ticket carries. Then **stop. End the turn and hand the decision to the user.** Their approval is the only thing that moves this forward — never roll into creating the tickets on your own, and never treat your own judgment as their approval.

**If they skip the GATE** ("just create them"): honor it, but name the calls you made on their behalf — the types, the sizes, the grouping and the dependency graph — and record them as **(decided-by-default)** in the epic's *Dependency graph and execution order* (with no epic, in the Step 7 report), never as though the user had ruled on them.

**Done when** the user approved the breakdown — or skipped the GATE, and the calls made for them are named.

## Output — create the tickets

### Step 6 — Draft and validate every ticket, then create them

Write the epic's free text in the spec's `Language`; template labels stay as written. Before creating anything, confirm you can reach the tracker `docs/issue-tracker.md` names, with the tool it names or whatever fits when it names none. If nothing reaches it → **STOP** and say so: a run that fails midway leaves a partial backlog.

Plan → validate → execute:

1. **Draft every ticket body** in a file outside the repository's tracked paths, using `templates/ticket.md` exactly: the header block, then the 11 sections of the spec. Fill each section by the rules below. Ids that do not exist yet are written `#0`, one for each blocker in `Blocked by` and for `Part of`.
2. **Validate each draft** with `sh ${CLAUDE_SKILL_DIR}/scripts/lint_ticket.sh [ticket file] [spec path]` — run it, do not read it; it needs a POSIX `sh`, `awk`, `tr`, `cmp` and `git`. Fix the draft, never the spec, until it prints `RESULT: OK`. **No ticket is created while any draft has findings.**
3. **Create, in creation order.** With an epic, create it first, from `templates/epic.md`, used exactly, where `docs/issue-tracker.md` says. Then create each ticket by the *Creating a ticket* rules, blockers first. Before creating a ticket, replace each `#0` in its `Part of` and `Blocked by` with the real id, and validate the body again. Capture each ticket's id and URL as soon as it exists, in the id form `docs/issue-tracker.md` defines, and, with an epic, add its line to the epic's *Tickets* list. That id is what every later step is handed.
4. **With an epic, then write the dependency graph and the execution order** in the epic's *Dependency graph and execution order* section, and the open questions no ticket carries in its *Not ticketed* section.

What goes in a ticket, line by line — every bullet and every table row is a line of the spec, copied character for character with its IDs, and a section with nothing for the slice holds only `None in this ticket.`:

- **Sections 1 and 2** — every line, whole.
- **Section 3** — the `FR` lines the slice's tasks cite. **Section 4** — the `NFR` lines they cite. **Section 6** — the `C` lines. **Section 7** — the `D` lines.
- **Section 5** — every `AC` whose head cites at least one `FR` of the slice, with its whole line, even when the head also cites an `FR` outside the slice.
- **Section 8** — the slice's own task lines. A task that depends on a task in another ticket keeps its `Depends on` as written, and that ticket's id goes in `Blocked by`; the line of the other ticket's task is not copied.
- **Section 9** — the table header and the rows of the `AC` copied to section 5.
- **Section 10** — the *Always*, *Ask first* and *Never* levels, whole; under *Open questions*, only the lines that cite an ID of the slice, even when a line also cites an ID outside it.
- **Appendix** — the table header and the decision-log row of every `Q` cited anywhere in the ticket, whole.

The header block follows `templates/ticket.md`: `Part of` only with an epic, `Spec` as `[spec path] @ [hash]` with the hash from `git hash-object --no-filters [spec path]`, then `Slice`, `Blocked by`, `Size`, `Intent-slug` and `Language` copied from the spec.

Every ticket, in either branch:

- Its section headings are the contract: an implementation loop reads the task list under section 8, the criteria under section 5 and the commands under section 9.
- Its blockers are kept twice: in `Blocked by`, and in whatever blocking link the tracker offers.
- The spec and the PRD are not posted anywhere: the epic carries no comment, and neither does a ticket.

**Done when** every ticket is created with its id and URL captured; with an epic, its *Tickets* list is complete and the dependency graph is written.

### Step 7 — Report

Report a table of ticket title → type → created id and URL; the spec the backlog was generated from, by path and hash; the execution order — which tickets can start now, in parallel, and which are waiting; **what you deliberately did *not* ticket** — the open questions no ticket carries; and, with the GATE skipped, the **(decided-by-default)** calls.

**Done when** every created ticket is in the table and every *Not ticketed* note is in the report.

## Hand off

Confirm the epic's id, when there is one, and where the tickets landed, then offer the next move and let the user run it — this skill does not chain into the next one:

- **Start the first ticket** — run `piv-implement [ticket id]`, in a session of its own, one per ticket.
- **Run a wave in parallel** — the independent tickets from Step 4 can start at the same time, each in a session of its own.

Plan just-in-time: a dependent ticket waits until its blocker is *implemented*.
