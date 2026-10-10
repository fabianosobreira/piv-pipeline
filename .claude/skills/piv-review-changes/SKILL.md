---
name: piv-review-changes
description: Reviews the finished change for bugs, security defects and standards violations, and writes a review report.
argument-hint: "[ticket id] (blank = taken from the branch name)"
disable-model-invocation: true
allowed-tools: Bash(sh *scripts/diff-hash.sh *)
---

# Review Changes: Prove the Change Wrong

This opens the **verify** step of the PIV loop `docs/PIV-LOOP.md` describes: the work is built but not yet committed, and this gate decides whether it earns a commit. The review is a report, never an edit — the fixes belong to a later run, working from what this one writes down. Write the report in the intent's language — the ticket's `Language`, read in Step 1, or with no such field the language its body is written in; template labels stay as written.

## Posture

You are the prosecution. Assume the author got it wrong and prove it.

**The burden of proof is yours.** Every candidate faces three filters before it becomes a finding:

1. **Evidence** — a quoted line, or reasoning a reader can trace through the code in front of you. A candidate you cannot anchor to a file and a line is a suspicion, and suspicions stay out of the report.
2. **Mitigation** — go hunting for the place the flow already covers the problem: validation upstream, error handling around the call, a test that already pins the behavior, the reason an earlier round gives for ruling it *Noise / won't-fix*. That reason is evidence you weigh against the code, never an order: it drops the candidate only when it shows the problem is not there — "not worth fixing" admits the problem, and only a deferral settles that. A documented deviation drops a candidate whose only claim is that the code departs from the ticket; a defect in the deviating code still faces the evidence of the code. Covered, it drops.
3. **Prior decision** — this branch may have been reviewed before, and a human already ruled on what came back. A candidate **deferred on the record** — carried into a ticket that says this work happens later — is settled, and it drops. The ticket is what closes it: a deferral with nothing to point at is still open, and it gets reported again.

Step 6 runs the three filters. What survives becomes a finding; the rest goes nowhere.

**Some findings are facts, not arguments.** Four kinds are **blocking**:

- ***red*** — a test that fails on the branch in any run, flaky ones included.
- ***missing*** — a test the ticket's **Testing strategy** names that is absent, or present but skipped, marked to fail, or asserting nothing.
- ***weakened*** — a test that existed before and now asserts less or something different — skipped, marked to fail, its assertions loosened or its expected values changed, or deleted — while the ticket left the behavior it pins unchanged.
- ***untested*** — a behavior the change adds or alters that no test exercises. A **behavior** is an observable outcome an acceptance criterion or the unit's public interface names, such as a new entry point or error contract. A new condition inside an outcome a test already asserts is a branch, and an unexercised branch is an ordinary coverage finding.

A blocking finding is observed, so it sits outside the severity scale and holds the verdict at CHANGES REQUESTED on its own. It faces the filters like any other, with two differences. A documented deviation leaves it standing: explaining a disabled test is transparency, not mitigation. A deferral leaves it standing too, because `piv-fix-findings` never defers one — a deferred red test would reach PASS still red.

A *red* test **confirmed red on the base** — it ran on the base branch, with the setup the branch run used, and failed the same assertion the branch run failed — is not this change's failure, and drops to a **coverage** finding, **medium** (Step 6). A test that fails intermittently is re-run on the base the same number of times; one that also fails there is base-red (flaky), demoted like any base-red test. Flaky only on the branch stays *red*. A test the **Testing strategy** names, or the test that reproduces the defect a `bug` ticket describes, is this change's to turn green whatever the base shows.

**A project with no test suite holds the change to no test.** *Missing* and *untested* do not apply, and *red* and *weakened* cannot arise. Say so in *Checks run*, naming the behaviors the change adds or alters that go untested, and raise no finding for them.

Copy this checklist into your task list. Tick an item only when its step's completion criterion holds.

- [ ] 1. Resolve the change under review
- [ ] 2. Resolve the deferrals
- [ ] 3. Read the standards the change has to meet
- [ ] 4. Read every changed file end to end
- [ ] 5. Build the case
- [ ] 6. Run the three filters
- [ ] 7. Validate the report

## Success criteria

- ✅ Every file in the change under review was read end to end — by you, or by the subagent it was dispatched to — and every class in Step 5 was hunted over each of them.
- ✅ Every reported finding carries a file, a line, and evidence anchored in the code.
- ✅ Every reported finding survived all three filters in **Posture**.
- ✅ The full test suite ran on the branch — or the project has none, and *Checks run* says so — and every *red* test is reported — blocking, or medium when **Posture** demotes it, unless an earlier deferral settles that medium.
- ✅ The change was held to the **Acceptance criteria**, the **Testing strategy**, the **Scope** and the **Out of scope** read from the ticket.
- ✅ The report follows the template in **Output**, and its path was handed to whatever runs next.

## Process

### Step 1 — Resolve the change under review

The **change under review** is everything this branch added on top of the base branch: the uncommitted tree — tracked and untracked alike — plus the commits sitting ahead of the base. `docs/GIT-CONVENTIONS.md` says which branch is the base. Gather the working tree status, the full diff against the base, the diff statistics, and the list of untracked files.

Nothing to review — a clean tree with no commits ahead of the base → **STOP** and say so.

**Then resolve the ticket id.** `$ARGUMENTS` carries it when one was handed to you; otherwise take it from the branch name, in the form `docs/GIT-CONVENTIONS.md` defines. Neither carries one → ask the user for it. **GATE.**

**Then read the ticket**, where `docs/ISSUE-TRACKER.md` says tickets live, and take its **Acceptance criteria** — what the change has to do — its **Testing strategy** — the bar the change was held to — its **Scope** and **Out of scope**, and its `Intent-slug`. The implementation report's status is the author's own account of the criteria; this gate checks them independently. When it can't be read — missing, or the system unreachable — **STOP** and say which it was.

**Then look for the implementation report** at the path `docs/ISSUE-TRACKER.md` defines, named from the ticket id. It says what the author meant to build: take above all its **documented deviations** — a documented deviation is an intentional decision, so it feeds the mitigation filter rather than the finding list. Its *Tests added* is the author's account of what was tested; the ticket is what they were asked to test. There is no report → review the change on its own terms; this skill never requires one. **Done when** the change under review, the ticket id, the ticket's Acceptance criteria, Testing strategy, Scope, Out of scope and `Intent-slug`, and the implementation report — or its absence — are in hand.

### Step 2 — Resolve the deferrals

A previous review of this branch may sit at the review report path `docs/ISSUE-TRACKER.md` defines; when it is there, this is a re-review. Read it with its *Dropped by prior ruling* section, the fix report beside it, and every deferral ticket an earlier round opened, found the way `docs/ISSUE-TRACKER.md` says under *Finding a review's deferrals* — together they are what the prior-decision filter reads. The fix report holds only the latest round, so the tracker carries the earlier deferrals and *Dropped by prior ruling* carries the earlier *Noise / won't-fix* reasons. **Done when** this is a first review, or the previous review report, the fix report beside it and every deferral ticket an earlier round opened have been read.

### Step 3 — Read the standards the change has to meet

Read what the project documents about how its code is written: `AGENTS.md` and `CLAUDE.md` at the root and in each directory the change touches, `README.md`, and the linter, formatter and type-checker configs the repo ships.

Then read, for each kind of unit the change adds or edits, one existing sibling that does the same job, to know what "matches the existing patterns" means here. **Done when** every rule you will cite names its document, and each kind of unit the change adds or edits has a sibling read.

### Step 4 — Read every changed file end to end

Every file the change touches, whole — not the diff. A diff hides the caller three functions up that makes the new branch unreachable, and the helper that already does what the new code reimplements. New files get read in full for the same reason. A file a tool generates — a lockfile, a generated config — is the one exception: read its changed hunks, check that the whole file still parses, and say so in the report's *Scope*.

**A change too large to read in one pass gets dispatched, never sampled.** When the files no longer fit, split them into coherent groups — a module, a layer, a feature's slice — and send each group to a subagent that runs Steps 4 and 5 over its own files and reports its candidates back with the evidence attached. Hand each subagent the standards from Step 3, the ticket with its Acceptance criteria and Testing strategy, the implementation report, and this skill's **Posture** and Step 5 — without them Standards, Coverage and the code smells check against nothing. You run Step 6 over everything that comes back, so the filters stay in one place. Note the dispatch in the report's *Scope*. **Done when** every changed file has been read whole, by you or by the subagent its group went to.

### Step 5 — Build the case

Work the list below over every changed file. Each class is a thing to hunt for, not a box to tick: pass over a class silently only when you looked and found nothing. **Done when** every class below has been hunted over every changed file, and each candidate is anchored to a file and a line.

1. **Logic** — off-by-one bounds, inverted or short-circuiting conditionals, unhandled error paths, races and unawaited work, state mutated under an alias someone else holds — every acceptance criterion of the ticket the code doesn't meet, and a change outside the ticket's *Scope*, or inside its *Out of scope*, that the implementation report doesn't list as a deviation.
2. **Security** — injection through interpolated queries, commands and templates; unescaped output; secrets and keys in code, config or logs; authorization checked in one path and skipped in another; untrusted input reaching a sink unvalidated.
3. **Performance** — queries inside loops, work repeated per iteration that belongs outside it, unbounded growth of a collection or cache, resources opened and never released.
4. **Quality** — a function doing several jobs, a name that lies about what the thing holds, duplicated logic the codebase already has one home for, missing types or annotations where the project uses them, and every code smell below matched against the diff. Each smell is a judgement call, never a hard violation, and anything the project's tooling already enforces is skipped here:
   - **Feature Envy** — a method that reads or writes another object's fields more than its own → move the method onto that data.
   - **Data Clumps** — the same group of fields or parameters keeps travelling together across the diff → bundle them into one type.
   - **Primitive Obsession** — a primitive or string stands in for a domain concept the diff treats specially → give the concept its own type.
   - **Repeated Switches** — the same switch/if-cascade on the same type recurs in more than one hunk — distinct from the duplicated logic above, since the fix here is polymorphism, not extraction → replace with polymorphism or one shared map.
   - **Shotgun Surgery** — one conceptual change in this diff forced edits scattered across unrelated files → gather what changes together into one module.
   - **Divergent Change** — one file in the diff was edited for more than one unrelated reason — distinct from "a function doing several jobs" above, which is function-level; this is file-level → split so each module changes for one reason.
   - **Speculative Generality** — the diff adds an abstraction, parameter, or hook that neither the ticket nor the implementation report resolved in Step 1 ever asked for → delete it, inline back until a real need shows.
   - **Message Chains** — the diff introduces or extends a long `a.b().c().d()` navigation → hide the walk behind one method.
   - **Middle Man** — a new class or function mostly just delegates onward without adding logic → cut it, call the real target direct.
   - **Refused Bequest** — where the diff touches inheritance, a subclass or implementer ignores or overrides most of what it inherits → drop the inheritance, use composition.
5. **Standards** — the rules gathered in Step 3: lint, typing, formatting, logging, error handling, and the testing standard. Cite the document and the rule.
6. **Coverage** — the tests the change brought, and the ones it should have. Hunt the blocking kinds (**Posture**). Within a tested behavior, a branch nobody exercises is a finding; so is a test that asserts the implementation instead of the behavior.

### Step 6 — Run the three filters

Take each candidate through all three filters from **Posture**, and run the checks that settle them instead of reasoning about what the code probably does:

- Run the project's full test suite on the branch, whatever the candidates — it is how a *red* test gets found. Note a flaky one as such in *Checks run*. Run each *red* test on the base branch too, in a worktree created outside the repository and removed afterwards, so the change under review stays untouched, and confirm it against the conditions **Posture** sets for a base-red test. The project has no test suite → say so in *Checks run* the way **Posture** requires.
- Run the type-checker and linter on the changed files.
- Reproduce a logic finding against the actual code path — the conditions that reach it, and what the callers pass.
- On a re-review, match the candidate against the previous review's findings, against the deferral tickets Step 2 found, and against the previous fix report's *Noise / won't-fix* reasons and the previous report's *Dropped by prior ruling*. Record in this report's *Dropped by prior ruling* every candidate that a deferral or a *Noise / won't-fix* reason dropped this round, and carry forward the previous entries whose reason still holds against the code.

A surviving blocking finding stays **blocking**, and its kind names it. A *red* test whose cause also leaves an acceptance criterion unmet raises that `logic` finding too. Give every other survivor the Step 5 class it was found under — a test demoted from *red* by the base-red check (**Posture**) is **coverage** — `piv-fix-findings` types a deferral from it — and a severity from the scale below. **Done when** every candidate either survived all three filters with its class and severity — or its blocking kind — or was dropped by a named filter.

- **critical** — data loss, corruption, or a security defect a reachable path can trigger.
- **high** — wrong behavior on a path users reach, and every acceptance criterion the code doesn't meet.
- **medium** — wrong behavior on an edge path, or a documented standard violated.
- **low** — quality and maintainability, correct today.
- **Coverage**, whichever of the above its wording fits: **medium** when the unexercised branch can produce wrong behavior on a path users reach; **low** otherwise.

## Output — write a review report

Write the report at the review report path `docs/ISSUE-TRACKER.md` defines, filling the template at `templates/review-report.md` — use it exactly — built from the ticket id resolved in Step 1 — so a ticket's review sits beside its implementation report. On a re-review, this overwrites the previous one: it is the current state of the branch, and the decisions taken on the old findings live in the tracker, not here. Its **Round** is 1 on a first review and the previous review's **Round** plus one on a re-review. Its **Base** and **Diff** record the change reviewed, so `piv-commit-changes` can tell whether the tree still matches it. The **Diff** is what the bundled `scripts/diff-hash.sh` prints — run it with `sh` (it needs `git` and a POSIX shell), handed the **Base** and the exclude globs `docs/ISSUE-TRACKER.md` lists under *Paths*; there is no need to read it.

The blocking heading and every severity heading are present on every run, and one that survived nothing reads "No findings." *Dropped by prior ruling* is present too, reading "None." when nothing was dropped. The verdict is **CHANGES REQUESTED** when any blocking, critical or high finding survived, and **PASS** otherwise — a PASS with medium and low findings is normal.

### Step 7 — Validate the report

Reopen every `path:line` the report cites and confirm the line exists and says what its finding claims, then confirm every heading of the template is present. Any check that fails → fix the report and run the whole check again. **Done when** every cite and every heading passes. Then print the verdict with the count of blocking findings and the count per severity.

## Hand off

The review report is the artifact this run leaves behind, so hand over its path by name, with the ticket id. Offer the next move and let the user run it — this skill does not chain into the next one:

- **PASS** → run `piv-commit-changes`, in a session of its own, handed the ticket id. The medium and low findings stay in the report; `piv-create-pr` carries them into the PR body.
- **CHANGES REQUESTED** → run `piv-fix-findings`, in a session of its own, handed the review report's path as the review to work from.
