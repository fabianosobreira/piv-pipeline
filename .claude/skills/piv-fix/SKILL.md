---
name: piv-fix
description: Triages the findings of a task's review report, fixes the ones you choose one at a time with tests, defers the rest as local deferrals, then validates and writes a fix report.
argument-hint: "[review report path] (blank = the review report of the epic's task in progress)"
disable-model-invocation: true
allowed-tools: Bash(sh ${CLAUDE_SKILL_DIR}/scripts/diff-hash.sh *)
---

# Fix: Triage, Fix, Validate

This runs inside the **verify** step of the PIV loop (`docs/piv-loop.md`): it settles every finding of a review and hands the branch back to `piv-review`, whose fresh PASS is the only thing that closes the loop; a PASS review whose tree still matches its **Diff hash** after this run still stands. A review is **input, not a work order**: you propose where each finding lands, and the user rules.

## Before Step 1

1. **Find the review report.** `$ARGUMENTS` carries its path. With no path, resolve the intent and its task in progress as `docs/piv-loop.md` says under *Resolving the intent and the task*, and look at `.piv/[intent-slug]/tasks/T-xx/T-xx.review.md`. No report there → **STOP** and ask the user for the report to work from.
2. **Read the review report end to end**, so you understand every finding before triaging. Take the issue number and the task id from its header. A finding outside *Test facts* whose line ends on no origin → **STOP** and ask the user to run `piv-review` again: the origin is the review's ruling, never yours.
3. **Read the reviewed ticket** at `.piv/[intent-slug]/tasks/T-xx/T-xx.md`. It supplies the `Language` and the `Intent-slug` every deferral copies, and the boundaries every fix stays inside: *Ask first* and *Never* of section 8. Missing → **STOP** and say so.
4. **Set the language.** The fix report and every deferral are written in the intent's language: the reviewed ticket's `Language`. Template labels and headings stay as written; everything you fill in — descriptions, proofs, reasons, *Checks run* — is in the intent's language.
5. **Check for an earlier run** at `.piv/[intent-slug]/tasks/T-xx/T-xx.fixes.md`:
   - **No fix report, or one whose *Round* is lower than the review report's** → it belongs to an earlier review. Start at Step 1.
   - **Same *Round*, with a *Fixed* entry `not fixed — pending`, a *Deferred* entry `not created`, or a *Needs a human look* entry open** → an earlier run stopped after the user ruled. The ruling stands: skip Step 1 and its GATE. Ask the user for a verdict on each open *Needs a human look* entry — for one moved to *Defer*, propose its title and type as Step 1 does — and record each verdict in the fix report as a pending entry of its new bucket. Then resume at Step 2: write only the deferrals not yet written — a file under `deferrals/` whose *Origin* names this task and round with the same claim is already written — fix only the findings still pending, then Step 4. When the user rules on no open entry and nothing else is pending, **STOP**: the hand-off stays blocked until they do.
   - **Same *Round*, nothing pending and nothing open** → this review was fully triaged. **STOP** and point the user at the fix report and at the next move the **Hand off** names; triaging again would duplicate every deferral.

## Success criteria

- ✅ Every finding in the review report landed in exactly one bucket, and the user ruled on the split.
- ✅ No test-fact finding was deferred.
- ✅ Every test-fact, *introduced* or *aggravated* finding was proposed for *Fix now*, or for *Needs a human look* when the code contradicts its test-fact kind or origin; one the user ruled elsewhere carries the user's reason in the fix report, except a *low* one, which carries no reason: its `D-xx` when deferred, `won't fix — low` when left unfixed.
- ✅ Every finding you proposed to defer is *pre-existing* in the review report; an *introduced* or *aggravated* *low* one is deferred only when the user rules it so.
- ✅ Every *Fix now* finding has its Step 3 proof passing, is marked `not fixed` with the hypotheses tried, or was moved to *Needs a human look* as a refactor.
- ✅ Every deferred finding has its file at `deferrals/D-xx.md`, its `D-xx` in the fix report, and its line under the epic's *Deferrals*.
- ✅ With a *Fix now* set, the baseline of the tests in scope ran once, before the first edit — or the project has none, and *Checks run* says so; the full suite never ran; every test red there that no finding names is in *Checks run*, and every check of Step 4 is green or recorded red there.
- ✅ The outcome is written to the fix report path, not only printed.
- ✅ The run ended by handing the branch back to `piv-review` — or to `piv-commit` when the review was a PASS and the tree still matches its **Diff hash** — or, with a *Needs a human look* entry open, by asking the user to rule on it.

## Process

### Step 1 — Triage

**The change** is the diff against the review report's *Base*, uncommitted work included. The **tests in scope** are the tests that exercise, directly or through a caller, code the change touched or a *Fix now* finding cites — and, once Step 3 edits, code this run touched, with every test it wrote or edited.

**Type.** Every finding's type follows its class, never its claim, as `docs/piv-loop.md` defines types: `bug` for logic and security — behavior that diverges from what was specified or delivered — and for any finding of severity critical or high; `none` for the rest. Never `feature`: a deferral delivers no new capability.

**Test fact and origin** are the review's rulings, read from the report: a finding is test-fact when it sits under the *Test facts* heading, and every other finding's line ends on its origin — *introduced*, *aggravated* or *pre-existing*. Take both as written. When the code contradicts the test-fact kind or the origin — not the claim itself, which *Noise / won't-fix* settles — propose the finding for *Needs a human look*, naming the contradiction.

Sort the findings into four buckets, each finding into exactly one. Propose the cut by origin, whatever the severity: test-fact, *introduced* and *aggravated* to *Fix now*, *pre-existing* to *Defer*. A contradiction of the test-fact kind or the origin, above, overrides that cut, and so do three rules:

- A test-fact finding is never deferred: it goes to *Fix now*, or to *Noise / won't-fix* with a reason that shows the problem is not there.
- An *introduced* or *aggravated* finding of severity critical, high or medium is never proposed for deferral to keep the change small: its repair is part of the change.
- An *introduced* or *aggravated* *low* finding is optional, since it never forced CHANGES REQUESTED: propose it for *Fix now*, and the user may instead rule it to *Defer* or leave it unfixed, with no reason asked. A deferral settles it for the next review; a finding left unfixed lands in *Noise / won't-fix* as `won't fix — low`, the only entry whose reason the code need not bear out, and the next review reports it again.

The buckets:

- **Fix now** — real, and the change answers for it: a defect in code it touched, a break it caused elsewhere (a test it turned red), something it left out (an unmet acceptance criterion), or an old defect it made reachable.
- **Defer** — real, and *pre-existing*: the review reproduced it on the *Base* without the change; or an *introduced* or *aggravated* one the user rules here at the GATE, a *low* one with no reason and any other with the reason the GATE asks. Propose the deferral's type and its title — imperative and specific, naming the defect and where it lives: `Reject an empty email in the signup handler`, not `Fix validation`.
- **Needs a human look** — anything the user should inspect or test by hand before trusting it. Flag it; do not fix it.
- **Noise / won't-fix** — not a real problem, or a *low* one the user leaves unfixed. The next review weighs your reason against the code, so give one the code bears out: "the handler already rejects it at `api/signup.py:31`" keeps the finding from coming back; "minor" or "not worth fixing" does not. A real finding closes only through a fix or a deferral; an *introduced* or *aggravated* *low* one may also be left open as `won't fix — low`.

**GATE** — post the split, each deferral with its proposed title and type, and wait for the user's ruling. A finding the user rules into *Defer* that you did not propose gets its title and type proposed before its deferral is written. No code moves and no deferral is written until they rule. When the user rules a test-fact, *introduced* or *aggravated* finding out of *Fix now*, ask for their reason; it goes in the fix report. A *low* one needs no reason. A *Fix now* finding whose repair reaches an *Ask first* item names that item in the split, and the user's ruling is the permission; one whose repair needs a *Never* item goes to *Needs a human look*.

**Once they rule, write the fix report** at `.piv/[intent-slug]/tasks/T-xx/T-xx.fixes.md`, filling `${CLAUDE_SKILL_DIR}/templates/fix-report.md` exactly. In this first write every *Fixed* entry is `not fixed — pending` and every *Deferred* entry is `not created — pending`. Flip each one as it lands: a `D-xx` as Step 2 writes it, a fix as Step 3 turns it green. A run that stops midway, for any reason, thus leaves the ruling on record, and the next run resumes from it.

**Done when** the user has ruled and the fix report holds every finding in its ruled bucket.

### Step 2 — Write a deferral for each finding deferred

Write each deferral at `.piv/[intent-slug]/deferrals/D-xx.md`, numbered on from the highest `D-xx` already there — `D-01` when there is none — filling `${CLAUDE_SKILL_DIR}/templates/deferral.md` exactly. Take the claim, impact, evidence, location and fix from the finding in the review report, and copy evidence and location in full: the next review overwrites the review report, and `piv-open-pr` publishes each deferral in full in the PR body, so it must stand on its own.

- **Type** — the type ruled at the GATE.
- **Header block** — `Intent-slug` and `Language` copied verbatim from the reviewed ticket; `Origin` the task id and the review report's *Round*.

As each file is written, record its `D-xx` in the fix report, and append `- D-xx — [title] — origin T-xx` under the epic's *Deferrals*, replacing its `None.`. When a write fails, mark that entry `not created — [the error]` and **STOP**, saying what failed; rerunning this skill once the cause is cleared resumes from there.

**Done when** every *Defer* finding has its file, its `D-xx` in the fix report and its line in the epic.

### Step 3 — Fix the *Fix now* set, one at a time

**Before the first edit, run the tests in scope once — the baseline — and wait for it to finish**, so every test it leaves red was red before this run's edits. Never run the full suite: this run answers only for the tests in scope. A test red in the baseline that no *red* finding names is not this run's: it enters no bucket and is not worked, and *Checks run* names it with the assertion it fails. The project has no test suite → no baseline, and *Checks run* says so.

Test-fact findings first, then by severity. Findings that share one repair — the same cause or the same lines — are fixed as one, and each keeps its own proof and its own entry. For each:

1. Explain what was wrong.
2. Make the fix.
3. Pick its proof — the first that applies:
   - **Test facts** — the test itself: the red test green through a change to the code (or to its assertions, when the ticket changed the behavior it pins); the missing test written and passing; the weakened test restored and passing; the untested behavior exercised by a new passing test.
   - **Typed `bug`** — a test that fails without the fix and passes with it.
   - **Any other** — the check that shows the claim no longer holds: the lint or type-check rule it broke or, for a coverage finding, the test it asked for.
   - **No test the project's setup can run** — a typed `bug` whose behavior the setup cannot exercise: the waiver is the user's, never yours. Post the finding, why the setup cannot reach it and the manual check that would prove it. **GATE.** Waived → the proof is that manual check, recorded as `manual: [the check]`.
4. Run the proof. It runs only the tests it names, never the full suite. A red test that failed intermittently is green only when its entry names the cause the fix removed: one passing run proves nothing about it. When it passes, the finding is **green**: mark it fixed in the fix report, with what changed and the proof. When it fails, work it again before starting the next finding. After three attempts, each on a different hypothesis about the cause, mark it `not fixed — [the hypotheses tried]` and move on.

Fix what the finding names and stop there. A test-fact finding, or an *introduced* or *aggravated* one of severity critical, high or medium, is repaired in full, however large the repair. For any other finding, a repair that grows into a refactor is out of scope: move the finding from *Fixed* to *Needs a human look* as a candidate task. Write no deferral beyond the ruled ones.

**Done when** every *Fix now* finding is marked fixed, marked `not fixed` with the hypotheses tried, or moved to *Needs a human look*.

### Step 4 — Validate

Run the tests in scope again, then the lint, type-check and build commands the repo exposes. A test that fails the assertion it failed in the baseline is not this run's: record it, don't work it. Any other red check is — a test outside the baseline included: fix the cause and re-run it until it is green. Nothing was fixed → Step 4 runs nothing, and *Checks run* says so.

Stop working a red check when three attempts, each on a different hypothesis about the cause, leave it red, or when its cause sits outside what the findings ask you to change.

Record every check in the fix report's *Checks run* with its result; for one left red, add the failure and what you tried.

A check, the baseline included, may leave files behind — a cache, a coverage file, a regenerated snapshot. Remove them, so the tree holds the fixes and nothing else.

**Done when** every check is green, or each one still red is recorded in *Checks run*, and the checks left nothing behind.

## Output — finish the fix report

Check that every entry in the fix report carries its final state, then print a summary: the fix report's path, the count in each bucket, each deferral's `D-xx`, every finding `not fixed`, every check still red and every test red before this run.

Everything the template leaves to you — each entry's description, its proof or reason, and *Checks run* — is written in the intent's language; only the template's labels and headings stay as written.

## Hand off

Offer the next move and let the user run it — this skill does not chain into the next one:

- **A *Needs a human look* entry is open** → the hand-off to `piv-review` is blocked. Ask the user to inspect each entry, then rerun this skill, here or in a fresh session: their verdict moves each entry into *Fix now*, *Defer* or *Noise / won't-fix*, and the run resumes from there.
- **None is open** → hash the tree by running the bundled script — run it, don't read it — with the review report's **Base** and nothing else:

  ```bash
  sh ${CLAUDE_SKILL_DIR}/scripts/diff-hash.sh '[Base]'
  ```

  - **The verdict is PASS and the hash equals the report's Diff hash** → the PASS still stands: run `piv-commit [#N] [T-xx]`, in a session of its own.
  - **Any other case, a failed script included** → run `piv-review [#N] [T-xx]` again, in a session of its own.
