---
name: piv-fix-findings
description: Triages the findings of a review report, fixes the ones you choose one at a time with tests, defers and logs the rest, then validates and writes a fix report.
argument-hint: "[review report path] (blank = the review written for this branch)"
disable-model-invocation: true
---

# Fix Review Findings: Triage, Fix, Validate

This continues the **verify** step of the PIV loop `docs/PIV-LOOP.md` describes: the review raised findings, and this run settles every one of them — the loop only closes when the fresh review this hands back to returns PASS.

A review produced findings — but a review is **input, not a work order.** You decide what happens to each one.

`$ARGUMENTS` carries the review report's path. **Read it end to end first**, so you understand every finding before triaging — the report is what you work from, and its findings arrive with the evidence and the severity that make each one actionable.

**No path handed to you** — go find the report written for this branch, where `docs/ISSUE-TRACKER.md` says review reports live, named from the ticket id or from the branch name in the form `docs/GIT-CONVENTIONS.md` gives it. Not found → **STOP** and ask the user for the report to work from; until a report exists there is nothing to triage.

Take the ticket id and the `intent-slug` from the review report's header. They are what the fix report is named for, so the two reports sit side by side.

## Interaction mode: triage gating

**GATE** — put the split to the user and wait for their answer. No code moves until they rule.

## Process

### Step 1 — Triage

Sort the findings before touching code. The review's severities are the default cut you propose: critical and high in *fix now*, medium and low in *defer*. Four buckets:

- **Fix now** — real, in-scope, belongs with this change.
- **Defer** — real but later; don't bloat this change. **Create an issue** where `docs/ISSUE-TRACKER.md` says tickets live, and record its ref. A deferral with nothing to point at is not a deferral: the next review raises the finding again.
- **Needs a human look / manual test** — anything the user should inspect or test by hand before trusting it. Flag it, don't silently auto-fix.
- **Noise / won't-fix** — say why, then drop it.

Every finding lands in exactly one bucket. Don't let the reviewer dictate scope — "real, but later" is a valid and common call; a clean small change beats a sprawling one.

### Step 2 — Fix the *fix now* set, one at a time

For each finding, in severity order:

1. Explain what was wrong.
2. Make the fix.
3. Write a test that fails without the fix and passes with it.
4. Run that test. The finding goes **green** when it passes, and a red finding gets fixed before the next one starts.

Fix what the finding names and stop there. A repair that grows into a refactor becomes its own ticket.

### Step 3 — Validate

Run the project's own checks — the test, lint, type-check, and build commands the repo exposes. When a check goes red: fix the cause, re-run, and continue once it is green.

## Output — write a fix report

Write the report at the fix report path `docs/ISSUE-TRACKER.md` defines, filling the template at `templates/fix-report.md`, and print the summary. The triage is a human decision, and a decision that exists only in the conversation is gone by the next run: this file is what tells the re-review what was already settled.

## Hand off

Offer the next move and let the user run it — this skill does not chain into the next one:

- Next: `piv-review-changes` runs again over the branch, in a session of its own. It reads the tracker issues the deferrals opened, so what was deferred on the record stays closed and only what is genuinely still open comes back. Hand it the ticket id.
- With nothing left to fix and the verdict already PASS, next is `piv-commit-changes`.

## Success criteria

- ✅ Every finding in the review report landed in exactly one bucket, and the user ruled on the split.
- ✅ Every *fix now* finding has a test that fails without the fix.
- ✅ Every deferred finding has a tracker issue ref.
- ✅ The project's checks are green.
- ✅ The triage outcome was written to the fix report path, not only printed.
- ✅ The run ended by handing the branch back to `piv-review-changes`, which is the only thing that closes the loop.
