---
name: piv-implement
description: Implements one task of an intent from its ticket, on the intent's branch, validating at every step, and writes an implementation report.
argument-hint: "[#N | intent-slug] [T-xx] (blank = the issue on the branch name, and the epic's next task)"
disable-model-invocation: true
---

# Implement: Build from the Ticket

This is the **implement** step of the PIV loop `docs/piv-loop.md` describes: one task, read from its ticket, built on the intent's branch and left uncommitted for `piv-review`. Write the report in the intent's language — the ticket's `Language`; template labels stay as written.

## Success criteria

- ✅ The task from Step 3 is implemented.
- ✅ Every file the change touched, apart from the artifacts under `.piv/`, shows in the git status — none is one the repository ignores.
- ✅ Every test the ticket's section 9 commands name exists, runs and passes, and every behavior the change adds or alters has a test — or the report's *Tests added* says why there is none (no test suite, no testable behavior, or the user waived them).
- ✅ The full test suite and every other check run in Step 6 are green, apart from the baseline's red tests Step 6 leaves red.
- ✅ Every test that existed before the change still runs and asserts what it did, unless the ticket changed the behavior it pins.
- ✅ The change matches the patterns of the files it touched (Step 4a).
- ✅ Documentation the change made stale is updated.
- ✅ **Repair:** the defect the ticket's `AC-xx` describe no longer reproduces, and the tests around the touched code still pass.

## Process

### Step 1 — Resolve the task

`$ARGUMENTS` carries `[#N | intent-slug] [T-xx]`. Resolve the intent and the task as `docs/piv-loop.md` says under *Resolving the intent and the task*, from `.piv/[intent-slug]/epic.md`. No epic → **STOP**: `piv-slice` writes it.

Then check the task against the epic, and **STOP** on the first that holds, naming it:

- **The task is `[x]`** → it is already committed.
- **Another task is `[~]`** → that one is in progress; finish it first, since tasks never run in parallel.
- **A task its `Depends on` names is not `[x]`** → name it as the one that has to be committed first.

Read the ticket at `.piv/[intent-slug]/tasks/T-xx/T-xx.md`. It can't be read → **STOP**, saying so. From here on, **the ticket governs the run**, and it is the only plan: it carries what it needs, so no plan outside it is read or asked for. No `DoD` in its header → **STOP**: the ticket needs reworking in `piv-slice` before it can be built.

**The spec must be the one the ticket was cut from.** Read the spec at the path the ticket's `Spec` field gives and compute `git hash-object --no-filters [the spec path]`. The spec can't be read, or its hash differs from the one in the field → **STOP**: the spec changed after `piv-slice` cut the ticket; it goes through `piv-review-spec` again and `piv-slice` re-cuts the tickets before this task runs.

When the ticket's `Type` is `bug`, this run is a **repair**: the instructions marked **Repair:** apply on top of the normal ones, and the run is done only when every one of them holds.

**Fetch the base branch** `docs/git-conventions.md` defines. From here on, *the base* is the tip that file defines — the remote tip after this fetch, such as `origin/main`.

**Mark the task in progress**: turn its line in the epic from `[ ]` to `[~]`. A STOP after this mark turns it back to `[ ]`; a GATE leaves it, since the user is still there.

**Done when** the ticket is read and governs the run, its spec hash matches, the base is fetched, every task it depends on is `[x]`, and the task is `[~]` in the epic.

### Step 2 — Work on the intent's branch

`docs/git-conventions.md` defines the branch name — read it before creating anything. Its tag comes from the epic's `Type`, its number from the epic's `Issue`, its slug from the intent-slug. To test whether the base is an ancestor of a branch, run `git merge-base --is-ancestor [base] [branch]`: exit code 0 means it is.

- **The epic's `Branch` reads `pending`** — the first task:
  - **On the base branch, clean, and no branch for this issue exists locally or on the remote** → create the branch from the base and write its name into the epic's `Branch`.
  - **A branch for this issue already exists** → switch to it when the tree is clean, and write its name into the epic's `Branch`.
- **The epic names a `Branch`**:
  - **On that branch, or on the base branch with that branch existing, clean** → use that branch. The base is not its ancestor → **STOP**: rebase the branch onto the base first.
- **On a branch carrying another issue's number or no number** → **STOP**: switch to the base or to this intent's branch first.
- **Uncommitted changes** → **STOP**: commit or stash first — on the intent's branch, an earlier task still waits for `piv-commit`.

**The baseline** is the project's full test suite run on the clean tree, at the branch's `HEAD`, before you change anything, with the setup this run will use. Write into your working notes every test that fails an assertion there and the assertion it fails, so Step 6 can tell the failures this change caused from the ones it found.

**The project has no test suite** → say so, skip the baseline, and carry on without tests: setting up a suite is not this run's job. Every test instruction below then falls away, and the report's *Tests added* says why.

**Done when** the run sits on the intent's branch, the epic names it, and the baseline names every test red at `HEAD` — or the project has no test suite and that is said.

### Step 3 — Read the ticket end to end

Make no edit until this step is done.

#### a. Read the sources
Read the ticket's sections: the goal and non-goals (1, 2), the requirements and constraints it carries (3, 5, 6), the design (7), the criteria (4), the boundaries and open questions (8) and the commands (9). The header holds the task: `Title`, `Blocked by`, `DoD` (the criteria the task proves) and `Cites`.

A reference to a file outside this repository is context, not scope: the header and the acceptance criteria draw the boundary of the run, and sections 2 and 8 (*Never*, *Ask first*) bound what it may touch.

#### b. Write the working notes
Write into your working notes the task from the header — its `Title`, `Blocked by` and `DoD` — the criteria of section 4, and every command of section 9.

**Repair:** also note the root cause — the defect section 1 and the `AC-xx` it fails describe — and whether the task still addresses it. It no longer does → that is an undercut assumption: handle it as Step 4c says.

#### c. Check the verification
Section 9 says which check proves each criterion, never whether. A criterion with no command → ask whether to write its test anyway or rework the ticket. **GATE.**

#### d. Check for drift
Where the ticket quotes code or cites paths or line refs inside this repository, open those files and compare. A reference to a file outside this repository is not drift-checked: an unreachable file is not evidence of drift.

Drift is quoted code that no longer exists, has moved, or changed so the ticket's instruction for it can no longer be performed. Cosmetic differences — formatting, renamed locals, shifted line numbers over identical code — are not drift.

- **Drift an earlier task of this intent caused** — `git log` on the drifted lines leads to a commit the epic lists under that task's `commits:` → **GATE**: post the drift and the task adapted to the current code, for the user to approve.
- **Any other drift** → **STOP**, naming what changed; the user edits the spec and the ticket before rerunning.

**Repair:** confirm the defect still reproduces before changing anything, by the `AC-xx` that describe it. It doesn't → **STOP**, saying the ticket is stale or already fixed.

#### e. Settle the unsettled facts
The ticket's section 8 *Open questions* may list facts as unsettled — a value, an error code, an edge case no source defines. A fact no task needs stays unsettled. For each one a task needs:

- **The repository already answers the same question** (existing code or schema) → take that precedent.
- **No precedent** → propose the smallest value consistent with the ticket's requirements and design. Post all of these together for the user to settle. **GATE.**

List every settled fact in the report's *Deviations from the ticket*, with its value and its source — precedent or user.

**Done when** the task, the criteria and every check the ticket names are in your notes, every source the ticket cites that the run can reach is read, the drift check came back clean or its drift was approved, and every unsettled fact a task needs has a value.

### Step 4 — Execute the task

Work the task from Step 3, running a and b. c applies whenever its situation comes up.

#### a. Implement the task
- Follow the ticket's specification for this task, and match the patterns already present in the files you're editing.
- Update the code the change reaches — imports, callers, call sites — and any documentation the change makes stale.
- Write the tests for the behavior this task adds or alters, together with the task.
- **Stay in scope:** implement what the ticket specifies. Refactors, improvements and unrelated problems you find along the way stay out of this branch; list them in the report's *Problems encountered* as candidate tasks. When you must deviate from the ticket, note what changed and why for the report's *Deviations from the ticket*.

#### b. Verify the task
**Run the task's own check before moving on.** When the ticket names a check for the task, run that one. When it names none, run the closest relevant check instead: the tests that exercise the behavior the task touched, plus the linter the project ships on the changed file, when it ships one. The task goes **green** when its check passes; a red task gets fixed before the run goes on.

**The three-hypothesis limit** applies here and in Step 6: when three fix attempts, each on a different hypothesis about the cause, leave a check red, stop working it. Record the check, the failure and each hypothesis tried for the report's *Problems encountered*, and the run ends as PARTIAL.

#### c. When a decision is missing or contradicted
A detail the ticket leaves unspecified: beyond matching the surrounding file's patterns (Step 4a), prefer in order the precedent the ticket already cites, then the smallest change consistent with the ticket's design.

Two things are not yours to settle: something you hit that undercuts an assumption a design item rests on — not just a missing detail — and a choice that would move an architectural boundary the ticket never drew. Name the assumption and the evidence against it, or the boundary and the options, along with the design item it affects and whether its rationale survives. The user resolves it before the run goes on. **GATE.**

**Done when** the task is green, or its failure is recorded for *Problems encountered*.

### Step 5 — Close the testing strategy

- Every test file and every test case the ticket's section 9 commands name now exists, runs, and asserts the behavior it is named for.
- Every behavior the change adds or alters — an observable outcome an acceptance criterion or the unit's public interface names — has at least one test that exercises it. Only a change with no testable behavior, such as docs or config that changes no observable outcome, goes without one, and the report's *Tests added* says so.
- **Repair:** at minimum, a test that fails without the fix and passes with it, plus tests for the edge cases around the bug. Name the test so it traces back to the issue number and the task id.

**Done when** every line above holds, or the project has no test suite and that is said.

### Step 6 — Run the checks

Run every check the ticket names, in the order it gives them, then the project's own checks in full — the whole test suite, lint, type-check, and build commands the repo exposes; its CI config lists them when it has one. The change reaches callers the ticket never named, and only the full suite sees their tests break.

When a check goes red: fix the cause, re-run, and continue once it is green. A test goes green by the code changing: its assertions, and whether it runs at all, change only when the ticket changes the behavior it pins — the review blocks any other change to a test, whatever *Deviations from the ticket* says. A test failing the same assertion the baseline recorded stays red, unless the ticket's verification names it or it reproduces the defect a **Repair** fixes: that one is this change's to turn green.

A failure the three-hypothesis limit (Step 4b) leaves red, or one whose cause sits outside what the ticket asks you to change, is not worked further: record it the way Step 4b says and carry the run to Step 7 as PARTIAL.

**Done when** every check is green, apart from the baseline's red tests this step leaves red, or each one still red is recorded for *Problems encountered*.

### Step 7 — Final verification

Before you write the report, walk the **Success criteria** at the top of this skill, line by line. For the git-status line, run `git check-ignore -v -- [every file the change touched, apart from the artifacts under .piv/]`: each path it prints is ignored, and a change to an ignored file never reaches the diff, the commit or the PR — it stays on this machine. Every line true → the status is COMPLETE. Any line that isn't true → the status is PARTIAL, and that line goes into the report's *Problems encountered*, named.

**Done when** every success criterion is marked true or named in *Problems encountered*, and the status is set.

## Output — write an implementation report

Write the report at `.piv/[intent-slug]/tasks/T-xx/T-xx.report.md`, filling the template at `${CLAUDE_SKILL_DIR}/templates/implementation-report.md` — use it exactly — then print its **Status** and **Summary** in the session. Copy the ticket's `Intent-slug` **verbatim** into its header block. This is what the `piv-review` gate reads — especially the **deviations**, which it treats as intentional decisions rather than findings.

Everything the template leaves to you — what was built, each deviation and its reason, and the checks — is written in the intent's language; only the template's labels and headings stay as written.

## Hand off

Confirm the implementation report's path. Next: `piv-review [#N] [T-xx]` gates the task before anything is committed, in a session of its own.
