---
name: piv-open-pr
description: Opens the pull request for the finished branch and hands the URL to a human reviewer.
argument-hint: "[base branch] · [ticket id] (blank = the project's base branch, with the id read off the branch name)"
disable-model-invocation: true
---

# Open PR: Open the Pull Request, Hand Off for Review

This closes the **verify** step of the PIV loop `docs/piv-loop.md` describes: the implementation is committed on a feature branch, and the PR hands it to a human reviewer.

"PR" below means the review request of the tool the repo already uses — a pull request on GitHub, a merge request on GitLab, a branch marked ready for review elsewhere. Drive it through that tool's CLI or API.

Copy this checklist into your task list. Tick an item only when its step's **Done when** holds.

- [ ] 1. Resolve the base branch
- [ ] 2. Check the branch is in a shippable state
- [ ] 3. Gather the material and write the body
- [ ] 4. Publish the branch
- [ ] 5. Open the PR

## Success criteria

- ✅ The PR title follows the form `docs/git-conventions.md` defines.
- ✅ The PR is a draft or ready for review as Step 5's rule decides.
- ✅ The body carries the implementation report's *Deviations from the ticket* and *Problems encountered*, every finding the review report left standing, and the fix report's items flagged for a manual check — or says which of the implementation and review reports was unavailable. A missing fix report goes unmentioned.
- ✅ The reports themselves stay local: the body is their distillation, and nothing is attached or embedded.
- ✅ The body's header block carries the ticket's `Intent-slug`, `Intent` and `Architecture`, copied verbatim from the ticket as read on the tracker.
- ✅ The mark `docs/issue-tracker.md` assigns to this step is on the ticket.

## Process

### Step 1 — Resolve the base branch

`$ARGUMENTS` may carry a base branch, a ticket id, or both — tell them apart by shape, using the id form `docs/issue-tracker.md` defines. No base branch handed to you → resolve it the way `docs/git-conventions.md` defines. Call the result `<base>`, and fetch it: the commits "ahead of `<base>`" below are counted from its remote tip, as `docs/git-conventions.md` defines it. A fetch that fails → **STOP** and say so. A ticket id handed to you overrides any the branch name or the commit subjects carry.

**Done when** `<base>` is resolved, and any ticket id handed to you is told apart from it.

### Step 2 — Check the branch is in a shippable state

Check which branch is checked out, whether the working tree is clean, which commits sit ahead of `<base>`, whether the PR tool's CLI is installed and authenticated, and whether a PR is already open for this branch. Act on the first condition below that holds.

- **Checked out on `<base>`** → **STOP**: "The base branch doesn't become a PR — put the ticket on its own branch, or review your own diff when this project commits on the base branch by design."
- **Uncommitted changes — staged, unstaged or untracked** → **STOP**: "Commit (or stash) before opening the PR." The loop's own artifacts — the paths `docs/issue-tracker.md` lists under *Paths* — don't count.
- **No commits ahead of `<base>`** → **STOP**: "Nothing to PR."
- **The PR tool's CLI missing or not authenticated** → **STOP**: say which, and the command that installs or authenticates it.
- **A PR already open for this branch** → **STOP** and print its URL.
- **None of the above** → proceed.

**Done when** the last condition holds.

### Step 3 — Gather the material and write the body

**Ticket id.** When Step 1 handed you none, take it from the branch name, in the form `docs/git-conventions.md` defines; with none there, from the subjects of the commits ahead of `<base>`, where `docs/git-conventions.md` places it. Commit bodies are not a source. Ids that disagree — the branch name against a subject, or one subject against another → ask the user which one this PR closes. **GATE.** No id in any of them → ask the user for it. **GATE.**

**Ticket.** Read it where `docs/issue-tracker.md` says tickets live. Missing, or the tracker unreachable → **STOP** and say which. Take its `Intent-slug`, `Intent`, `Architecture` and `Language`. The ticket is the source for these fields even when a report carries them: a report's header is only a copy, and the ticket holds the published value.

**Implementation report**, at the path `docs/issue-tracker.md` defines, named from the ticket id. Take its status, *Summary*, *Validation results*, *Deviations from the ticket* and *Problems encountered*.

**Review report**, at the review report path `docs/issue-tracker.md` defines. Take its verdict and every finding it left standing. On a PASS those are its medium and low findings — normal on a PASS, and the body is the only place the human reviewer meets them. When the commit went ahead on a verdict that was not PASS, its blocking, critical and high findings stand too, and the human reviewer has to see what is still open. Carry each finding as its severity, its one-line claim and its `file:line` — never its evidence, impact or fix: a reviewer who reads the first reviewer's reasoning inherits that framing instead of reading the code.

**Fix report**, at the fix report path `docs/issue-tracker.md` defines. Take its *Checks run* and every *Needs a human look* item it still holds unresolved; the body lists those as flagged, never as checked. Leave its deferrals out: they live on the tracker as tickets linked to the ticket, and *Linked* points there rather than listing a subset. No fix report is the normal case when the first review passed: the body doesn't call it unavailable.

**Validation results.** Take them from the fix report's *Checks run*; with no fix report, from the implementation report's *Validation results*; with neither, run the project's checks now and use what they report.

**Write the body.** When the repo ships a PR template, fill it, and append the header block, *Notes for the reviewer*, *Open problems* and *Linked* from `templates/pr-body.md` for each one it has no matching section for. Otherwise fill `templates/pr-body.md` section by section, keeping its structure exactly; each placeholder says what goes there.

Write the PR body in the intent's language — the ticket's `Language`, or with no such field the language its body is written in; template labels stay as written.

**Done when** every section of the body is filled, or says which report was unavailable.

### Step 4 — Publish the branch

Push it to the remote, tracking it. A rejected push → **STOP** and report git's message; never force-push, because the remote branch may hold commits this branch lacks.

**Done when** the remote branch tracks the local one and holds every commit ahead of `<base>`.

### Step 5 — Open the PR

Open it against `<base>`, titled in the form `docs/git-conventions.md` gives PR titles. When the commits carry different tags, the title takes the largest effect among them, as `docs/git-conventions.md` rules for a commit.

Open it as a draft or ready for review by the first condition below that holds:

- **Implementation report status `PARTIAL`, a fix report, and a PASS review report whose *Round* is above that fix report's** → ready for review. The PARTIAL went through a fix round and a fresh review, but a PASS proves only that no blocking, critical or high finding survived — the review runs no build, for one. Mark each problem under *Open problems* "reported by the implementation before the PASS review", never as resolved.
- **Implementation report status `PARTIAL`** → draft. The body's closing line says it waits on the open problems it lists.
- **Any other status, or no implementation report** → ready for review.

**Then close the ticket's loop**: do what the **Ticket status** section of `docs/issue-tracker.md` assigns to this step, and nothing beyond it.

**Done when** the PR is open against `<base>` in the state above and the ticket carries the mark.

## Output — report the PR

Report the PR number and URL, the base ← head branches, and **"Ready for review → a human approves and merges."** — or, for a draft, **"Draft → waiting on the open problems it lists."**

The PR body's free text — the summary, the Validation and the open problems — stays in the intent's language, as written above; only the template's labels stay as written.

## Hand off

Next: a human reviews, approves and merges. The agent's loop ends at the merge.
