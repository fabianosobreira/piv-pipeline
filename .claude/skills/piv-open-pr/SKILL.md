---
name: piv-open-pr
description: Opens the GitHub pull request for an intent whose tasks are all committed, closing its issue on merge, and hands the URL to a human reviewer.
argument-hint: "[#N | intent-slug] · [base branch] (blank = the issue on the branch name, and the project's base branch)"
disable-model-invocation: true
---

# Open PR: Open the Pull Request, Hand Off for Review

This closes the **verify** step of the PIV loop `docs/piv-loop.md` describes: every task of the intent is committed on its branch, and the PR hands the whole intent to a human reviewer. It is one of the two steps that write to GitHub, through `gh`. Write the PR body in the intent's language — the epic's `Language`; template labels stay as written.

## Success criteria

- ✅ Every task of the epic was `[x]` and every commit it lists is on the branch.
- ✅ The PR title follows the form `docs/git-conventions.md` defines, with the issue number.
- ✅ The body carries `Closes #N`, the epic's `Spec` line, and, per task, the implementation report's *Deviations from the ticket* and *Problems encountered*, the findings Step 2 carries from the review report, and the fix report's items flagged for a manual check — or says which report was unavailable. A missing fix report goes unmentioned.
- ✅ The body carries every deferral of the intent in full.
- ✅ The reports themselves stay local: the body is their distillation, and nothing is attached.
- ✅ The PR carries the user as assignee, and is a draft or ready for review as Step 5's rule decides.

## Process

### Step 1 — Resolve the intent and the base branch

`$ARGUMENTS` may carry an issue number or intent-slug, a base branch, or both — tell them apart by shape. Resolve the intent as `docs/piv-loop.md` says under *Resolving the intent and the task*, and read `.piv/[intent-slug]/epic.md`. No base branch handed to you → resolve it the way `docs/git-conventions.md` defines. Call the result `[base]`, and fetch it: the commits "ahead of `[base]`" below are counted from its remote tip, as `docs/git-conventions.md` defines it. A fetch that fails → **STOP** and say so.

**Done when** the epic is read and `[base]` is resolved and fetched.

### Step 2 — Check the branch is in a shippable state

Run `gh auth status`; check which branch is checked out, whether the working tree is clean, which commits sit ahead of `[base]`, and whether a PR is already open for this branch. Act on the first condition below that holds.

- **`gh` missing or not authenticated** → **STOP**: say which, and the command that fixes it — `gh auth login` for the second.
- **Not on the branch the epic names under `Branch`** → **STOP**, naming both.
- **A task of the epic is not `[x]`** → **STOP**, listing each one: every task is committed before the PR opens.
- **A hash the epic lists under `commits:` is not on the branch** — `git merge-base --is-ancestor [hash] HEAD` fails → **STOP**, listing each missing one.
- **Uncommitted changes — staged, unstaged or untracked** → **STOP**: "Commit (or stash) before opening the PR."
- **No commits ahead of `[base]`** → **STOP**: "Nothing to PR."
- **A PR already open for this branch** → **STOP** and print its URL.
- **None of the above** → proceed.

**Done when** the last condition holds.

### Step 3 — Gather the material and write the body

Read, for each task of the epic in its order, under `.piv/[intent-slug]/tasks/T-xx/`:

- **Implementation report**, `T-xx.report.md` — its status, *Summary*, *Validation results*, *Deviations from the ticket* and *Problems encountered*.
- **Review report**, `T-xx.review.md` — its verdict and the findings to carry. On a PASS there are none to carry: its *low* findings stay in the report. A finding the fix report of the review's *Round* settled elsewhere (same claim and `file:line`) is not listed here: one with a deferral in the body appears only as that deferral, one ruled *Noise / won't-fix* drops out, and one under *Needs a human look* appears only among the items flagged for a manual check. When the commit went ahead on a verdict that was not PASS, its test-fact findings, and its *introduced* and *aggravated* ones of severity critical, high or medium, are carried too. Carry each finding as its severity, its one-line claim and its `file:line` — never its evidence, impact or fix: a reviewer who reads the first reviewer's reasoning inherits that framing instead of reading the code.
- **Fix report**, `T-xx.fixes.md`, when there is one — its *Checks run* and every *Needs a human look* item it still holds unresolved; the body lists those as flagged, never as checked. No fix report is the normal case when the first review passed.
- **Validation results** — the fix report's *Checks run*; with no fix report, the implementation report's *Validation results*; with neither, run the project's checks now and use what they report.

Then read every file under `.piv/[intent-slug]/deferrals/`, whole.

**Write the body** in a file under `.piv/[intent-slug]/`. When the repo ships a PR template, fill it, and append from `${CLAUDE_SKILL_DIR}/templates/pr-body.md` the header block, the `Closes #[N]` line, and each section it has no match for. Otherwise fill `${CLAUDE_SKILL_DIR}/templates/pr-body.md` section by section, keeping its structure exactly; each placeholder says what goes there. `Closes #[N]` is the epic's issue number: the merge closes the issue through it, and no step closes it by hand.

**Done when** every section of the body is filled, or says which report was unavailable, and every deferral is in it.

### Step 4 — Publish the branch

Push it to the remote, tracking it. A rejected push → **STOP** and report git's message; never force-push, because the remote branch may hold commits this branch lacks.

**Done when** the remote branch tracks the local one and holds every commit ahead of `[base]`.

### Step 5 — Open the PR

Open it with `gh pr create` against `[base]`, with the body file from Step 3, and `@me` as assignee. Title it in the form `docs/git-conventions.md` gives PR titles, with the issue number; when the commits carry different tags, the title takes the largest effect among them.

Open it as a draft or ready for review by the first condition below that holds, over every task:

- **An implementation report status `PARTIAL`, with a fix report, and a PASS review report whose *Round* is above that fix report's** → ready for review. The PARTIAL went through a fix round and a fresh review, but a PASS proves only that no test-fact finding, and no *introduced* or *aggravated* one of severity critical, high or medium, survived — the review runs no build, for one. Mark each of its problems under *Open problems* "reported by the implementation before the PASS review", never as resolved.
- **Any other implementation report status `PARTIAL`** → draft. The body's closing line says it waits on the open problems it lists.
- **Otherwise** → ready for review.

**Done when** the PR is open against `[base]` in the state above, with its assignee.

## Output — report the PR

Report the PR number and URL, the base ← head branches, and **"Ready for review → a human approves and merges."** — or, for a draft, **"Draft → waiting on the open problems it lists."**

The PR body's free text — the summary, the validation and the open problems — stays in the intent's language, as written above; only the template's labels stay as written.

## Hand off

Offer the next move and let the user run it — this skill does not chain into the next one:

- **Audit the PR against the spec** — run `piv-review-pr [#N]`, in a session of its own.

After it, a human reviews, approves and merges. The agent's loop ends at the merge.
