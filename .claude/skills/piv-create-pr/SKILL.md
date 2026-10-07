---
name: piv-create-pr
description: Opens the pull request for the finished branch and hands the URL to a human reviewer.
argument-hint: "[base branch] · [ticket id] (blank = the project's base branch, with the id read off the branch name)"
disable-model-invocation: true
---

# Create PR: Open the Pull Request, Hand Off for Review

This closes the **verify** step of the PIV loop `docs/PIV-LOOP.md` describes: the implementation is committed on a feature branch, and the review request hands it to a human reviewer.

The motion is the same wherever the team works — a pull request on GitHub, a merge request on GitLab, marking a branch ready for review elsewhere. Use whatever tooling the repo already uses, and read "PR" below as that tool's review request.

## Process

### Step 1 — Resolve the base branch

`$ARGUMENTS` may carry a base branch, a ticket id, or both — tell them apart by shape, in the id form `docs/ISSUE-TRACKER.md` defines. No base branch handed to you → resolve it the way `docs/GIT-CONVENTIONS.md` defines. Call the result `<base>`. A ticket id handed to you overrides any the branch name or the commit subjects carry. **Done when** `<base>` is resolved, and any ticket id handed to you is told apart from it.

### Step 2 — Check the branch is in a shippable state

Check which branch is checked out, whether the working tree is clean, which commits sit ahead of `<base>`, and whether a review request is already open for this branch. Act on the first condition below that holds.

- **Checked out on `<base>`** → **STOP**: "The base branch doesn't become a PR — put the ticket on its own branch, or review your own diff when this project commits on the base branch by design."
- **Uncommitted changes in the tree** → **STOP**: "Commit (or stash) before opening the PR."
- **No commits ahead of `<base>`** → **STOP**: "Nothing to PR."
- **A review request already open for this branch** → **STOP** and print its URL.
- **Clean tree, commits ahead, nothing open yet** → proceed.

### Step 3 — Gather the material for the body

The commit subjects since `<base>` and, when Step 1 wasn't handed one, the ticket id. The branch name carries it, in the form `docs/GIT-CONVENTIONS.md` defines; with none there, the `(<ticket id>)` suffix of the commit subjects does. Commit bodies are not a source: a body that mentions another ticket would put that ticket's header block on this PR and close it at the merge. When the ids found disagree — the branch name against a subject, or one subject against another — ask the user which one this PR closes. **GATE.** No id in any of them → ask the user for it. **GATE.**

**Then find the reports** at the paths `docs/ISSUE-TRACKER.md` defines, named from the ticket id.

**Then read the ticket itself**, where `docs/ISSUE-TRACKER.md` says tickets live, and copy its `Intent-slug`, `Intent` and `Architecture` **verbatim** into the PR body's header block, so the PR resolves back to the plans it came from without a reviewer opening the ticket first. The ticket is the source for these three fields, ahead of any report: the implementation report's header is only a copy, and the ticket holds the published value. A ticket that can't be read — missing, or the system unreachable → **STOP** and say which it was; filling these fields from the report instead would hand the PR whatever copy the report carries. When the implementation report is there, take its status, its summary, its validation results, its **documented deviations**, and its *Problems encountered*. The deviations tell the reviewer what was intentional and the problems tell them what is still open, so both belong in the body.

**Then look for the review report** at the review report path the same file defines, and take its verdict — *Validation* carries it, or "no review report available" when there is none — and every finding that survived it. On a PASS those are the medium and low findings — the reviewer's notes the review had nowhere else to send: a PASS with medium and low findings is normal, and the body is where the human reviewer meets them. When the commit went ahead on a verdict that was not PASS, the blocking, critical and high findings behind it survived too, and the human reviewer has to see what is still open. Carry each one, blocking first and then by severity, as its severity, its one-line claim and its `file:line` — never its evidence, impact or fix. Those are the first reviewer's reasoning, and a reviewer who reads them inherits that framing instead of reading the code.

**Then look for the fix report** at the fix report path the same file defines, and take its *Needs a human look* items and its *Checks run*. Those checks ran after the last fixes, so they fill *Validation* ahead of the implementation report's validation results. The report holds only the latest round of triage, and that is all the body carries: the items of earlier rounds were cleared by hand before the review that followed them. List them as flagged, never as checked — the report records that the triage raised them, not that anyone tested them. Leave its deferrals out: they live on the tracker as tickets linked to the ticket, and the body points there rather than listing a subset. No fix report is the normal case when the first review passed: write "none" under *Flagged for a manual check*, and leave the fix report out of what the body calls unavailable.

The body is the reports' distillation: carry what they say into its sections and leave the files themselves local.

When the repo ships a pull request template, fill that template; otherwise fill each section of `templates/pr-body.md` from the material gathered here. **Done when** every section of the body is filled, or says which report was unavailable.

### Step 4 — Publish the branch

Push it to the remote, tracking it so later pushes need no arguments. **Done when** the remote branch tracks the local one and holds every commit ahead of `<base>`.

### Step 5 — Open the review request

Open it against `<base>`, titled `<tag>: <concise description> (<ticket id>)` — the same shape `docs/GIT-CONVENTIONS.md` gives the commit subjects.

- **Implementation report status `PARTIAL`** → open it as a draft, and say in the body that the draft is waiting on the problems it lists — unless a fix report is newer than the implementation report and the review report is PASS with a **Round** above that fix report's. Then the PARTIAL was worked through a fix round and a fresh review: open it ready for review, and mark each problem under *Open problems* as reported by the implementation before the PASS review, never as resolved. A PASS proves no blocking, critical or high finding survived, not that every problem was cleared — the review runs no build, for one.
- **No implementation report found** → open it ready for review, fill *Validation* from the fix report's *Checks run*, or from a fresh run of the project's checks when there is no fix report either, and say in the body that no implementation report was available.

**Then close the ticket's loop**: do what the **Ticket status** section of `docs/ISSUE-TRACKER.md` assigns to this step, and nothing beyond it. That section names one owner per transition precisely so this skill doesn't have to know which tracker it is talking to.

**Done when** a review request is open for the branch and its URL is reported.

## Output — report the review request

Report the PR number and URL, the base ← head branches, and **"Ready for review → a human approves and merges."** — or, for a draft, **"Draft → waiting on the open problems it lists."**

## Hand off

Next: a human reviews, approves and merges. The agent's loop ends at the merge.

## Success criteria

- ✅ The PR title follows `<tag>: <concise description> (<ticket id>)`.
- ✅ The PR is a draft when the implementation report's status is `PARTIAL`, unless a fix round followed it and a PASS review followed that fix round, and ready for review otherwise.
- ✅ The body carries the implementation report's documented deviations and open problems, every finding the review report left standing, and the fix report's items flagged for a manual check — or says which of the implementation and review reports was unavailable. A missing fix report goes unmentioned.
- ✅ The reports themselves stay local: the body is their distillation, and nothing is attached or embedded.
- ✅ The mark `docs/ISSUE-TRACKER.md` assigns to this step is on the ticket.
- ✅ The body's header block carries its `Intent-slug`, `Intent` and `Architecture`, copied verbatim from the ticket as read on the tracker.
