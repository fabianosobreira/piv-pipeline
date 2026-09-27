---
name: piv-review-changes
description: Reviews the finished change for bugs, security defects and standards violations, and writes a review report.
argument-hint: "[ticket id] (blank = taken from the branch name)"
disable-model-invocation: true
---

# Review Changes: Prove the Change Wrong

This opens the **verify** step of the PIV loop `docs/PIV-LOOP.md` describes: the work is built but not yet committed, and this gate decides whether it earns a commit. The review is a report, never an edit — the fixes belong to a later run, working from what this one writes down.

## Posture

You are the prosecution. Assume the author got it wrong and prove it — a review that finds nothing because it looked gently ships with a stamp of approval on it.

**The burden of proof is yours.** Every candidate faces three filters before it becomes a finding:

1. **Evidence** — a quoted line, or reasoning a reader can trace through the code in front of you. A candidate you cannot anchor to a file and a line is a suspicion, and suspicions stay out of the report.
2. **Mitigation** — go hunting for the place the flow already covers the problem: validation upstream, error handling around the call, a test that already pins the behavior, a deviation the implementation report documents as intentional, the reason the previous fix report gives for ruling it *Noise / won't-fix*. That reason is evidence you weigh against the code, never an order: it drops the candidate only when it shows the problem is not there — "not worth fixing" admits the problem, and only a deferral settles that. Covered, it drops.
3. **Prior decision** — this branch may have been reviewed before, and a human already ruled on what came back. A candidate **deferred on the record** — carried into a ticket that says this work happens later — is settled, and it drops. The ticket is what closes it: a deferral with nothing to point at is still open, and it gets reported again.

Step 6 runs the three filters. What survives becomes a finding; the rest goes nowhere.

**Some findings are facts, not arguments.** Four kinds are **blocking**:

- ***red*** — a test that fails on the branch in any run, flaky ones included.
- ***missing*** — a test the ticket's **Testing strategy** names that is absent, or present but skipped, marked to fail, or asserting nothing.
- ***weakened*** — a test that existed before and now asserts less or something different — skipped, marked to fail, its assertions loosened or its expected values changed, or deleted — while the ticket left the behavior it pins unchanged.
- ***untested*** — a behavior the change adds or alters that no test exercises. A **behavior** is an observable outcome an acceptance criterion or the unit's public interface names, such as a new entry point or error contract. A new condition inside an outcome a test already asserts is a branch, and an unexercised branch is an ordinary coverage finding.

A blocking finding is observed, so it sits outside the severity scale and holds the verdict at CHANGES REQUESTED on its own. It faces the filters like any other, with two differences. A documented deviation leaves it standing: explaining a disabled test is transparency, not mitigation. A deferral leaves it standing too, because `piv-fix-findings` never defers one — a deferred red test would reach PASS still red.

A *red* test **confirmed red on the base** — it ran on the base branch, with the setup the branch run used, and failed the same assertion the branch run failed — is not this change's failure, and drops to a **coverage** finding, **medium** (Step 6): a `bug`'s proof would be the test itself turning red without the fix, which is circular for a test that is already red. A test the **Testing strategy** names, or the test that reproduces the defect a `bug` ticket describes, is this change's to turn green whatever the base shows.

**A project with no test suite holds the change to no test.** `piv-implement-ticket` builds there without tests rather than setting a suite up, so *missing* and *untested* do not apply, and *red* and *weakened* cannot arise. Say so in *Checks run*, naming the behaviors the change adds or alters that go untested, and raise no finding for them.

## Process

### Step 1 — Resolve the change under review

The **change under review** is everything this branch added on top of the base branch: the uncommitted tree — tracked and untracked alike — plus the commits sitting ahead of the base. `docs/GIT-CONVENTIONS.md` says which branch is the base. Gather the working tree status, the full diff against the base, the diff statistics, and the list of untracked files.

Nothing to review — a clean tree with no commits ahead of the base → **STOP** and say so.

**Then resolve the ticket id.** `$ARGUMENTS` carries it when one was handed to you; otherwise take it from the branch name, in the form `docs/GIT-CONVENTIONS.md` defines. Neither carries one → ask the user for it. **GATE.**

**Then read the ticket**, where `docs/ISSUE-TRACKER.md` says tickets live, and take its **Testing strategy** — the bar the change was held to — and its `Intent-slug`. When it can't be read — missing, or the system unreachable — **STOP** and say which it was.

**Then look for the implementation report** at the path `docs/ISSUE-TRACKER.md` defines, named from the ticket id. It says what the author meant to build: take above all its **documented deviations** — a documented deviation is an intentional decision, so it feeds the mitigation filter rather than the finding list. Its *Tests added* is the author's account of what was tested; the ticket is what they were asked to test. There is no report → review the change on its own terms; this skill never requires one.

### Step 2 — Resolve the deferrals

A previous review of this branch may sit at the review report path `docs/ISSUE-TRACKER.md` defines; when it is there, this is a re-review. Read it, the fix report beside it, and every deferral ticket an earlier round opened, found the way `docs/ISSUE-TRACKER.md` says under *Finding a review's deferrals* — together they are what the prior-decision filter reads. The fix report holds only the latest round, so the tracker is what still carries the earlier ones.

### Step 3 — Read the standards the change has to meet

A rule you can cite is a rule you can enforce; a rule you cannot point at is your own taste wearing the project's name. Read what the project documents about how its code is written: `CLAUDE.md`, `AGENTS.md`, `README.md`, and the linter, formatter and type-checker configs the repo ships.

Then read, for each kind of unit the change adds or edits, one existing sibling that does the same job, to know what "matches the existing patterns" means here.

### Step 4 — Read every changed file end to end

Every file the change touches, whole — not the diff. A diff hides the caller three functions up that makes the new branch unreachable, and the helper that already does what the new code reimplements. New files get read in full for the same reason.

**A change too large to read in one pass gets dispatched, never sampled.** When the files no longer fit, split them into coherent groups — a module, a layer, a feature's slice — and send each group to a subagent that runs Steps 4 and 5 over its own files and reports its candidates back with the evidence attached. Hand each subagent the standards from Step 3, the ticket or plan with its Testing strategy, the implementation report, and this skill's **Posture** and Step 5 — without them Standards, Coverage and the code smells check against nothing. You run Step 6 over everything that comes back, so the filters stay in one place. Note the dispatch in the report's *Scope*: end-to-end still holds, it just happened across several readers.

### Step 5 — Build the case

Work the list below over every changed file. Each class is a thing to hunt for, not a box to tick: pass over a class silently only when you looked and found nothing.

1. **Logic** — off-by-one bounds, inverted or short-circuiting conditionals, unhandled error paths, races and unawaited work, state mutated under an alias someone else holds.
2. **Security** — injection through interpolated queries, commands and templates; unescaped output; secrets and keys in code, config or logs; authorization checked in one path and skipped in another; untrusted input reaching a sink unvalidated.
3. **Performance** — queries inside loops, work repeated per iteration that belongs outside it, unbounded growth of a collection or cache, resources opened and never released.
4. **Quality** — a function doing several jobs, a name that lies about what the thing holds, duplicated logic the codebase already has one home for, missing types or annotations where the project uses them, and every entry in `references/code-smells.md` matched against the diff.
5. **Standards** — the rules gathered in Step 3: lint, typing, formatting, logging, error handling, and the testing standard. Cite the document and the rule.
6. **Coverage** — the tests the change brought, and the ones it should have. Hunt the blocking kinds (**Posture**). Within a tested behavior, a branch nobody exercises is a finding; so is a test that asserts the implementation instead of the behavior.

### Step 6 — Run the three filters

Take each candidate through all three filters from **Posture**, and run the checks that settle them instead of reasoning about what the code probably does:

- Run the project's full test suite on the branch, whatever the candidates — it is how a *red* test gets found. Note a flaky one as such in *Checks run*. Run each *red* test on the base branch too, in a worktree created outside the repository and removed afterwards, so the change under review stays untouched, and confirm it against the conditions **Posture** sets for a base-red test. The project has no test suite → say so in *Checks run* the way **Posture** requires.
- Run the type-checker and linter on the changed files.
- Reproduce a logic finding against the actual code path — the conditions that reach it, and what the callers pass.
- On a re-review, match the candidate against the previous review's findings, against the deferral tickets Step 2 found, and against the previous fix report's *Noise / won't-fix* reasons.

A surviving blocking finding stays **blocking**, and its kind names it. Give every other survivor the Step 5 class it was found under — a test demoted from *red* by the base-red check (**Posture**) is **coverage** — `piv-fix-findings` types a deferral from it — and a severity:

- **critical** — data loss, corruption, or a security defect a reachable path can trigger.
- **high** — wrong behavior on a path users reach.
- **medium** — wrong behavior on an edge path, or a documented standard violated.
- **low** — quality and maintainability, correct today.

## Output — write a review report

Write the report at the review report path `docs/ISSUE-TRACKER.md` defines, filling the template at `templates/review-report.md`, built from the ticket id resolved in Step 1 — so a ticket's review sits beside its implementation report. On a re-review, this overwrites the previous one: it is the current state of the branch, and the decisions taken on the old findings live in the tracker, not here. Then print the verdict with the count of blocking findings and the count per severity.

The blocking heading and every severity heading are present on every run, and one that survived nothing reads "No findings." The verdict is **CHANGES REQUESTED** when any blocking, critical or high finding survived, and **PASS** otherwise — a PASS with medium and low findings is normal.

## Hand off

The review report is the artifact this run leaves behind, so hand over its path by name, with the ticket id. Offer the next move and let the user run it — this skill does not chain into the next one:

- **PASS** → run `piv-commit-changes`, in a session of its own, handed the ticket id. The medium and low findings stay in the report; `piv-create-pr` carries them into the PR body.
- **CHANGES REQUESTED** → run `piv-fix-findings`, in a session of its own, handed the review report's path as the review to work from.

## Success criteria

- ✅ Every file in the change under review was read end to end — by you, or by the subagent it was dispatched to — and every class in Step 5 was hunted over each of them.
- ✅ Every reported finding carries a file, a line, and evidence anchored in the code.
- ✅ Every reported finding survived all three filters in **Posture**.
- ✅ The full test suite ran on the branch — or the project has none, and *Checks run* says so — and every *red* test is reported — blocking, or medium when **Posture** demotes it, unless an earlier deferral settles that medium.
- ✅ The change was held to the **Testing strategy** read from the ticket.
- ✅ The report follows the template in **Output**, and its path was handed to whatever runs next.
