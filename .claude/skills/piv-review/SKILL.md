---
name: piv-review
description: Reviews the finished change for bugs, security defects and standards violations, and writes a review report.
argument-hint: "[ticket id] (blank = taken from the branch name)"
disable-model-invocation: true
allowed-tools:
  - Bash(sh *scripts/diff-hash.sh *)
  - Bash(sh *scripts/check-report.sh *)
  - Bash(sh *scripts/locate.sh *)
---

# Review: Prove the Change Wrong

This opens the **verify** step of the PIV loop `docs/piv-loop.md` describes: the work is built but not yet committed, and this gate decides whether it earns a commit. The review is a report, never an edit — the fixes belong to a later run, working from what this one writes down. Write the report in the intent's language — the ticket's `Language`, read in Step 1, or with no such field the language its body is written in; template labels stay as written. Nothing this run does may alter the change under review, the checks of Step 6 included.

## Posture

You are the prosecution. Assume the author got it wrong and prove it.

**The burden of proof is yours.** Every candidate faces three filters before it becomes a finding:

1. **Evidence** — a quoted line, or reasoning a reader can trace through the code in front of you. A candidate you cannot anchor to a file and a line is a suspicion, and suspicions stay out of the report.
2. **Mitigation** — go hunting for the place the flow already covers the problem: validation upstream, error handling around the call, a test that already pins the behavior, the reason an earlier round gives for ruling it *Noise / won't-fix*. That reason is evidence you weigh against the code, never an order: it drops the candidate only when it shows the problem is not there — "not worth fixing" admits the problem, and only a deferral settles that. A documented deviation drops a candidate whose only claim is that the code departs from the ticket; a defect in the deviating code still faces the evidence of the code. Covered, it drops.
3. **Prior decision** — this branch may have been reviewed before, and a human already ruled on what came back. A candidate **deferred on the record** — carried into a ticket that says this work happens later — is settled, and it drops. The ticket is what closes it: a deferral with nothing to point at is still open, and it gets reported again.

Step 6 runs the three filters. What survives becomes a finding; the rest goes nowhere.

**Some findings are facts, not arguments.** Four kinds are **blocking**:

- ***red*** — a test that fails on the branch in any run, flaky ones included.
- ***missing*** — a test the ticket's verification names — a section 9 command, or a deferral's **Testing strategy** — that is absent, or present but skipped, marked to fail, or asserting nothing.
- ***weakened*** — a test that existed before and now asserts less or something different — skipped, marked to fail, its assertions loosened or its expected values changed, or deleted — while the ticket left the behavior it pins unchanged.
- ***untested*** — a behavior the change adds or alters that no test exercises. A **behavior** is an observable outcome an acceptance criterion or the unit's public interface names, such as a new entry point or error contract. A new condition inside an outcome a test already asserts is a branch, and an unexercised branch is an ordinary coverage finding.

A blocking finding is observed, so it sits outside the severity scale and holds the verdict at CHANGES REQUESTED on its own. It faces the filters like any other, with two differences. A documented deviation leaves it standing: explaining a disabled test is transparency, not mitigation. A deferral leaves it standing too, because `piv-fix` never defers one — a deferred red test would reach PASS still red.

A *red* test **confirmed red on the base** — it ran on the **Base** commit, with the setup the branch run used, and failed the same assertion the branch run failed — is not this change's failure, and drops to a **coverage** finding, **medium**. A test that fails intermittently is re-run on the base the same number of times; one that also fails there is base-red (flaky), demoted like any base-red test. Flaky only on the branch stays *red*. A test the ticket's verification names, or the test that reproduces the defect a `bug` ticket describes, stays *red* whatever the base shows: turning it green is this change's job.

**A project with no test suite holds the change to no test.** *Missing* and *untested* do not apply, and *red* and *weakened* cannot arise. Say so in *Checks run*, naming the behaviors the change adds or alters that go untested, and raise no finding for them.

## Success criteria

- ✅ Every file in the change under review was examined with the context needed to judge it, and every class in Step 5 was hunted over each of them.
- ✅ Every reported finding carries a file, a line, and evidence anchored in the code.
- ✅ Every reported finding survived all three filters in **Posture**.
- ✅ The full test suite ran on the branch — or the project has none, and *Checks run* says so — and every *red* test is reported — blocking, or medium when **Posture** demotes it, unless an earlier deferral settles that medium.
- ✅ The change was held to every `AC-xx` criterion of the ticket, its verification, its task plan, and its non-goals and boundaries.
- ✅ The tree the report's **Diff** records is the tree that was reviewed: the checks left nothing behind.
- ✅ The report follows the template in **Output**, `check-report.sh` exits 0 on it with every cited line saying what its finding claims, and its path was given to the user with the next move.

## Bundled scripts

Three scripts sit in `${CLAUDE_SKILL_DIR}/scripts/`. Run each with `sh`, from the repository root, exactly as shown; never read them, and never hand-roll what they do.

- **`diff-hash.sh`** — `sh ${CLAUDE_SKILL_DIR}/scripts/diff-hash.sh [Base] [exclude-glob]...` prints one hash for the full diff from `[Base]` to the working tree, untracked files included, every exclude glob left out. Needs `git`. Exit 2 is a usage error and says what to pass.
- **`locate.sh`** — `sh ${CLAUDE_SKILL_DIR}/scripts/locate.sh [file] [text]` prints `file:line: content` for every line of `[file]` containing `[text]`, matched as a fixed string on one line. Needs `grep`, `tr` and `awk`. Exit 1 means no line matched: search a shorter piece of the line.
- **`check-report.sh`** — `sh ${CLAUDE_SKILL_DIR}/scripts/check-report.sh [report]` checks the header fields, the headings and their order, the sections' content, the verdict against the findings, and that every backticked `path:line` exists. Needs `awk`, `grep`, `sed`, `tr`, `wc`, `tail`, `sort` and `mktemp`. Exit 0 prints `check-report: ok`; exit 1 prints one problem per line.

## Process

Copy this checklist into your task list. Tick an item only when its step's **Done when** holds.

- [ ] 1. Resolve the change under review: Base, Diff, ticket, implementation report
- [ ] 2. Resolve the deferrals
- [ ] 3. Read the standards and siblings
- [ ] 4. Examine every changed file in its context
- [ ] 5. Build the case
- [ ] 6. Filter and class every candidate; recompute the Diff
- [ ] 7. Write the review report: `check-report.sh` exits 0, every cited line reopened

### Step 1 — Resolve the change under review

The **change under review** is everything this branch added on top of the base branch: the uncommitted tree — tracked and untracked alike — plus the commits sitting ahead of the base, leaving out the loop's own artifacts, which are the exclude globs `docs/issue-tracker.md` lists under *Paths*. `docs/git-conventions.md` says which branch is the base and what *the base* is: that branch's remote tip after a fetch. Fetch it first; a fetch that fails → **STOP** and say so. The **Base** is the commit the branch forked from, `git merge-base HEAD [the base]`: the base branch's tip moves, so every diff in this run is taken against the fork point. The merge-base failing → **STOP**, saying what to fetch. Gather the working tree status, the full diff against the Base, the diff statistics, and the list of untracked files. Then record the **Diff**: what `diff-hash.sh` prints, handed the Base and those exclude globs.

Nothing to review — a clean tree with no commits ahead of the base, once the artifacts are left out → **STOP** and say so.

**Then resolve the ticket id.** `$ARGUMENTS` carries it when one was handed to you; otherwise take it from the branch name, in the form `docs/git-conventions.md` defines. Neither carries one → ask the user for it. **GATE.**

**Then read the ticket**, where `docs/issue-tracker.md` says tickets live, and take, from a sliced ticket: its **criteria**, the `AC-xx` lines of section 5 — what the change has to do — its **verification**, the commands of section 9 — the bar the change was held to — its **task plan** (section 8), its **non-goals** (section 2) and its **boundaries** (*Always*, *Ask first* and *Never* of section 10), its `Intent-slug`, and its `Language`. A deferral gives the same in its own sections: the checklist under `Acceptance criteria`, its **Testing strategy**, its **Scope** and **Out of scope**. The `Language` is the language the report is written in; a ticket with no such field sets it by the language its body is written in. The implementation report's status is the author's own account of the criteria; this gate checks them independently. When the ticket can't be read — missing, or the system unreachable — **STOP** and say which it was.

**Then look for the implementation report** at the path `docs/issue-tracker.md` defines, named from the ticket id. It says what the author meant to build: take above all its **documented deviations** — a documented deviation is an intentional decision, so it feeds the mitigation filter rather than the finding list. Its *Tests added* is the author's account of what was tested; the ticket is what they were asked to test. There is no report → review the change on its own terms; this skill never requires one.

**Done when** the change under review, its Base and Diff, the ticket id, the ticket's criteria, verification, task plan, non-goals, boundaries and `Intent-slug`, the report language, and the implementation report — or its absence — are in hand.

### Step 2 — Resolve the deferrals

A previous review of this branch may sit at the review report path `docs/issue-tracker.md` defines; when it is there, this is a re-review. Read it with its *Dropped by prior ruling* section, the fix report beside it, and every deferral ticket an earlier round opened, found the way `docs/issue-tracker.md` says under *Finding a review's deferrals* — together they are what the prior-decision filter reads. The fix report holds only the latest round, so the tracker carries the earlier deferrals and *Dropped by prior ruling* carries the earlier *Noise / won't-fix* reasons.

**Done when** this is a first review, or the previous review report, the fix report beside it and every deferral ticket an earlier round opened have been read.

### Step 3 — Read the standards the change has to meet

Read what the project documents about how its code is written: `AGENTS.md` and `CLAUDE.md` at the root and in each directory the change touches, the linter, formatter and type-checker configs the repo ships.

Then read the closest existing sibling of each kind of unit the change adds or edits. It shows what "matches the existing patterns" means here, but documents outrank it: where a document read above contradicts the sibling, the document is the rule.

**Done when** every standards rule you will cite names a document, and every pattern you will cite names a sibling that no document contradicts.

### Step 4 — Examine every changed file in its context

Read every file the change touches with the context needed to judge it — its callers, the helpers it could have used — not the diff alone.

**A change too large for one pass is split into coherent groups — a module, a layer, a feature's slice — never sampled.** It is too large when you cannot hold every changed file and its context at once: reading the next file would mean losing one already read. Send each group to a subagent that runs Step 5 over its own files, reading them in context, and reports its candidates back with the evidence attached; it reports, it never edits. Give each subagent:

- the standards from Step 3, the ticket with its criteria and verification, and the implementation report — without them its Standards, Coverage and smell checks have no reference;
- this skill's **Posture** and Step 5, and the `locate.sh` command from **Bundled scripts** with `${CLAUDE_SKILL_DIR}` filled in;
- the Base, the command that prints the diff against it, and the map of group to files, so it can read what every other group changed.

Run Step 6 once over all the candidates that come back, and note the dispatch in the report's *Scope*.

**Done when** every changed file has been examined, alone or as part of a dispatched group.

### Step 5 — Build the case

Work the list below over every changed file. Each class is a thing to hunt for, not a box to tick: pass over a class silently only when you looked and found nothing. Take every line number you cite from `locate.sh`, never one counted by hand.

**Done when** every class below has been hunted over every changed file, and each candidate is anchored to a file and a line.

1. **Logic** — off-by-one bounds, inverted or short-circuiting conditionals, unhandled error paths, races and unawaited work, state mutated under an alias someone else holds — every `AC-xx` criterion of the ticket the code doesn't meet — an unmet criterion is a `logic` finding, `high` — and a change outside the ticket's task plan, or inside its non-goals or its *Never* boundary, that the implementation report doesn't list as a deviation.
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

- Run the project's full test suite on the branch, whatever the candidates — it is how a *red* test gets found. Note a flaky one as such in *Checks run*. The project has no test suite → say so in *Checks run* the way **Posture** requires.
- Run each *red* test on the Base too, in a worktree outside the repository, so the change under review stays untouched, and confirm it against the conditions **Posture** sets for a base-red test:

  ```
  git worktree add --detach [dir outside the repository] [Base]
  # set it up as the branch run was set up, then run the red test there, as many times as on the branch
  git worktree remove --force [dir outside the repository]
  ```

- Run the type-checker and linter the project configures (Step 3) on the changed files, in check mode only — never with a flag that fixes or rewrites files. The project configures neither → say so in *Checks run*.
- Reproduce a logic finding against the actual code path — the conditions that reach it, and what the callers pass.
- On a re-review, match the candidate against the previous review's findings, against the deferral tickets Step 2 found, and against the previous fix report's *Noise / won't-fix* reasons and the previous report's *Dropped by prior ruling*. Record in this report's *Dropped by prior ruling* every candidate that a deferral or a *Noise / won't-fix* reason dropped this round, and carry forward the previous entries whose reason still holds against the code.

When the checks are done, run `diff-hash.sh` again with the same arguments as in Step 1. A hash other than the recorded **Diff** means something wrote into the tree during the review. When it is what your checks left — a cache, a coverage file, a regenerated snapshot — remove it and recompute until the hash matches. When it is anything else → **STOP** and tell the user what changed: the tree no longer matches what was reviewed.

A surviving blocking finding stays **blocking**, and its kind names it. A *red* test whose cause also leaves an acceptance criterion unmet raises that `logic` finding too. Give every other survivor the Step 5 class it was found under — `piv-fix` types a deferral from it — and a severity:

- **critical** — data loss, corruption, or a security defect a reachable path can trigger.
- **high** — wrong behavior on a path users reach, and every acceptance criterion the code doesn't meet.
- **medium** — wrong behavior on an edge path, or a documented standard violated.
- **low** — quality and maintainability, correct today.

A **coverage** finding is **medium** when it is a *red* test demoted as base-red (**Posture**), or an unexercised branch that can produce wrong behavior on a path users reach; it is **low** otherwise.

**Done when** every candidate either survived all three filters with its class and severity — or its blocking kind — or was dropped by a named filter, and the recomputed hash matches the recorded **Diff**.

## Output — write a review report

Write the report at the review report path `docs/issue-tracker.md` defines for the ticket id from Step 1, so it sits beside the implementation report. Fill `templates/review-report.md` exactly: every heading, in the template's order, with its labels as written.

- **Round** — 1 on a first review; the previous review's **Round** plus one on a re-review. A re-review overwrites the previous report: it is the current state of the branch, and the decisions taken on the old findings live in the tracker, not here.
- **Base** and **Diff** — the values Step 1 recorded and Step 6 confirmed. `piv-commit` recomputes the Diff to tell whether the tree still matches the review.
- **Findings** — the Blocking heading and every severity heading are present on every run; one that holds no finding reads "No findings.". *Dropped by prior ruling* reads "None." when nothing was dropped.
- **Verdict** — **CHANGES REQUESTED** when any blocking, critical or high finding survived; **PASS** otherwise. A PASS with medium and low findings is normal.
- **Language** — everything the template leaves to you — each finding's claim, evidence, impact and fix, the notes under *Scope*, and *Checks run* — is written in the report language Step 1 resolved; only the template's labels and headings stay as written.

Check the report before handing it on, whatever the verdict:

1. Run `check-report.sh` on the report's path.
2. It prints problems → fix each one in the report and go back to 1. Go on only when it exits 0.
3. Reopen every cited line and confirm it says what its finding claims — the script checks only that the line exists. A finding whose line does not → correct the citation or the finding, and go back to 1.

Then print the verdict, the count of blocking findings and the count per severity.

## Hand off

The review report is the artifact this run leaves behind, so give the user its path by name, with the ticket id. Offer the next move and let the user run it — this skill does not chain into the next one:

- **PASS** → run `piv-commit`, in a session of its own, handed the ticket id. The medium and low findings stay in the report; `piv-open-pr` carries them into the PR body.
- **CHANGES REQUESTED** → run `piv-fix`, in a session of its own, handed the review report's path as the review to work from.
