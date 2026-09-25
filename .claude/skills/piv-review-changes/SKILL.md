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
2. **Mitigation** — go hunting for the place the flow already covers the problem: validation upstream, error handling around the call, a test that already pins the behavior, a deviation the implementation report documents as intentional. Covered, it drops.
3. **Prior decision** — this branch may have been reviewed before, and a human already ruled on what came back. A candidate **deferred on the record** — carried into a ticket that says this work happens later — is settled, and it drops. The ticket is what closes it: a deferral with nothing to point at is still open, and it gets reported again.

Step 6 runs the three filters. What survives becomes a finding; the rest goes nowhere.

## Process

### Step 1 — Resolve the change under review

The **change under review** is everything this branch added on top of the base branch: the uncommitted tree — tracked and untracked alike — plus the commits sitting ahead of the base. `docs/GIT-CONVENTIONS.md` says which branch is the base. Gather the working tree status, the full diff against the base, the diff statistics, and the list of untracked files.

Nothing to review — a clean tree with no commits ahead of the base → **STOP** and say so.

**Then look for the implementation report**, which says what the author meant to build. `docs/ISSUE-TRACKER.md` says where reports live and how their names are built. `$ARGUMENTS` carries the ticket id when one was handed to you; otherwise take it from the branch name, in the form `docs/GIT-CONVENTIONS.md` defines. With an id, the report's name follows from it.

**No id** — the work has no ticket, so the report is named for its `intent-slug`, and the branch's `<short-slug>` is not reliably that slug. Match an existing report first: scan the reports directory and compare each report's **Branch** header against the branch you are on. One match → that is the report, and its `intent-slug` is the one this run uses from here on. No match → there is no report. More than one → ask the user which one covers this branch. **GATE.**

Take from the report the ticket it implemented, its status, and above all its **documented deviations** — a documented deviation is an intentional decision, so it feeds the mitigation filter rather than the finding list. There is no report → review the change on its own terms; this skill never requires one.

**Settle the `intent-slug` once, and write it down.** With an id or a report, it comes from there. With neither, fall back to the branch name's `<short-slug>` in the form `docs/GIT-CONVENTIONS.md` gives it — and because that fallback is the weakest derivation, the review report records the slug it used in its header. A later run reuses the slug from an existing review report instead of re-deriving it, so a re-review overwrites the report it should overwrite rather than writing a second one beside it.

### Step 2 — Resolve the deferrals

A previous review of this branch may sit at the review report path `docs/ISSUE-TRACKER.md` defines; when it is there, this is a re-review. Read it, the fix report beside it, and every deferral ticket an earlier round opened, found the way `docs/ISSUE-TRACKER.md` says under *Finding a review's deferrals* — together they are what the prior-decision filter reads. The fix report holds only the latest round, so the tracker is what still carries the earlier ones.

### Step 3 — Read the standards the change has to meet

A rule you can cite is a rule you can enforce; a rule you cannot point at is your own taste wearing the project's name. Read what the project documents about how its code is written: `CLAUDE.md`, `AGENTS.md`, `README.md`, and the linter, formatter and type-checker configs the repo ships.

Then read enough of the surrounding module to know what "matches the existing patterns" means here.

### Step 4 — Read every changed file end to end

Every file the change touches, whole — not the diff. A diff hides the caller three functions up that makes the new branch unreachable, and the helper that already does what the new code reimplements. New files get read in full for the same reason.

**A change too large to read in one pass gets dispatched, never sampled.** When the files no longer fit, split them into coherent groups — a module, a layer, a feature's slice — and send each group to a subagent that runs steps 4 and 5 over its own files and reports its candidates back with the evidence attached. You run step 6 over everything that comes back, so the filters stay in one place. Note the dispatch in the report's *Scope*: end-to-end still holds, it just happened across several readers.

### Step 5 — Build the case

Work the list below over every changed file. Each class is a thing to hunt for, not a box to tick: pass over a class silently only when you looked and found nothing.

1. **Logic** — off-by-one bounds, inverted or short-circuiting conditionals, unhandled error paths, races and unawaited work, state mutated under an alias someone else holds.
2. **Security** — injection through interpolated queries, commands and templates; unescaped output; secrets and keys in code, config or logs; authorization checked in one path and skipped in another; untrusted input reaching a sink unvalidated.
3. **Performance** — queries inside loops, work repeated per iteration that belongs outside it, unbounded growth of a collection or cache, resources opened and never released.
4. **Quality** — a function doing several jobs, a name that lies about what the thing holds, duplicated logic the codebase already has one home for, missing types or annotations where the project uses them. Also match the diff against the code smells catalogued in `references/code-smells.md`.
5. **Standards** — the rules gathered in step 3: lint, typing, formatting, logging, error handling, and the testing standard. Cite the document and the rule.
6. **Coverage** — the change's own tests. A behavior with a branch nobody exercises is a finding; so is a test that asserts the implementation instead of the behavior.

### Step 6 — Run the three filters

Take each candidate through all three filters from **Posture**, and run the checks that settle them instead of reasoning about what the code probably does:

- Run the tests that touch the suspect code, and the type-checker and linter on the changed files.
- Reproduce a logic finding against the actual code path — the conditions that reach it, and what the callers pass.
- On a re-review, match the candidate against the previous review's findings, and follow each deferral to its ticket.

Give each survivor a severity:

- **critical** — data loss, corruption, or a security defect a reachable path can trigger.
- **high** — wrong behavior on a path users reach.
- **medium** — wrong behavior on an edge path, or a documented standard violated.
- **low** — quality and maintainability, correct today.

## Output — write a review report

Write the report at the review report path `docs/ISSUE-TRACKER.md` defines, filling the template at `templates/review-report.md`, built from the ticket id or the `intent-slug` resolved in step 1 — so a ticket's review sits beside its implementation report. On a re-review, this overwrites the previous one: it is the current state of the branch, and the decisions taken on the old findings live in the tracker, not here. Then print the verdict with the count per severity.

Every severity heading is present on every run, and one that survived nothing reads "No findings." The verdict is **CHANGES REQUESTED** when any critical or high finding survived, and **PASS** otherwise — a PASS with medium and low findings is normal.

## Hand off

The review report is the artifact this run leaves behind, so hand over its path by name — with the ticket id when there is one. Offer the next move and let the user run it — this skill does not chain into the next one:

- **PASS** → run `piv-commit-changes`, in a session of its own, handed the ticket id. The medium and low findings stay in the report; `piv-create-pr` carries them into the PR body.
- **CHANGES REQUESTED** → run `piv-fix-findings`, in a session of its own, handed the review report's path as the review to work from.

## Success criteria

- ✅ Every file in the change under review was read end to end — by you, or by the subagent it was dispatched to — and every class in step 5 was hunted over each of them.
- ✅ Every reported finding carries a file, a line, and evidence anchored in the code.
- ✅ Every reported finding survived all three filters in **Posture**.
- ✅ The report follows the template in **Output**, and its path was handed to whatever runs next.
