---
name: piv-slice
description: Cuts a reviewed spec into tasks, one ticket per task and an epic that tracks them, then publishes the spec as the intent's one GitHub issue.
argument-hint: "[intent-slug] (blank = starts by asking for it)"
disable-model-invocation: true
allowed-tools:
  - Bash(sh ${CLAUDE_SKILL_DIR}/scripts/lint_ticket.sh *)
  - Bash(sh ${CLAUDE_SKILL_DIR}/scripts/lint_epic.sh *)
  - Bash(git hash-object *)
  - Bash(gh auth status)
  - Bash(gh issue create *)
---

# Slice: Spec → Provable Units of Work

This closes the **plan** step of the PIV loop `docs/piv-loop.md` describes. It cuts the spec into tasks, writes, under `.piv/[intent-slug]/`, one ticket per task at `tasks/T-xx/T-xx.md` and the `epic.md` that tracks them, then creates the intent's one GitHub issue, whose body is the whole spec. The spec fixes the requirements; the cut into tasks is this skill's own call. A ticket has two parts: a header this skill writes — title, type, size, blockers, the criteria the task proves, the items it cites — and sections copied from the spec. Never reword, add or drop a line of the spec in a section: the user confirmed each one, and a ticket that changes one lets the implementation drift from it. Write the epic's free text in the spec's `Language`; the tickets inherit it by copying.

## Input — a reviewed spec

`$ARGUMENTS` carries the intent-slug. Nothing passed → list each `.piv/[slug]/spec.md` that says `Status: reviewed` and ask which. **GATE.** No spec at `.piv/[intent-slug]/spec.md` → **STOP**: `piv-spec` writes it first.

The spec's header, and `.piv/[intent-slug]/spec.review.md`, decide whether the run goes on:

- `Status: draft` → **STOP**: the spec has to be concluded in `piv-spec`.
- `Status: ready` → **STOP**: the spec has to be reviewed in `piv-review-spec` first.
- `Status: reviewed`, but `git hash-object --no-filters [spec path]` differs from the `Reviewed-hash` of `spec.review.md`, or there is none → **STOP**: the spec changed after its review; run `piv-review-spec` again.
- `Status: reviewed` and the hashes match → go on.

An `epic.md` already there decides it too:

- Its `Issue` holds a number → **STOP**: the intent is already published as that issue.
- Its `Issue` reads `pending` → an earlier run stopped before the issue. Start over, and ask before overwriting each ticket already under `tasks/`. **GATE.**

## Success criteria

- ✅ **The spec was reviewed at its current revision**; otherwise nothing was written.
- ✅ **Every task is provable on its own, and every `AC` of the spec is in the DoD of exactly one ticket**, with every `NFR`, `C` and `D` cited by at least one.
- ✅ **Every ticket carries exactly one task, and every section of it holds only lines of the spec.**
- ✅ **Every ticket passed `lint_ticket.sh`, and the cut passed `lint_epic.sh`, before anything reached GitHub.**
- ✅ **The epic lists every task with its type, size and dependencies, all `[ ]`, the reason of every task sized `L`, and every open question no ticket carries.**
- ✅ **The GATE showed, for every task, why it is provable on its own**, and the user approved the issue there before it was created.
- ✅ **The issue exists with the whole spec as its body, and the user as assignee**, and its number, URL and type are in the epic.

## Process

### Step 1 — Read the spec

List every `FR`, `AC` (with the `FR` its head cites), `NFR`, `C` and `D`, every row of section 9, and every open question of section 8 with the IDs it cites.

**Done when** every item is listed and the spec's `Status`, `Intent-slug` and `Language` are read.

### Step 2 — Orient on the existing surface

The cut needs a look at what exists. Read the files and directories that `C` and `D` items name and where the `FR` land. Greenfield with nothing built yet: skip this step, and say so.

**Done when** each `AC` has the surface it touches, enough to judge the seams of a task, or the skip is stated.

### Step 3 — Cut the tasks

No user question here: the cut is this skill's call, and the report shows it. A task is implemented, reviewed and committed on its own, so it has to be provable on its own: its `AC` pass with the code of its blockers and no other task. A task that cannot be, because an `AC` has no verification in section 9 or an `FR` has no `AC`, is a defect of the spec → **STOP**, naming the item, and point at `piv-review-spec`, or at `piv-spec` when the interview has to be redone.

**The test.** A task is one *concern*: one verifiable outcome. Two `AC` that independent changes could satisfy are two concerns, so two tasks. Cut by dependency, by concern, or as a slim end-to-end slice, whichever makes each task easiest to prove; slice vertically, never by horizontal layer. Put two concerns in one task only when their `AC` cannot be proven apart, whoever asks; that task is `L`.

For each task write:

- **Title** — one imperative sentence naming one outcome, with no conjunction joining two, unless the task is `L` (`Add token refresh endpoint`, not `Auth`).
- **DoD** — the `AC` ids the task proves. Every `AC` of the spec is in exactly one DoD. An `AC` that an independent change could satisfy apart from the others belongs in another task, unless they cannot be proven apart (`L`).
- **Cites** — the `NFR`, `C` and `D` ids the task needs; `none` when it needs none. A `C` or `NFR` is needed by every task whose surface (Step 2) it covers — a stack constraint such as the runtime version, by every task that writes code — and a `D` by every task that changes or follows it. Every `NFR`, `C` and `D` is cited by at least one task. The `FR` need no entry: each comes from the `AC` that cite it.
- **Type** — exactly one of `bug`, `feature` and `none`, as `docs/piv-loop.md` defines them, from the text of the `FR` behind its `AC`.
- **Size** — `S`, `M` or `L`, from the *seams* the task crosses: a seam is a boundary the change crosses, such as a top-level module or directory (Step 2) or a `D` item it changes.
  - `S`: one concern, at most one seam.
  - `M`: one concern, two or more seams.
  - `L`: two concerns whose `AC` cannot be proven apart. Try to split it first; when no split gives tasks provable on their own, keep `L` and write the reason under *Large tasks* in the epic.

**Done when** every `AC` is in one DoD, every `NFR`, `C` and `D` is cited, and each task has its title, DoD, cites, type and size.

### Step 4 — Map the blockers

A task's `Blocked by` is exactly the tasks whose code its DoD needs, as `T-xx` ids, or `none`. Number the tasks in execution order: every blocker comes before the task it blocks, so no dependency is a cycle.

**Done when** every task has its `Blocked by`, and every blocker comes before its task.

### Step 5 — Write and lint the tickets and the epic

A re-cut can leave tickets of tasks the new cut no longer has. List each `tasks/T-xx/` that is not in the cut and ask before deleting it. **GATE.** Delete only a folder that holds nothing but its ticket; one that holds a report, a review or fixes is work to keep → **STOP**, naming it.

Write each ticket at `.piv/[intent-slug]/tasks/T-xx/T-xx.md`, from `${CLAUDE_SKILL_DIR}/templates/ticket.md` used exactly: the header block, then the 10 sections of the spec (9 numbered ones and the appendix). What goes in a section, line by line — every bullet and table row is a line of the spec, copied character for character with its IDs, and a section with nothing for the task holds only `None in this ticket.`:

- **Sections 1 and 2** — every line, whole.
- **Section 3** — the `FR` lines that an `AC` of the DoD cites.
- **Section 4** — the `AC` lines of the DoD, whole.
- **Section 5** — the `NFR` lines in `Cites`. **Section 6** — the `C` lines. **Section 7** — the `D` lines.
- **Section 8** — the *Always*, *Ask first* and *Never* levels, whole; under *Open questions*, only the lines that cite an ID the ticket carries.
- **Section 9** — the table header and the rows of the `AC` of the DoD.
- **Appendix** — the table header and the decision-log row of every `Q` cited anywhere in the ticket, whole.

The header block: `Spec` as `[spec path] @ [hash]`, with the hash from `git hash-object --no-filters [spec path]`; `Task`, `Title`, `Type`, `Blocked by`, `Size`, `DoD` and `Cites` from Steps 3 and 4; `Intent-slug` and `Language` copied from the spec.

Validate each ticket with `sh ${CLAUDE_SKILL_DIR}/scripts/lint_ticket.sh [ticket path] [spec path]` — run it, do not read it; it needs a POSIX `sh`, `awk`, `tr`, `cmp` and `git`. Fix the ticket, never the spec, until it prints `RESULT: OK`.

Then write `.piv/[intent-slug]/epic.md` from `${CLAUDE_SKILL_DIR}/templates/epic.md`, used exactly, in the grammar `docs/piv-loop.md` gives: every task `[ ]` with its title, type, size and `Depends on`; under *Large tasks*, the reason of every task sized `L`; `Issue`, `Type` and `Branch` reading `pending`; and under *Not ticketed*, every open question of section 8 that no ticket carries.

Check the cut with `sh ${CLAUDE_SKILL_DIR}/scripts/lint_epic.sh .piv/[intent-slug]` — run it, do not read it; it needs a POSIX `sh`, `awk` and `git`. A finding is a defect of the cut: fix the tickets and the epic, never the spec, until it prints `RESULT: OK`.

**Done when** every ticket printed `RESULT: OK`, the epic lists every task, and `lint_epic.sh` printed `RESULT: OK`. Nothing reaches GitHub while any of them has findings.

### Step 6 — Preflight GitHub

Check, in order, and **STOP** on the first that fails, with the command that fixes it:

1. `gh auth status` passes — else `gh auth login`.
2. The `origin` remote is on `github.com`.

**Done when** both hold.

### Step 7 — GATE: confirm the issue

Post, then **GATE**:

- the issue title — the spec's title, the text after `# Spec:`;
- the proposed issue type — the largest effect among the tasks' types, `feature` over `bug` over `none` — with the type of each task behind it, and that the user may pick another of `bug`, `feature` and `none`;
- **"The spec will be published in full as the issue body."**;
- the local spec as a clickable relative link, such as `[spec.md](.piv/[intent-slug]/spec.md)`;
- the epic's task list, with each task's size, DoD and blockers, its *Large tasks* and *Not ticketed*. This is where the cut becomes visible;
- for each task, one line on why its DoD passes with the code of its blockers and no other task.

End the turn and wait. The user's approval is the only thing that creates the issue.

A cut the user rejects is re-cut in this run: take their reasons as the new constraint on the cut, go back to Step 3, rewrite and re-lint as Steps 3 to 5 say, and post this GATE again. Their reasons are input to the cut, not a question the skill asks.

**Done when** the GATE showed the reason for every task and the user approved the issue, with its type.

### Step 8 — Create the issue

Create it with `gh issue create`: the title from Step 7, the body from the spec file itself, passed as a file — `.piv/[intent-slug]/spec.md` — never retyped, and `@me` as assignee. Capture the number and URL it prints and write them into the epic's `Issue` as `#N` and the URL, and the approved type into its `Type`. A creation that fails → **STOP** with `gh`'s message; the epic keeps `Issue: pending`, so a rerun starts over.

**Done when** the issue exists and the epic's `Issue` and `Type` name it.

### Step 9 — Report

Report a table of task → type → size → files the task will touch (Step 2) and `AC` count → depends on; the reason of every task sized `L`; the issue number and URL; the spec path and the hash the tickets were cut from; and **what was not ticketed** — the open questions no ticket carries.

**Done when** every task is in the table and every *Not ticketed* line is in the report.

## Hand off

Confirm where the epic and the tickets landed, by path, and the issue by number and URL, then offer the next move and let the user run it — this skill does not chain into the next one:

- **Start the first task** — run `piv-implement [#N]`, in a session of its own. It picks the next task from the epic.
