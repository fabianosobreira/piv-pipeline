---
name: piv-fix-findings
description: Triages the findings of a review report, fixes the ones you choose one at a time with tests, defers the rest as tickets, then validates and writes a fix report.
argument-hint: "[review report path] (blank = the review written for this branch)"
disable-model-invocation: true
---

# Fix Findings: Triage, Fix, Validate

This continues the **verify** step of the PIV loop `docs/PIV-LOOP.md` describes: the review raised findings, and this run settles every one of them — the loop only closes when the fresh review this hands back to returns PASS.

A review produced findings — but a review is **input, not a work order.** You decide what happens to each one.

`$ARGUMENTS` carries the review report's path. **Read it end to end first**, so you understand every finding before triaging — the report is what you work from, and its findings arrive with the evidence and the severity that make each one actionable.

**No path handed to you** — go find the report written for this branch, where `docs/ISSUE-TRACKER.md` says review reports live. With a ticket id on the branch name, in the form `docs/GIT-CONVENTIONS.md` gives it, the report's name follows from the id. With no id, the branch's `<short-slug>` is not reliably the report's `intent-slug`: scan the review reports and compare each one's **Branch** header against the branch you are on. One match → that is the report. More than one → ask the user which one covers this branch. **GATE.** Not found → **STOP** and ask the user for the report to work from; until a report exists there is nothing to triage.

Take the ticket id and the `intent-slug` from the review report's header. They are what the fix report is named for, so the two reports sit side by side.

**A fix report already at that path, still pending** — its `Review` header names this review report, the review report has not been rewritten since, and it holds a deferral marked not created or a fix marked not fixed — means an earlier run stopped midway after the user ruled. Resume from it: the ruling stands, so skip Step 1 and its GATE, create only the deferrals not yet created, fix only the findings not yet fixed, then carry on to Step 4. A fix report with nothing pending, or older than the review report, belongs to a finished round: triage from scratch.

## Process

### Step 1 — Triage

Sort the findings before touching code. The review's severities are the default cut you propose: critical and high in *fix now*, medium and low in *defer*. Low goes to *defer* too, not to *noise*: a deferral is the only thing that closes a finding for the next review, so a low dropped without one comes back every round. Four buckets:

- **Fix now** — real, in-scope, belongs with this change.
- **Defer** — real but later; don't bloat this change. Each one becomes a ticket in Step 2; propose its title — imperative and specific, as `piv-create-tickets` titles its tickets — and its type here, and its group too when no ticket is behind the review.
- **Needs a human look / manual test** — anything the user should inspect or test by hand before trusting it. Flag it, don't silently auto-fix.
- **Noise / won't-fix** — say why, then drop it. The next review weighs that reason against the code, so make it one the code can bear out: a reason that shows the problem is not there keeps the finding from coming back; "not worth fixing" does not.

Every finding lands in exactly one bucket. Don't let the reviewer dictate scope — "real, but later" is a valid and common call; a clean small change beats a sprawling one.

**GATE** — post the split, each deferral with the title and type its ticket will carry — and its group, when no ticket is behind the review — and wait for the user's ruling. No code moves and no ticket is created until they rule.

**Once they rule, write the fix report** at the fix report path `docs/ISSUE-TRACKER.md` defines, filling the template at `templates/fix-report.md` with the split, and keep it current through the steps below — each deferral's ticket ref as it is created, each fix as it goes green. A run that stops midway — a tracker that can't be reached, a label that can't be created — still leaves the ruling on record, with each deferral not yet created and each fix not yet made marked as such. Running this skill again once the cause is cleared resumes from that record.

### Step 2 — Open a ticket for each deferral

A deferral is a ticket: create it by the rules `docs/ISSUE-TRACKER.md` gives under *Creating a ticket* — the same rules `piv-create-tickets` follows — so it lands in the backlog typed, grouped and linked like every other ticket, and `piv-implement-ticket` can pick it up cold. Fill the template at `templates/deferral.md`, taking the claim, impact, evidence, location and fix from the finding in the review report. Its *Origin* and *Evidence* are the deferral's per-ticket context. The review report stays local and the next review overwrites it, so a run picking the deferral up cold may never see it: the evidence and the location are what that run reads first, and the *Origin* `Review` path is only the key the next review finds the deferral by.

With a ticket behind the review, read that ticket where `docs/ISSUE-TRACKER.md` says tickets live — it is where the deferral's epic, group and header block come from. When it can't be read — missing, or the system unreachable — **STOP** and say which it was; a group or header block filled from a guess files the deferral where no filter finds it.

- **Type** — as `docs/ISSUE-TRACKER.md` defines the types under *Creating a ticket*: `bug` when the finding is behavior that diverges from what was specified or delivered (logic, security); `task` otherwise (performance, quality, standards, coverage). A deferral never delivers a new capability, so it is never a `feature`.
- **Group** — the reviewed ticket's group, copied: the deferral comes out of the same work.
- **Epic and header block** — the reviewed ticket's epic as its parent, and its `Intent-slug`, `Intent` and `Architecture` copied verbatim.
- **Link** — linked to the reviewed ticket, the way *Creating a ticket* says a deferral is. That link is what lets the next review find the deferral once this fix report is overwritten, and what the PR body points at.
- **Depends on** — the reviewed ticket: the code the finding names only exists once that ticket lands.

**No ticket behind the review** — there is no epic, group or ticket to copy or link. Take the group the user ruled on at the GATE; copy `Intent-slug`, `Intent` and `Architecture` from the implementation report `docs/ISSUE-TRACKER.md` names for this intent, or, with no implementation report, take the `Intent-slug` from the review report's header and write "none" for the other two. Create the deferral with no parent, no link, and "none" under *Depends on*. Its *Origin* `Review` line, copied verbatim, is then the only thing the next review finds it by, so never shorten or reword that path.

Leave the epic's body as it is — its *Tickets* list and its dependency graph alike: `piv-create-tickets` owns both, the deferral reaches the epic through the epic link *Creating a ticket* gives it, and a deferral blocks nothing — it only depends on the reviewed ticket.

Record each created ticket's ref against its finding in the fix report. A deferral with nothing to point at is not a deferral: the next review raises the finding again.

### Step 3 — Fix the *fix now* set, one at a time

For each finding, in severity order:

1. Explain what was wrong.
2. Make the fix.
3. Prove it. A finding Step 2 would type `bug` — logic, security — gets a test that fails without the fix and passes with it. Any other gets the check that shows its claim no longer holds: the lint or type-check rule it broke, or, for a coverage finding, the test it asked for.
4. Run that proof. The finding goes **green** when it passes, and a red finding gets fixed before the next one starts.

Fix what the finding names and stop there. A repair that grows into a refactor becomes its own ticket.

### Step 4 — Validate

Run the project's own checks — the test, lint, type-check, and build commands the repo exposes. When a check goes red: fix the cause, re-run, and continue once it is green.

When a failure survives a few honest attempts, or its cause sits outside what the findings ask you to change, stop working it: record the check, the failure, and what you tried in the fix report's *Checks run*. The re-review runs the checks again and raises whatever is still red.

## Output — finish the fix report

Finish the fix report started in Step 1 — every bucket settled, *Checks run* filled from Step 4 — and print the summary. The triage is a human decision, and a decision that exists only in the conversation is gone by the next run: this file is what tells the re-review what was already settled.

## Hand off

Confirm the fix report's path and each deferral ticket's ref, then offer the next move and let the user run it — this skill does not chain into the next one:

- Run `piv-review-changes` again over the branch, in a session of its own. It reads the deferral tickets this run opened, so what was deferred on the record stays closed and only what is genuinely still open comes back. Hand it the ticket id when there is one, and tell the user to clear every *Needs a human look* item by hand before starting it: the next fix run overwrites this report, and an item still open by then drops off the record.

## Success criteria

- ✅ Every finding in the review report landed in exactly one bucket, and the user ruled on the split.
- ✅ Every *fix now* finding has its Step 3 proof — a test that fails without the fix for a `bug`-type finding, the check that shows the claim gone for any other.
- ✅ Every deferred finding has a ticket created by the tracker doc's *Creating a ticket* rules, and its ref in the fix report.
- ✅ The project's checks are green, or each one still red is recorded in the fix report's *Checks run*.
- ✅ The triage outcome was written to the fix report path, not only printed.
- ✅ The run ended by handing the branch back to `piv-review-changes`, which is the only thing that closes the loop.
