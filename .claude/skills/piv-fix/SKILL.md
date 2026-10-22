---
name: piv-fix
description: Triages the findings of a task's review report, fixes the ones you choose one at a time with tests, defers the rest as local deferrals, then validates and writes a fix report.
argument-hint: "[review report path] (blank = the review report of the epic's task in progress)"
disable-model-invocation: true
---

# Fix: Triage, Fix, Validate

This runs inside the **verify** step of the PIV loop (`docs/piv-loop.md`): it settles every finding of a review and hands the branch back to `piv-review`, whose fresh PASS is the only thing that closes the loop. A review is **input, not a work order**: you propose where each finding lands, and the user rules.

## Before Step 1

1. **Find the review report.** `$ARGUMENTS` carries its path. With no path, resolve the intent and its task in progress as `docs/piv-loop.md` says under *Resolving the intent and the task*, and look at `.piv/[intent-slug]/tasks/T-xx/T-xx.review.md`. No report there → **STOP** and ask the user for the report to work from.
2. **Read the review report end to end**, so you understand every finding before triaging. Take the issue number and the task id from its header.
3. **Read the reviewed ticket** at `.piv/[intent-slug]/tasks/T-xx/T-xx.md`. It supplies the `Language` and the `Intent-slug` every deferral copies. Missing → **STOP** and say so.
4. **Set the language.** The fix report and every deferral are written in the intent's language: the reviewed ticket's `Language`. Template labels and headings stay as written; everything you fill in — descriptions, proofs, reasons, *Checks run* — is in the intent's language.
5. **Check for an earlier run** at `.piv/[intent-slug]/tasks/T-xx/T-xx.fixes.md`:
   - **No fix report, or one whose *Round* is lower than the review report's** → it belongs to an earlier review. Start at Step 1.
   - **Same *Round*, with a *Fixed* entry `not fixed — pending`, a *Deferred* entry `not created`, or a *Needs a human look* entry open** → an earlier run stopped after the user ruled. The ruling stands: skip Step 1 and its GATE. Ask the user for a verdict on each open *Needs a human look* entry — for one moved to *Defer*, propose its title and type as Step 1 does — and record each verdict in the fix report as a pending entry of its new bucket. Then resume at Step 2: write only the deferrals not yet written — a file under `deferrals/` whose *Origin* names this task and round with the same claim is already written — fix only the findings still pending, then Step 4. When the user rules on no open entry and nothing else is pending, **STOP**: the hand-off stays blocked until they do.
   - **Same *Round*, nothing pending and nothing open** → this review was fully triaged. **STOP** and point the user at the fix report and at running `piv-review` again; triaging again would duplicate every deferral.

## Success criteria

- ✅ Every finding in the review report landed in exactly one bucket, and the user ruled on the split.
- ✅ No blocking finding was deferred.
- ✅ Every finding the change introduced was proposed for *Fix now*; one the user ruled elsewhere carries the user's reason in the fix report.
- ✅ Every finding you proposed to defer reproduces on the review report's *Base* without the change.
- ✅ Every *Fix now* finding has its Step 3 proof passing, is marked `not fixed` with the hypotheses tried, or was moved to *Needs a human look* as a refactor.
- ✅ Every deferred finding has its file at `deferrals/D-xx.md`, its `D-xx` in the fix report, and its line under the epic's *Deferrals*.
- ✅ The project's checks are green, or each one still red is recorded in the fix report's *Checks run*.
- ✅ The outcome is written to the fix report path, not only printed.
- ✅ The run ended by handing the branch back to `piv-review` or, with a *Needs a human look* entry open, by asking the user to rule on it.

## Process

Copy this checklist into your task list. Tick an item only when its step's **Done when** holds.

```
- [ ] Step 1 — Triage
- [ ] Step 2 — Write a deferral for each finding deferred
- [ ] Step 3 — Fix the *Fix now* set, one at a time
- [ ] Step 4 — Validate
- [ ] Step 5 — Finish the fix report and hand off
```

### Step 1 — Triage

**The change** is the diff against the review report's *Base*, uncommitted work included.

**Type.** Every finding's type follows its class, never its claim, as `docs/piv-loop.md` defines types: `bug` for logic and security — behavior that diverges from what was specified or delivered — and for any finding of severity critical or high; `task` for the rest. Never `feature`: a deferral delivers no new capability.

**Blocking.** A finding is blocking when it is a red, missing or weakened test, or an untested behavior.

Sort the findings into four buckets, each finding into exactly one. Propose the cut by whether the change introduced the finding, whatever its severity. Two rules override that cut:

- A blocking finding is never deferred: it goes to *Fix now*, or to *Noise / won't-fix* with a reason that shows the problem is not there.
- A finding the change introduced is never deferred to keep the change small: its repair is part of the change.

The buckets:

- **Fix now** — real, and introduced by the change: a defect in code it touched, a break it caused elsewhere (a test it turned red), or something it left out (an unmet acceptance criterion).
- **Defer** — real, and it reproduces on the *Base* without the change. Confirm the reproduction in a throwaway worktree outside the repository, and remove it afterwards:
  ```bash
  git worktree add --detach [path outside the repository] [Base]
  # reproduce the finding there
  git worktree remove --force [path outside the repository]
  ```
  Propose the deferral's type and its title — imperative and specific, naming the defect and where it lives: `Reject an empty email in the signup handler`, not `Fix validation`.
- **Needs a human look** — anything the user should inspect or test by hand before trusting it. Flag it; do not fix it.
- **Noise / won't-fix** — not a real problem. The next review weighs your reason against the code, so give one the code bears out: "the handler already rejects it at `api/signup.py:31`" keeps the finding from coming back; "minor" or "not worth fixing" does not. A real finding closes only through a fix or a deferral.

**GATE** — post the split, each deferral with its proposed title and type, and wait for the user's ruling. No code moves and no deferral is written until they rule. When the user rules a finding the change introduced out of *Fix now*, ask for their reason; it goes in the fix report.

**Once they rule, write the fix report** at `.piv/[intent-slug]/tasks/T-xx/T-xx.fixes.md`, filling `templates/fix-report.md` exactly. In this first write every *Fixed* entry is `not fixed — pending` and every *Deferred* entry is `not created — pending`. Flip each one as it lands: a `D-xx` as Step 2 writes it, a fix as Step 3 turns it green. A run that stops midway, for any reason, thus leaves the ruling on record, and the next run resumes from it.

**Done when** the user has ruled and the fix report holds every finding in its ruled bucket.

### Step 2 — Write a deferral for each finding deferred

Write each deferral at `.piv/[intent-slug]/deferrals/D-xx.md`, numbered on from the highest `D-xx` already there — `D-01` when there is none — filling `templates/deferral.md` exactly. Take the claim, impact, evidence, location and fix from the finding in the review report, and copy evidence and location in full: the next review overwrites the review report, and `piv-open-pr` publishes each deferral in full in the PR body, so it must stand on its own.

- **Type** — the type ruled at the GATE.
- **Header block** — `Intent-slug` and `Language` copied verbatim from the reviewed ticket; `Origin` the task id and the review report's *Round*.

As each file is written, record its `D-xx` in the fix report, and append `- D-xx — [title] — origin T-xx` under the epic's *Deferrals*, replacing its `None.`. When a write fails, mark that entry `not created — [the error]` and **STOP**, saying what failed; rerunning this skill once the cause is cleared resumes from there.

**Done when** every *Defer* finding has its file, its `D-xx` in the fix report and its line in the epic.

### Step 3 — Fix the *Fix now* set, one at a time

Blocking findings first, then by severity. For each:

1. Explain what was wrong.
2. Make the fix.
3. Pick its proof — the first that applies:
   - **Blocking** — the test itself: the red test green through a change to the code (or to its assertions, when the ticket changed the behavior it pins); the missing test written and passing; the weakened test restored and passing; the untested behavior exercised by a new passing test.
   - **Typed `bug`** — a test that fails without the fix and passes with it.
   - **Any other** — the check that shows the claim no longer holds: the lint or type-check rule it broke or, for a coverage finding, the test it asked for.
4. Run the proof. When it passes, the finding is **green**: mark it fixed in the fix report, with what changed and the proof. When it fails, work it again before starting the next finding. After three attempts, each on a different hypothesis about the cause, mark it `not fixed — [the hypotheses tried]` and move on.

Fix what the finding names and stop there. A finding the change introduced is repaired in full, however large the repair. For any other finding, a repair that grows into a refactor is out of scope: move the finding from *Fixed* to *Needs a human look* as a candidate task. Write no deferral beyond the ruled ones.

**Done when** every *Fix now* finding is marked fixed, marked `not fixed` with the hypotheses tried, or moved to *Needs a human look*.

### Step 4 — Validate

Run the project's own checks — the test, lint, type-check and build commands the repo exposes. When one goes red, fix the cause and re-run until it is green.

Stop working a red check when three attempts, each on a different hypothesis about the cause, leave it red, or when its cause sits outside what the findings ask you to change.

Record every check in the fix report's *Checks run* with its result; for one left red, add the failure and what you tried.

**Done when** every check is green, or each one still red is recorded in *Checks run*.

## Output — finish the fix report

Check that every entry in the fix report carries its final state, then print a summary: the fix report's path, the count in each bucket, each deferral's `D-xx`, every finding `not fixed`, every check still red.

Everything the template leaves to you — each entry's description, its proof or reason, and *Checks run* — is written in the intent's language; only the template's labels and headings stay as written.

## Hand off

Offer the next move and let the user run it — this skill does not chain into the next one:

- **A *Needs a human look* entry is open** → the hand-off to `piv-review` is blocked. Ask the user to inspect each entry, then rerun this skill, here or in a fresh session: their verdict moves each entry into *Fix now*, *Defer* or *Noise / won't-fix*, and the run resumes from there.
- **None is open** → run `piv-review [#N] [T-xx]` again, in a session of its own.
