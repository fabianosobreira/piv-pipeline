---
name: piv-implement
description: Implements a ticket task by task on its own branch, validating at every step, and writes an implementation report.
argument-hint: "[ticket id] (blank = starts by asking which ticket)"
disable-model-invocation: true
---

# Implement: Build from the Ticket

This is the **implement** step of the PIV loop `docs/piv-loop.md` describes. Write the report in the intent's language — the ticket's `Language`, read in Step 1, or with no such field the language its body is written in; template labels stay as written.

Copy this checklist into your todo list. Tick an item only when its step's **Done when** holds.

- [ ] 1. Resolve the ticket
- [ ] 2. Work on a branch
- [ ] 3. Read the ticket end to end
- [ ] 4. Execute tasks in order
- [ ] 5. Close the testing strategy
- [ ] 6. Run the checks
- [ ] 7. Final verification

## Success criteria

- ✅ Every task on the list from Step 3 is implemented.
- ✅ Every file the change touched shows in the git status — none is one the repository ignores.
- ✅ Every test the ticket asks for exists, runs and passes, and every behavior the change adds or alters has a test — or the report's *Tests added* says why there is none (no test suite, no testable behavior, or the user waived them).
- ✅ The full test suite and every other check run in Step 6 are green, apart from the baseline's red tests Step 6 leaves red.
- ✅ Every test that existed before the change still runs and asserts what it did, unless the ticket changed the behavior it pins.
- ✅ The change matches the patterns of the files it touched (Step 4a).
- ✅ Documentation the change made stale is updated.
- ✅ **Repair:** the ticket's *Reproduction* — on a deferral, its *Evidence* — no longer reproduces the defect, and the tests around the touched code still pass.

## Process

### Step 1 — Resolve the ticket

`$ARGUMENTS` carries the ticket id. Nothing passed → ask the user which ticket to implement. Only a ticket the user names counts. **GATE.**

Read that ticket where `docs/issue-tracker.md` says tickets live, reaching that system with whatever tool fits. The ticket can't be read — missing, already closed, the system unreachable → **STOP**, saying which it was.

From here on, **the ticket governs the run**. No `Acceptance criteria` heading, or an empty checklist under it → **STOP**: say so, and that the ticket needs reworking before it can be built.

Assigned to someone else → **STOP**, naming the assignee.

When the ticket's type is `bug`, this run is a **repair**: the instructions marked **Repair:** apply on top of the normal ones, and the run is done only when every one of them holds. A **deferral** is a ticket that carries *Origin* and *Evidence*; the instructions below name what to read on one in place of a sliced ticket's *Reproduction* and *Root cause*.

**Fetch the base branch** `docs/git-conventions.md` defines. From here on, *the base* is the tip that file defines — the remote tip after this fetch, such as `origin/main`.

**Check the dependencies.** Every ticket the ticket's **Depends on** names must be merged into the base — its branch or PR merged into the base's remote tip. One isn't → **STOP**, saying which ticket has to land first.

**Mark the ticket in flight**, the way `docs/issue-tracker.md` says. A STOP after this mark puts the ticket back to the status it had; a GATE leaves it, since the user is still there.

**Done when** the ticket is read and governs the run, the base is fetched, every ticket it *Depends on* is merged into the base, and it is marked in flight.

### Step 2 — Work on a branch

`docs/git-conventions.md` defines the branch name — read it before creating anything. A branch this run creates starts from the base. To test whether the base is an ancestor of a branch, run `git merge-base --is-ancestor <base> <branch>`: exit code 0 means it is.

- **On the base branch, clean, and no branch for this ticket exists locally or on the remote** → create the branch from the base, then record the baseline on it.
- **On a branch carrying this ticket's id, or on the base branch, clean, with that branch already existing** → switch to that branch. The base is not its ancestor → **STOP**: rebase the branch onto the base first. Otherwise record the baseline in a worktree of the base, then use the branch.
- **On a branch carrying another ticket's id or no id** → **STOP**: switch to the base or to this ticket's branch first.
- **On the base branch with uncommitted changes** → **STOP**: commit or stash first. The in-flight mark on the ticket is not one of them.

**The baseline** is the project's full test suite run against the base before you change anything, with the setup the branch run will use. Write into your working notes every test that fails an assertion there and the assertion it fails, so Step 6 can tell the failures this change caused from the ones it found. A worktree for it goes outside the repository — `git worktree add <path outside the repo> <base>` — and is removed afterwards with `git worktree remove <path>`.

**The project has no test suite** → say so, skip the baseline, and carry on without tests: this run implements the ticket, and setting up a suite is not its job. Every test instruction below then falls away, and the report's *Tests added* says why.

**Done when** the run sits on the ticket's branch and the baseline names every test red on the base — or the project has no test suite and that is said.

### Step 3 — Read the ticket end to end

Make no edit until this step is done.

#### a. Read the sources
Read the ticket's **`Architecture`** field and its **Entry context** — the decisions it cites, the starting code, the external references you can reach, and what the neighbors own; on a deferral, also its **Origin** and **Evidence**.

- **`Architecture` says `none`** → no architecture doc was produced for this ticket; proceed without one. **Otherwise it names a path or a URL** → resolve it wherever `docs/issue-tracker.md` says plans live, and read it. Unresolvable → **STOP**, asking for it.
- **Entry context › Decisions cites sections of the intent** → resolve the ticket's `Intent` field the same way and read those sections. Unresolvable → **STOP**, asking for it.

What the architecture and the intent describe beyond the decisions the ticket cites is context, not scope: *Scope*, *Out of scope* and the acceptance criteria draw the boundary of the run.

#### b. Write the working notes
Write into your working notes the task list with the dependencies between tasks, every check the ticket names, and its **Testing strategy**. Acceptance criteria that already read as a task list are that list. Criteria written as outcome prose carry no order: derive the task list from them, then check it covers everything the ticket asks for.

**Repair:** also note the root cause — on a sliced ticket, its *Root cause*; on a deferral, *Origin › Location* and *Evidence* — and whether the proposed fix still addresses it. It no longer does → that is an undercut assumption: handle it as Step 4c says.

#### c. Check the Testing strategy
The Testing strategy says which tests, never whether. "project defaults" means the project's own testing standard applies. A strategy that waives the tests for a behavior the ticket adds or alters → ask whether to write them anyway or rework the ticket. **GATE.**

#### d. Check for drift
Where the ticket quotes code or cites line refs inside this repository, open those files and compare. *External references* are context, not drift-checked: the run may not be able to open them, and an unreachable file is not evidence of drift.

Drift is quoted code that no longer exists, has moved, or changed so the ticket's instruction for it can no longer be performed. Cosmetic differences — formatting, renamed locals, shifted line numbers over identical code — are not drift.

- **Drift a ticket this one *Depends on* caused** — `git log` on the drifted lines leads to that ticket's merge → **GATE**: post the drift and the task list adapted to the current code, for the user to approve.
- **Any other drift** → **STOP**, naming what changed; the user edits the ticket before rerunning.

**Repair:** confirm the defect still reproduces before changing anything, by the ticket's *Reproduction* — on a deferral, by its *Evidence*. It doesn't → **STOP**, saying the ticket is stale or already fixed.

#### e. Settle the unsettled facts
The ticket's *Entry context* may list facts as unsettled — a value, an error code, an edge case no source defines. A fact no task needs stays unsettled. For each one a task needs:

- **The repository already answers the same question** (existing code or schema) → take that precedent.
- **No precedent** → propose the smallest value consistent with the ticket's decisions. Post all of these together for the user to settle. **GATE.**

List every settled fact in the report's *Deviations from the ticket*, with its value and its source — precedent or user.

**Done when** the task list, every check the ticket names and its Testing strategy are in your notes, every cited source the run can reach is read, the drift check came back clean or its drift was approved, and every unsettled fact a task needs has a value.

### Step 4 — Execute tasks in order

Work the task list from Step 3 in its dependency order, running a and b for each task. c applies whenever its situation comes up.

#### a. Implement the task
- Follow the ticket's specification for this task, and match the patterns already present in the files you're editing.
- Update the code the change reaches — imports, callers, call sites — and any documentation the change makes stale.
- Write the tests for the behavior this task adds or alters, together with the task.
- **Stay in scope:** implement what the ticket specifies. Refactors, improvements and unrelated problems you find along the way stay out of this branch; list them in the report's *Problems encountered* as candidate tickets. This run creates no ticket. When you must deviate from the ticket, note what changed and why for the report's *Deviations from the ticket*.

#### b. Verify the task
**Run the task's own check before starting the next task.** When the ticket names a check for the task, run that one. When it names none, run the closest relevant check instead: the tests that exercise the behavior the task touched, plus the linter the project ships on the changed file, when it ships one. A task goes **green** when its check passes; a red task gets fixed before the next one starts.

**The three-hypothesis limit** applies here and in Step 6: when three fix attempts, each on a different hypothesis about the cause, leave a check red, stop working it. Record the check, the failure and each hypothesis tried for the report's *Problems encountered*, and the run ends as PARTIAL. Here, also skip the tasks that depend on the red one, recording each as skipped, and continue with the rest.

#### c. When a decision is missing or contradicted
A detail the ticket leaves unspecified: beyond matching the surrounding file's patterns (Step 4a), prefer in order the precedent the ticket or its architecture doc already cites, then the smallest change consistent with the ticket's decision.

Two things are not yours to settle: something you hit that undercuts an assumption a decision rests on — not just a missing detail — and a choice that would move an architectural boundary the ticket never drew. Name the assumption and the evidence against it, or the boundary and the options, along with the decision it affects and whether that decision's rationale survives. The user resolves it before the architecture changes. **GATE.**

**Done when** every task on the list is green, or its failure or skip is recorded for *Problems encountered*.

### Step 5 — Close the testing strategy

- Every test file and every test case the ticket's **Testing strategy** names now exists, runs, and asserts the behavior it is named for.
- Every behavior the change adds or alters — an observable outcome an acceptance criterion or the unit's public interface names — has at least one test that exercises it. Only a change with no testable behavior, such as docs or config that changes no observable outcome, goes without one, and the report's *Tests added* says so.
- **Repair:** at minimum, a test that fails without the fix and passes with it, plus tests for the edge cases around the bug. Name the test so it traces back to the ticket id.

**Done when** every line above holds, or the project has no test suite and that is said.

### Step 6 — Run the checks

Run every check the ticket names, in the order it gives them, then the project's own checks in full — the whole test suite, lint, type-check, and build commands the repo exposes; its CI config lists them when it has one. The change reaches callers the ticket never named, and only the full suite sees their tests break.

When a check goes red: fix the cause, re-run, and continue once it is green. A test goes green by the code changing: its assertions, and whether it runs at all, change only when the ticket changes the behavior it pins — the review blocks any other change to a test, whatever *Deviations from the ticket* says. A test failing the same assertion the baseline recorded stays red, unless the **Testing strategy** names it or it reproduces the defect a **Repair** fixes: that one is this change's to turn green.

A failure the three-hypothesis limit (Step 4b) leaves red, or one whose cause sits outside what the ticket asks you to change, is not worked further: record it the way Step 4b says and carry the run to Step 7 as PARTIAL.

**Done when** every check is green, apart from the baseline's red tests this step leaves red, or each one still red is recorded for *Problems encountered*.

### Step 7 — Final verification

Before you write the report, walk the **Success criteria** at the top of this skill, line by line. For the git-status line, run `git check-ignore -v -- <every file the change touched>`: each path it prints is ignored, and a change to an ignored file never reaches the diff, the commit or the PR — it stays on this machine. Every line true → the status is COMPLETE. Any line that isn't true → the status is PARTIAL, and that line goes into the report's *Problems encountered*, named.

**Done when** every success criterion is marked true or named in *Problems encountered*, and the status is set.

## Output — write an implementation report

Write the report at the implementation report path `docs/issue-tracker.md` defines, filling the template at `templates/implementation-report.md` — use it exactly — then print its **Status** and **Summary** in the session. Copy the ticket's `Intent-slug`, `Intent` and `Architecture` **verbatim** into its header block. This is what the `piv-review` gate reads — especially the **deviations**, which it treats as intentional decisions rather than findings.

Everything the template leaves to you — what was built, each deviation and its reason, and the checks — is written in the intent's language; only the template's labels and headings stay as written.

## Hand off

Confirm the implementation report's path. Next: `piv-review` gates the work before anything is committed, in a session of its own. Hand it the ticket id.
