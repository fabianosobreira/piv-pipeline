---
name: piv-implement-ticket
description: Implements a ticket task by task on its own branch, validating at every step, and writes an implementation report.
argument-hint: "[ticket id] (blank = starts by asking which ticket)"
disable-model-invocation: true
---

# Implement Ticket: Build from the Ticket

This is the **implement** step of the PIV loop `docs/PIV-LOOP.md` describes.

## Process

### Step 1 — Resolve the ticket

`$ARGUMENTS` carries the ticket id. Nothing passed → ask the user which ticket to implement. Only a ticket the user names counts. **GATE.**

Read that ticket where `docs/ISSUE-TRACKER.md` says tickets live, reaching that system with whatever tool fits. When the ticket can't be read — missing, already closed, the system unreachable — **STOP** and say which it was.

From here on, **the ticket governs the run**. If it carries no actionable tasks → **STOP**: say so, and that the ticket needs reworking before it can be built.

When the ticket's type is `bug`, this run is a **repair**, and the instructions marked **Repair:** apply on top of the normal ones. A repair run is done only when every instruction marked **Repair:** is satisfied.

**Fetch the base branch** `docs/GIT-CONVENTIONS.md` defines. From here on, *the base* is its remote tip: the local copy lags whatever merged since the last pull.

**Check the dependencies.** When the ticket names a **Depends on**, confirm that dependency is implemented — merged into the base. It isn't → **STOP** and say which ticket has to land first; building against a sliced-but-unbuilt dependency plans against a guess.

### Step 2 — Work on a branch

The work gets built on its own branch, so it can become one PR. `docs/GIT-CONVENTIONS.md` defines the branch name — read it before creating anything. A branch this run creates starts from the base.

- **On the base branch, clean** → create the branch, then record the baseline on it. The ticket id belongs in the name: every later step of the loop reads the id back out of it.
- **Already on a feature branch or in a worktree** → record the baseline in a worktree of the base, then use the branch. Warn if the branch name doesn't reference it.
- **On the base branch with uncommitted changes** → **STOP**: commit or stash first.

**The baseline** is the project's full test suite run against the base before you change anything, with the setup the branch run will use, noting every test that failed an assertion there and which one — so Step 6 can tell the failures this change caused from the ones it found. A worktree for it goes outside the repository and is removed afterwards. **The project has no test suite** → say so, skip the baseline, and carry on without tests: this run implements the ticket, and setting up a suite is not its job. Every test instruction below then falls away, and the report's *Tests added* says why.

### Step 3 — Read the ticket end to end

Before any edit, read the ticket's **`Architecture`** field and its **Entry context** first — the decisions it cites, the starting code, the external references and what the neighbors own; on a deferral, its **Origin** and **Evidence** — then write into your working notes: the task list with the dependencies between tasks, every check the ticket names, and its **Testing strategy**. **The ticket's Acceptance criteria are that task list**, when they already read as one; criteria written as outcome prose instead carry no explicit order, so derive the task list from them yourself, and check the list covers everything the ticket asks for before you touch any code. **Repair:** also the root cause — on a sliced ticket, its *Root cause*; on a deferral, *Origin › Location* and *Evidence* — and whether the proposed fix still addresses it.

**If the `Architecture` field says `none`**, no architecture doc was produced for this ticket — proceed without one. **Otherwise it names a path or a URL** — resolve it wherever `docs/ISSUE-TRACKER.md` says plans live. Unresolvable there → **STOP**, asking for it; building without the architecture the ticket was sliced against plans against a guess.

**When *Entry context › Decisions* cites sections of the intent**, resolve the ticket's `Intent` field the same way and read those sections. The ticket cites the intent instead of copying it, so the run has to read what it cites. Unresolvable → **STOP**, asking for it.

**The Testing strategy says which tests, never whether.** "project defaults" means the project's own testing standard applies. A strategy that waives the tests for a behavior the ticket adds or alters → ask whether to write them anyway or rework the ticket. **GATE.** With no test suite (Step 2), skip this.

**Then check for drift.** Where the ticket quotes existing code or cites line refs, open those files and compare. Drift → **STOP**, saying the ticket needs to be redone against the current code: any quoted code that no longer exists, has moved, or changed in a way that makes the ticket's instruction for it unperformable. Cosmetic differences (formatting, renamed locals, shifted line numbers with identical code) are not drift. **Repair:** also confirm the defect still reproduces before changing anything, by the ticket's *Reproduction* — on a deferral, by its *Evidence* — and when it doesn't → **STOP**, saying the ticket is stale or already fixed.

**Then mark the ticket in flight**, the way `docs/ISSUE-TRACKER.md` says this project marks it. That is what keeps a parallel wave from picking up the same ticket twice.

### Step 4 — Execute tasks in order

Work the task list from Step 3, in order.

#### a. Implement the task
- Follow the ticket's specification for this task, and match the patterns already present in the files you're editing.
- Update the code the change reaches — imports, callers, call sites — and any documentation the change makes stale.
- Write the tests for the behavior this task adds or alters, together with the task — unless the project has no test suite (Step 2).

#### b. Verify as you go
**Run the task's own check before starting the next task.** When the ticket names a check for the task, run that one. When it names none — acceptance criteria without checks, or a task written without one — run the closest relevant check instead: the tests that exercise the behavior the task touched, plus the linter on the changed file. A task goes **green** when its check passes, and a red task gets fixed before the next one starts. When a failure survives a few honest attempts, apply the same escape Step 6 uses: record it and carry the run to Step 7 as PARTIAL rather than block here. Step 6 runs the full suite; this per-task gate is what keeps Step 6 from becoming a pile-up.

**Stay in scope:** implement what the ticket specifies. Refactors, improvements, and unrelated problems you find along the way each become their own ticket, and this branch carries this ticket's work only. When you must deviate, note what changed and why, and surface it in the report's *Deviations from the ticket*.

#### c. When a decision is missing or contradicted
A detail the ticket leaves unspecified: beyond matching the surrounding file's patterns (Step 4a), prefer in order the precedent the ticket or its architecture doc already cites, then the smallest change consistent with the ticket's decision.

Two things are not yours to settle: something you hit mid-task that undercuts an assumption a decision rests on — not just a missing detail — and a choice that would move an architectural boundary the ticket never drew. Name the assumption and the evidence against it, or the boundary and the options, along with the decision it affects and whether that decision's rationale survives. The user resolves it before the architecture changes. **GATE.**

### Step 5 — Close the testing strategy

This step is the sweep that proves the change left nothing untested. With no test suite (Step 2) there is nothing to sweep: *Tests added* says so, and the run moves on to Step 6.

- Every test file and every test case the ticket's **Testing strategy** names now exists, runs, and asserts the behavior it is named for.
- Every behavior the change adds or alters — an observable outcome an acceptance criterion or the unit's public interface names — has at least one test that exercises it. Only a change with no testable behavior, such as docs or config that changes no observable outcome, goes without one, and the report's *Tests added* says so.
- **Repair:** at minimum, a test that fails without the fix and passes with it, plus tests for the edge cases around the bug. Name the test so it traces back to the ticket id.

### Step 6 — Run the checks

Run every check the ticket names, in the order it gives them, then the project's own checks in full — the whole test suite, lint, type-check, and build commands the repo exposes. The change reaches callers the ticket never named, and only the full suite sees their tests break.

When a check goes red: fix the cause, re-run, and continue once it is green. A test goes green by the code changing: its assertions, and whether it runs at all, change only when the ticket changes the behavior it pins — the review blocks any other change to a test, whatever *Deviations from the ticket* says. A test failing the same assertion the baseline recorded stays red, unless the **Testing strategy** names it or it reproduces the defect a **Repair** fixes: that one is this change's to turn green.

When a failure survives a few honest attempts, or its cause sits outside what the ticket asks you to change, stop working it: record the check, the failure, and what you tried in the report's *Problems encountered*, and carry the run to Step 7 as PARTIAL.

### Step 7 — Final verification

Before you write the report, walk the **Success criteria** at the end of this skill, line by line. Every line true → the status is COMPLETE. Any line that isn't true → the status is PARTIAL, and that line goes into the report's *Problems encountered*, named.

## Output — write an implementation report

Write a short report at the implementation report path `docs/ISSUE-TRACKER.md` defines, filling the template at `templates/implementation-report.md`, and print the summary. Copy the ticket's `Intent-slug`, `Intent` and `Architecture` **verbatim** into its header block. This is what the `piv-review-changes` gate reads — especially the **deviations**, which it treats as intentional decisions rather than findings.

## Hand off

Confirm the implementation report's path. Next: `piv-review-changes` gates the work before anything is committed, in a session of its own. Hand it the ticket id.

## Success criteria

- ✅ Every task on the list from Step 3 is implemented.
- ✅ Every test the ticket asks for exists, runs and passes, and every behavior the change adds or alters has a test — or the project has no test suite, and the report's *Tests added* says so.
- ✅ The full test suite and every other check run in Step 6 are green, apart from the baseline's red tests Step 6 leaves red.
- ✅ Every test that existed before the change still runs and asserts what it did, unless the ticket changed the behavior it pins.
- ✅ The change matches the patterns of the files it touched (Step 4a).
- ✅ Documentation the change made stale is updated.
- ✅ **Repair:** the ticket's *Reproduction* — on a deferral, its *Evidence* — no longer reproduces the defect, and the tests around the touched code still pass.
