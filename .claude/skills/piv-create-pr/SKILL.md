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

`$ARGUMENTS` may carry a base branch, a ticket id, or both — tell them apart by shape, in the id form `docs/ISSUE-TRACKER.md` defines. No base branch handed to you → resolve it the way `docs/GIT-CONVENTIONS.md` defines. Call the result `{base}`. A ticket id handed to you overrides the one the branch name carries.

### Step 2 — Check the branch is in a shippable state

Check which branch is checked out, whether the working tree is clean, which commits sit ahead of `{base}`, and whether a review request is already open for this branch. Act on the first condition below that holds.

- **Checked out on `{base}`** → **STOP**: "The base branch doesn't become a PR — put the ticket on its own branch, or review your own diff when this project commits on the base branch by design."
- **Uncommitted changes in the tree** → **STOP**: "Commit (or stash) before opening the PR."
- **No commits ahead of `{base}`** → **STOP**: "Nothing to PR."
- **A review request already open for this branch** → **STOP** and print its URL.
- **Clean tree, commits ahead, nothing open yet** → proceed.

### Step 3 — Gather the material for the body

The commit subjects since `{base}`, the diff statistics of the files they touch, and — when step 1 wasn't handed one — the linked ticket or issue id wherever it shows up: branch name, commit subjects, commit bodies.

**Then read the ticket's header block** and carry its `Intent-slug`, `Intent` and `Architecture` straight into the PR body's own, so the PR resolves back to the plans it came from without a reviewer opening the ticket first. No ticket → take them from the implementation report's header instead, and write "none" for whatever neither carries. Then look for the implementation report at the implementation report path `docs/ISSUE-TRACKER.md` defines. When it is there, take its status, its summary, its validation results, its **documented deviations**, and its *Issues encountered*. The deviations tell the reviewer what was intentional and the issues tell them what is still open, so both belong in the body.

**Then look for the review report** at the review report path the same file defines, and take its verdict and the medium and low findings that survived it. Those are the reviewer's notes the review had nowhere else to send: a PASS with medium and low findings is normal, and the body is where the human reviewer meets them. When the repo ships a pull request template, fill that template instead of the default below.

### Step 4 — Publish the branch

Push it to the remote, tracking it so later pushes need no arguments.

### Step 5 — Open the review request

Open it against `{base}`, titled `<tag>: <concise description> (<ticket id>)` when an id was found in step 3 — the same shape `docs/GIT-CONVENTIONS.md` gives the commit subjects.

- **Report status `PARTIAL`** → open it as a draft, and say in the body that the draft is waiting on the issues it lists.
- **No report found** → open it ready for review, fill *Validation* from a fresh run of the project's checks, and say in the body that no implementation report was available.

**Then close the ticket's loop**: do what the **Ticket status** section of `docs/ISSUE-TRACKER.md` assigns to this step, and nothing beyond it. That section names one owner per transition precisely so this skill doesn't have to know which tracker it is talking to.

Done when a review request is open for the branch and its URL is reported.

## Default body

Fill each section of the template at `templates/pr-body.md` from the material gathered in step 3.

## Output

Report the PR number and URL, the base ← head branches, and **"Ready for review → a human approves and merges."**

## Hand off

Next: a human reviews, approves and merges. The agent's loop ends at the merge.

## Success criteria

- ✅ The PR title follows `<tag>: <concise description> (<ticket id>)` whenever an id was found.
- ✅ The PR is a draft when the implementation report's status is `PARTIAL`, and ready for review otherwise.
- ✅ The body carries the implementation report's documented deviations and open issues, and the review report's surviving medium and low findings — or says which report was unavailable.
- ✅ Whenever a ticket was found, the mark `docs/ISSUE-TRACKER.md` assigns to this step is on it.
- ✅ The body's header block carries the `Intent-slug`, `Intent` and `Architecture` the ticket carried.
