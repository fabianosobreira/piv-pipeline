---
name: piv-fix-findings
description: Triages the findings of a review report, fixes the ones you choose one at a time with tests, defers the rest as tickets, then validates and writes a fix report.
argument-hint: "[review report path] (blank = the review report written for this branch)"
disable-model-invocation: true
---

# Fix Findings: Triage, Fix, Validate

This continues the **verify** step of the PIV loop `docs/piv-loop.md` describes: the review raised findings, and this run settles every one of them — the loop only closes when the fresh review this hands back to returns PASS.

A review produced findings — but a review is **input, not a work order**: you propose where each one lands, and the user rules on the split at the GATE below.

`$ARGUMENTS` carries the review report's path. **No path handed to you** — go find the report written for this branch, at the review report path `docs/issue-tracker.md` defines, named from the ticket id on the branch name, in the form `docs/git-conventions.md` gives it. No id on the branch name → ask the user for it. **GATE.** No report at that path → **STOP** and ask the user for the report to work from; until a report exists there is nothing to triage.

**Read it end to end first**, so you understand every finding before triaging.

Take the ticket id from the review report's header.

Read the reviewed ticket where `docs/issue-tracker.md` says tickets live — it is where the `Language` this run writes in and the deferral's epic and header block come from. When it can't be read — missing, or the system unreachable — **STOP** and say which it was.

Write the fix report and every deferral in the intent's language — the reviewed ticket's `Language`, read above, or with no such field the language its body is written in; template labels stay as written.

**A fix report already at the fix report path `docs/issue-tracker.md` defines, its Round matching this review report's** — the review report has not been rewritten since — was triaged against exactly this review. A deferral marked not created or a fix marked not fixed means an earlier run stopped midway after the user ruled: resume from it. The ruling stands, so skip Step 1 and its GATE, create only the deferrals not yet created, fix only the findings not yet fixed, then carry on to Step 4. A *Needs a human look* item the user has since ruled on counts as pending in its new bucket. Nothing pending → this review was already fully triaged; **STOP** and point the user at this fix report and at running `piv-review-changes` again, rather than re-triaging and recreating every deferral ticket as a duplicate. A fix report with a lower Round belongs to an earlier review: triage from scratch.

Copy this checklist into your task list. Tick an item only when its step's completion criterion holds.

- [ ] 1. Triage
- [ ] 2. Open a ticket for each deferral
- [ ] 3. Fix the *Fix now* set, one at a time
- [ ] 4. Validate

## Success criteria

- ✅ Every finding in the review report landed in exactly one bucket, and the user ruled on the split.
- ✅ Every blocking finding landed in *Fix now*, or in *Noise / won't-fix* with a reason that shows the problem is not there.
- ✅ Every *Fix now* finding has its Step 3 proof — a test that fails without the fix for a `bug`-type finding, the check that shows the claim gone for any other.
- ✅ Every deferred finding has a ticket created by the tracker doc's *Creating a ticket* rules, and its id in the fix report.
- ✅ The project's checks are green, or each one still red is recorded in the fix report's *Checks run*.
- ✅ The triage outcome was written to the fix report path, not only printed.
- ✅ The run ended by handing the branch back to `piv-review-changes`, which is the only thing that closes the loop.

## Process

### Step 1 — Triage

A finding's type follows its class, never its claim, the way `docs/issue-tracker.md` defines the types under *Creating a ticket*: `bug` for logic and security — behavior that diverges from what was specified or delivered — and for any finding of severity critical or high; `task` for the rest. A deferral never delivers a new capability, so it is never a `feature`.

Sort the findings into four buckets. The review's blocking findings and severities are the default cut you propose: blocking, critical and high in *Fix now*, medium and low in *Defer*. Low goes to *Defer* too, not to *Noise*: for a finding that is real, a deferral is the only thing that closes it.

- **Fix now** — real, in-scope, belongs with this change.
- **Defer** — real but later; don't bloat this change. Each one becomes a ticket in Step 2; propose its title — imperative and specific, as `piv-create-tickets` titles its tickets — and its type from the class above.
- **Needs a human look** — anything the user should inspect or test by hand before trusting it; flag it here rather than fixing it yourself.
- **Noise / won't-fix** — say why, then drop it. The next review weighs that reason against the code, so make it one the code can bear out: a reason that shows the problem is not there keeps the finding from coming back; "not worth fixing" does not.

Every finding lands in exactly one bucket. A finding real and in scope for this change can still belong in *Defer* — "real, but later" is a valid and common call, and a clean small change beats a sprawling one.

A **blocking** finding — a red, missing or weakened test, or an untested behavior — lands in *Fix now*, or in *Noise / won't-fix* with a reason that shows the problem is not there. Those are the two buckets that close it.

**GATE** — post the split, each deferral with the title and type its ticket will carry, and wait for the user's ruling. No code moves and no ticket is created until they rule.

**Once they rule, write the fix report** at the fix report path `docs/issue-tracker.md` defines, filling the template at `templates/fix-report.md` — use it exactly — with the split — every *Fixed* entry marked *not fixed* and every *Deferred* entry marked *not created* from this first write, each flipped only once it lands. Keep it current through the steps below: each deferral's ticket id as it is created, each fix as it goes green. A run that stops midway, for any reason, still leaves the ruling on record, with whatever hasn't landed still marked pending. Running this skill again resumes from that record once the cause is cleared. **Done when** the user has ruled and the fix report holds every finding in its ruled bucket.

### Step 2 — Open a ticket for each deferral

A deferral is a ticket: create it by the rules `docs/issue-tracker.md` gives under *Creating a ticket* — the same rules `piv-create-tickets` follows — so it lands in the backlog typed and linked like every other ticket, and `piv-implement-ticket` can pick it up cold. Fill the template at `templates/deferral.md` — use it exactly — taking the claim, impact, evidence, location and fix from the finding in the review report. Its *Origin* and *Evidence* are the deferral's entry context. The review report stays local and the next review overwrites it, so a run picking the deferral up cold may never see it: the evidence and the location are what that run reads first.

- **Type** — the type ruled at the GATE.
- **Epic and header block** — the reviewed ticket's epic as its parent, and its `Intent-slug`, `Language`, `Intent` and `Architecture` copied verbatim.
- **Link** — linked to the reviewed ticket, the way *Creating a ticket* says a deferral is. That link is what lets the next review find the deferral once this fix report is overwritten, and what the PR body points at.
- **Depends on** — the reviewed ticket: the code the finding names only exists once that ticket lands.

Leave the epic's body untouched.

Record each created ticket's id against its finding in the fix report. **Done when** every *Defer* finding has a created ticket whose id is in the fix report.

### Step 3 — Fix the *Fix now* set, one at a time

For each finding, blocking first, then in severity order:

1. Explain what was wrong.
2. Make the fix.
3. Prove it. A blocking finding's proof is the test itself: the red test green through a change to the code — or to its assertions, when the ticket changed the behavior it pins — the missing test written and passing, the weakened test restored and passing, the untested behavior exercised by a new test that passes. A finding typed `bug` gets a test that fails without the fix and passes with it. Any other gets the check that shows its claim no longer holds: the lint or type-check rule it broke, or, for a coverage finding, the test it asked for.
4. Run that proof. The finding goes **green** when it passes, and a red finding gets fixed before the next one starts. When three attempts, each on a different hypothesis about the cause, leave it red, mark it *not fixed* with what was tried, and move to the next.

Fix what the finding names and stop there. A repair that grows into a refactor is out of scope: list it in the fix report's *Needs a human look* as a candidate ticket. This run creates none beyond the ruled deferrals. **Done when** every *Fix now* finding is green and marked fixed in the fix report, or marked *not fixed* with its reason.

### Step 4 — Validate

Run the project's own checks — the test, lint, type-check, and build commands the repo exposes. When a check goes red: fix the cause, re-run, and continue once it is green.

When three attempts, each on a different hypothesis about the cause, leave a failure red, or its cause sits outside what the findings ask you to change, stop working it: record the check, the failure, and what you tried in the fix report's *Checks run*. `piv-create-pr` reads this *Checks run* ahead of the implementation report's for its own Validation. **Done when** every check is green, or each one still red is recorded in *Checks run*.

## Output — finish the fix report

Finish the fix report started in Step 1 — every bucket settled, *Checks run* filled from Step 4 — and print the summary.

Everything the template leaves to you — each entry's description, its proof or reason, and *Checks run* — is written in the intent's language; only the template's labels and headings stay as written.

## Hand off

Confirm the fix report's path and each deferral ticket's id, then offer the next move and let the user run it — this skill does not chain into the next one:

- Run `piv-review-changes` again over the branch, in a session of its own. It reads the deferral tickets this run opened. Hand it the ticket id.
- Once the user has looked at the *Needs a human look* items, rerun this skill, here or in a fresh session: their verdict moves each item into *Fix now*, *Defer* or *Noise / won't-fix*, and the run resumes from there. A *Needs a human look* item still open blocks the hand-off to `piv-review-changes`.
