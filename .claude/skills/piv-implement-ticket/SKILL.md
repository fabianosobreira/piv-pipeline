---
name: piv-implement-ticket
description: Implements a ticket task by task on its own branch, validating at every step, and writes an implementation report.
argument-hint: "[ticket id, or a plan document path] (blank = starts by asking which ticket)"
disable-model-invocation: true
---

# Implement: Build from the Ticket

This is the **implement** step of the PIV loop `docs/PIV-LOOP.md` describes.

## Process

### Step 1 — Resolve the ticket

`$ARGUMENTS` says what to implement. Three forms:

- **A ticket id** — read that ticket where `docs/ISSUE-TRACKER.md` says tickets live, reaching that system with whatever tool fits. When the ticket can't be read — missing, already closed, the system unreachable — **STOP** and say which it was.
- **A file path** — read that file; it is a **plan document**, the one input that is not a ticket.
- **Nothing** — ask the user which ticket to implement. Only work the user names counts. **GATE.**

From here on, **the ticket governs the run**. A plan document stands in for the ticket everywhere below — same rules, same gates — and the only difference is that it has no id, so the intent-slug takes the id's place in file names.

If the ticket carries no actionable tasks, say so and ask the user what to implement. **GATE.**

When the goal is repairing observed broken behavior — a bug ticket, or a defect the user reported — this run is a **repair**, and the instructions marked **Repair:** apply on top of the normal ones. A repair run is done only when every instruction marked **Repair:** is satisfied.

**Check the dependencies.** When the ticket names a **Depends on**, confirm that dependency is implemented — merged, or committed on the base branch. It isn't → **STOP** and say which ticket has to land first; building against a sliced-but-unbuilt dependency plans against a guess.

### Step 2 — Work on a branch

The work gets built on its own branch, so it can become one PR. `docs/GIT-CONVENTIONS.md` defines the base branch and the branch name — read it before creating anything.

- **On the base branch, clean** → create a branch following that convention. The ticket id belongs in the name: `piv-commit-changes` and `piv-create-pr` read the id back out of it.
- **Already on a feature branch or in a worktree** → use it. For a ticket, warn if the branch name doesn't reference it.
- **On the base branch with uncommitted changes** → **STOP**: commit or stash first.

**Then mark the ticket in flight**, the way `docs/ISSUE-TRACKER.md` says this project marks it. That is what keeps a parallel wave from picking up the same ticket twice.

### Step 3 — Read the ticket end to end

Before any edit, read the ticket's **`Architecture`** field and its **Per-ticket context** first — the architecture doc, the guides and seams it names — then write into your working notes: the task list with the dependencies between tasks, every check the ticket names, and its **Testing strategy**. **The ticket's Acceptance criteria are that task list.** **Repair:** also the root cause, and whether the proposed fix still addresses it.

**If the field says `none`**, no architecture doc was produced for this ticket — proceed without one. **Otherwise it names a path or a URL** — resolve it wherever `docs/ISSUE-TRACKER.md` says plans live. Unresolvable there, and not attached to the ticket or its epic either → **STOP** and ask for it; building without the architecture the ticket was sliced against plans against a guess.

### Step 4 — Drift check

Where the ticket quotes existing code or cites line refs, open those files and compare. **STOP** when any quoted code no longer exists, has moved, or changed in a way that makes the ticket's instruction for it unperformable — surface the drift and say the ticket needs to be redone against the current code. Cosmetic differences (formatting, renamed locals, shifted line numbers with identical code) are not drift. **Repair:** also confirm the defect still reproduces before changing anything.

### Step 5 — Execute tasks in order

Work through the tasks in order. When the ticket carries an explicit task list, that list is the order. When it doesn't — acceptance criteria that describe the outcome in prose — derive the list yourself in step 3, and check it covers everything the ticket asks for before you touch any code.

#### a. Implement the task
- Follow the ticket's specification for this task, and match the patterns already present in the files you're editing.
- Update the code the change reaches — imports, callers, call sites — and stop there.

#### b. Verify as you go
**Run the task's own check before starting the next task.** When the ticket names a check for the task, run that one. When it names none — acceptance criteria without checks, or a task written without one — run the closest relevant check instead: the test file you just touched, the linter on the changed file. A task goes **green** when its check passes, and a red task gets fixed before the next one starts. Step 7 runs the ticket's checks in full; this per-task gate is what keeps step 7 from becoming a pile-up.

**Stay in scope:** implement what the ticket specifies. Refactors, improvements, and unrelated problems you find along the way each become their own ticket, and this branch carries this ticket's work only. When you must deviate, note what changed and why, and surface it in the report's *Deviations*.

#### c. When evidence contradicts a decision
When something you hit mid-task undercuts an assumption a decision rests on — not just a missing detail — name the assumption, the evidence against it, the decision it affects, and whether that decision's rationale survives without it. The user resolves it before the architecture changes. **GATE.**

#### d. When a detail is unspecified
Beyond matching the surrounding file's patterns (5a), prefer in order: precedent the ticket or its architecture doc already cites; the smallest change consistent with the ticket's decision; **GATE** and ask when the choice would move an architectural boundary the ticket never drew.

### Step 6 — Close the testing strategy

Tests that belong to a task are written with that task in step 5. This step is the sweep for whatever the ticket's **Testing strategy** asks for and step 5 didn't already deliver:

- Every test file and every test case the ticket names now exists.
- **Repair:** at minimum, a test that fails without the fix and passes with it, plus tests for the edge cases around the bug. Name the test so it traces back to the ticket id.

### Step 7 — Run the checks

Run every check the ticket names, in the order it gives them. When it names none, run the project's own checks — the test, lint, type-check, and build commands the repo exposes.

When a check goes red: fix the cause, re-run, and continue once it is green.

When a failure survives a few honest attempts, or its cause sits outside what the ticket asks you to change, stop working it: record the check, the failure, and what you tried in the report's *Issues encountered*, and carry the run to step 8 as PARTIAL.

### Step 8 — Final verification

Before you write the report, walk the **Success criteria** at the end of this skill, line by line. Every line true → the status is COMPLETE. Any line that isn't true → the status is PARTIAL, and that line goes into the report's *Issues encountered*, named.

## Output — write an implementation report

Write a short report at the implementation report path `docs/ISSUE-TRACKER.md` defines, filling the template at `templates/implementation-report.md`, and print the summary. Carry the ticket's `Intent-slug`, `Intent` and `Architecture` — or the plan document's — into its header block, so a run with no ticket to read still resolves both plans. This is what the `piv-review-changes` gate reads — especially the **deviations** (a documented deviation is an *intentional* decision the reviewer should not flag).

## Hand off

Next: `piv-review-changes` gates the work before anything is committed, in a session of its own. Hand it the ticket id; it travels on to the commit, so the commit message links back to it.

## Success criteria

- ✅ Every task on the list from step 3 is implemented.
- ✅ Every test the ticket asks for exists and passes.
- ✅ Every check run in step 7 is green.
- ✅ The change matches the patterns of the files it touched (step 5a).
- ✅ Documentation the change made stale is updated.
- ✅ **Repair:** the reproduction steps no longer reproduce the defect, and the tests around the touched code still pass.
