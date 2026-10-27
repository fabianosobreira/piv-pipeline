---
name: piv-slice
description: Cuts a reviewed spec into one ticket per task and an epic that tracks them, then publishes the spec as the intent's one GitHub issue.
argument-hint: "[intent-slug] (blank = starts by asking for it)"
disable-model-invocation: true
allowed-tools:
  - Bash(sh ${CLAUDE_SKILL_DIR}/scripts/lint_ticket.sh *)
  - Bash(git hash-object *)
  - Bash(gh auth status)
  - Bash(gh issue create *)
---

# Slice: Spec → Provable Units of Work

This closes the **plan** step of the PIV loop `docs/piv-loop.md` describes. It writes, under `.piv/[intent-slug]/`, one ticket per task of the spec at `tasks/T-xx/T-xx.md` and the `epic.md` that tracks them, then creates the intent's one GitHub issue, whose body is the whole spec. A ticket is a copy of the part of the spec its task needs, never new text: the spec fixed every decision, and a ticket that adds or rewords one lets the implementation drift from what the user confirmed. Write the epic's free text in the spec's `Language`; the tickets inherit it by copying.

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
- ✅ **Every task of section 9 is in exactly one ticket, and every ticket carries exactly one task**, with no line the spec does not hold.
- ✅ **Every ticket passed `lint_ticket.sh` before anything reached GitHub.**
- ✅ **The epic lists every task with its type, size and dependencies, all `[ ]`, and every open question no ticket carries.**
- ✅ **The user approved the issue at the GATE** before it was created.
- ✅ **The issue exists with the whole spec as its body, and the user as assignee**, and its number, URL and type are in the epic.

## Process

Copy this checklist into your task list. Tick an item only when its step's **Done when** holds.

```
- [ ] Step 1 — Read the spec
- [ ] Step 2 — Orient on the existing surface
- [ ] Step 3 — Cut one ticket per task
- [ ] Step 4 — Map the blockers
- [ ] Step 5 — Write and lint the tickets and the epic
- [ ] Step 6 — Preflight GitHub
- [ ] Step 7 — GATE: confirm the issue
- [ ] Step 8 — Create the issue
- [ ] Step 9 — Report
```

### Step 1 — Read the spec

List every task of section 9 with the IDs in its head (`FR`, `NFR`, `C`, `D`) and its `Depends on`. List every open question of section 8 with the IDs it cites.

**Done when** every task is listed and the spec's `Status`, `Intent-slug` and `Language` are read.

### Step 2 — Orient on the existing surface

Size needs a look at what exists. Read the files and directories the tasks name, and where they land. Greenfield with nothing built yet: skip this step, and say so.

**Done when** each task has the surface it touches, enough to give it a rough size.

### Step 3 — Cut one ticket per task

One task is one ticket — never two tasks in one, whoever asks, and never a task split. Each task is implemented, reviewed and committed on its own, so it has to be provable on its own by its `DoD`. A task that cannot be — its `DoD` needs another task's code, or names no check — is a defect of the spec → **STOP**, naming the task and why, and point at `piv-review-spec`, or at `piv-spec` when the task plan needs reshaping.

For each task take, from the spec:

- **Title** — the task's description: the text between the head's colon and ` | Depends on`.
- **Type** — exactly one of `bug`, `feature` and `none`, as `docs/piv-loop.md` defines them, from the task's text.
- **Size** — `S`, `M` or `L`, judged from the surface listed in Step 2 and the lines of change one focused loop can finish.

**Done when** every task has its title, type and size, and every task is provable on its own.

### Step 4 — Map the blockers

A ticket's `Blocked by` is exactly the tasks its task lists in `Depends on`, as `T-xx` ids, or `none`.

**Done when** every ticket has its `Blocked by`, and every task's dependencies come before it in the spec's order.

### Step 5 — Write and lint the tickets and the epic

Write each ticket at `.piv/[intent-slug]/tasks/T-xx/T-xx.md`, from `${CLAUDE_SKILL_DIR}/templates/ticket.md` used exactly: the header block, then the 11 sections of the spec. What goes in, line by line — every bullet and table row is a line of the spec, copied character for character with its IDs, and a section with nothing for the task holds only `None in this ticket.`:

- **Sections 1 and 2** — every line, whole.
- **Section 3** — the `FR` lines the task cites.
- **Section 4** — every `AC` whose head cites at least one `FR` the task cites, with its whole line.
- **Section 5** — the `NFR` lines the task cites. **Section 6** — the `C` lines. **Section 7** — the `D` lines.
- **Section 8** — the *Always*, *Ask first* and *Never* levels, whole; under *Open questions*, only the lines that cite an ID the ticket carries.
- **Section 9** — the task's own line, its `Depends on` as written.
- **Section 10** — the table header and the rows of the `AC` copied to section 4.
- **Appendix** — the table header and the decision-log row of every `Q` cited anywhere in the ticket, whole.

The header block: `Spec` as `[spec path] @ [hash]`, with the hash from `git hash-object --no-filters [spec path]`; `Task`, the task's id; `Type`, `Blocked by` and `Size` from Steps 3 and 4; `Intent-slug` and `Language` copied from the spec.

Validate each ticket with `sh ${CLAUDE_SKILL_DIR}/scripts/lint_ticket.sh [ticket path] [spec path]` — run it, do not read it; it needs a POSIX `sh`, `awk`, `tr`, `cmp` and `git`. Fix the ticket, never the spec, until it prints `RESULT: OK`.

Then write `.piv/[intent-slug]/epic.md` from `${CLAUDE_SKILL_DIR}/templates/epic.md`, used exactly, in the grammar `docs/piv-loop.md` gives: every task `[ ]` with its title, type, size and `Depends on`; `Issue`, `Type` and `Branch` reading `pending`; and under *Not ticketed*, every open question of section 8 that no ticket carries.

**Done when** every ticket printed `RESULT: OK` and the epic lists every task. Nothing reaches GitHub while any ticket has findings.

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
- the epic's task list and *Not ticketed*.

End the turn and wait. The user's approval is the only thing that creates the issue.

**Done when** the user approved the issue, with its type.

### Step 8 — Create the issue

Create it with `gh issue create`: the title from Step 7, the body from the spec file itself, passed as a file — `.piv/[intent-slug]/spec.md` — never retyped, and `@me` as assignee. Capture the number and URL it prints and write them into the epic's `Issue` as `#N` and the URL, and the approved type into its `Type`. A creation that fails → **STOP** with `gh`'s message; the epic keeps `Issue: pending`, so a rerun starts over.

**Done when** the issue exists and the epic's `Issue` and `Type` name it.

### Step 9 — Report

Report a table of task → type → size → depends on; the issue number and URL; the spec path and the hash the tickets were cut from; and **what was not ticketed** — the open questions no ticket carries.

**Done when** every task is in the table and every *Not ticketed* line is in the report.

## Hand off

Confirm where the epic and the tickets landed, by path, and the issue by number and URL, then offer the next move and let the user run it — this skill does not chain into the next one:

- **Start the first task** — run `piv-implement [#N]`, in a session of its own. It picks the next task from the epic.
