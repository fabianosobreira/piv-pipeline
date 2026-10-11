---
name: piv-setup
description: Installs the docs the PIV loop's skills read into the project's docs/ folder, folding the project's own git rules into docs/git-conventions.md.
argument-hint: "[github | gitlab | jira | md] (blank = suggested from the git remote)"
disable-model-invocation: true
---

# Setup: Install the Docs the PIV Loop Reads

The loop's skills read five files under `docs/`: `piv-loop.md`, `issue-tracker.md`, `git-conventions.md`, and the `.gitignore` that keeps the loop's artifacts out of git. This run installs them from `${CLAUDE_SKILL_DIR}/assets/` into the project. It sets the loop up; it is not a step of it, and it hands off with the setup ready to commit.

The project's own rules win. Where its harness already says how to branch and commit, `docs/git-conventions.md` carries that rule, and the shipped asset fills only what the harness leaves unsaid.

Re-running it on a project already set up changes nothing the user didn't rule on.

## Success criteria

- ✅ `docs/piv-loop.md` matches the asset.
- ✅ `docs/issue-tracker.md` is the chosen tracker's doc with its setup placeholders filled, or the existing file the user ruled to keep.
- ✅ `docs/.gitignore` ignores every path the asset lists, unless another `.gitignore` already does.
- ✅ `docs/git-conventions.md` meets every requirement under *What the skills need from git-conventions.md*, follows every harness rule, and says where each harness rule came from.
- ✅ The user saw the commit message and ruled on the commit.

Write the docs in English, whatever language the harness is in: the skills find their sections by the asset's labels. Talk to the user in the language they write in.

## What the skills need from git-conventions.md

**Required** — without these the loop breaks:

- **Base branch** — how to resolve it. `piv-implement`, `piv-review`, `piv-commit` and `piv-open-pr` all start from it.
- **Commit subject form** — the shape `piv-commit` writes, including where the ticket id goes, if anywhere.
- **PR title form** — the shape `piv-open-pr` writes.
- **Commit tags** — the set of tags, and the rule for a change that mixes effects: one commit per effect, and the largest effect names the tag when it can't be split. `piv-commit` groups by it and `piv-open-pr` titles by it.

**Recommended** — without these the loop runs, with a GATE in every run:

- **Ticket id in the branch name**, in a form that reads back to the tracker's id. Without it `piv-review`, `piv-fix`, `piv-commit` and `piv-open-pr` ask the user for the id each run.
- **Ticket id in the commit subject.** Without it `piv-open-pr` has only the branch name to find the id in.

## Where the harness keeps git rules

Look in the project, never above it:

- **Agent instructions** — every `CLAUDE.md` and `AGENTS.md` in the repo, `.claude/rules/**`, `.cursor/rules/**`, `.github/copilot-instructions.md`.
- **Enforcement tooling** — commitlint config (`commitlint.config.*`, `.commitlintrc*`, the `commitlint` key of `package.json`), a commit template (`.gitmessage`, `git config commit.template`), and commit hooks (`.husky/`, `lefthook.yml`, `.pre-commit-config.yaml`). Tooling outranks prose: it rejects the commit.

Documents written for people — `CONTRIBUTING.md`, the README — are not harness and are never read for rules.

Read `~/.claude/CLAUDE.md` too, only to warn the user when it conflicts with the draft; it is one person's rule, never the project's, and nothing from it enters the file.

## Process

### Step 1 — Investigate

Gather, without writing anything:

- **The tracker.** `$ARGUMENTS` may name one of `github`, `gitlab`, `jira`, `md`. Otherwise suggest one from the remote's host: `github.com` → `github`, a GitLab host → `gitlab`; with no match, suggest none.
- **The existing docs.** For each of `docs/piv-loop.md`, `docs/issue-tracker.md`, `docs/.gitignore` and `docs/git-conventions.md`: absent, identical to its asset, or different. For an existing `docs/issue-tracker.md`, which tracker its *Where tickets live* describes.
- **The ignore lines.** Each line of the `.gitignore` asset that no `.gitignore` in the repo already covers — check with `git check-ignore` on a sample path under it.
- **The harness rules.** Every git rule the places under *Where the harness keeps git rules* state, with its file.

**Done when** each of the four docs is classified, the tracker is named or left unsuggested, and every harness file listed above was read or found absent.

### Step 2 — Draft git-conventions.md

Start from the existing `docs/git-conventions.md`, or from `${CLAUDE_SKILL_DIR}/assets/git-conventions.md` when there is none. Then lay the harness rules over it, in this order of precedence: enforcement tooling, then agent instructions, then the starting file. Where the harness says nothing, the starting file stands.

Write each harness rule under the asset's section that owns it, in English, and close it with its origin in parentheses — `(from CLAUDE.md)`. A harness rule no section owns goes under a section of its own, after *Commit tags*.

Then check the draft against *What the skills need from git-conventions.md*. A required item the harness contradicts is a conflict the user rules on. A recommended item the harness contradicts follows the harness; note which GATE every run will then hit.

**Done when** the draft names every requirement or lists it as a conflict, and every harness rule from Step 1 sits in it.

### Step 3 — Post the plan

Post one message with everything the user rules on, then **GATE**:

- **Tracker** — the suggested one, or the question of which. For `jira`, ask for the project key that replaces `<KEY>`. That is the only setup placeholder: every other `<...>` in a tracker doc is a form the loop fills at run time, and stays.
- **`docs/issue-tracker.md`** — when one exists, which tracker it describes, and whether to **keep** it or **replace** it with the chosen one.
- **`docs/piv-loop.md`** — copied, skipped as identical, or overwritten because it differs. The loop owns this file.
- **`docs/.gitignore`** — created, or the lines to append, and any line skipped as already covered.
- **`docs/git-conventions.md`** — the draft, with each conflict and how the draft resolved it, each required item the harness contradicts, each recurring GATE a recommended item will cause, and each conflict with `~/.claude/CLAUDE.md`. Say when an existing file already meets every requirement and conflicts with nothing: it stays untouched.
- **Centralize** — only when agent instructions hold git rules: offer to move them into `docs/git-conventions.md`, leaving a pointer behind. Name each file that would change.

When the user picks another tracker than the one asked about and it has setup placeholders, ask for them. **GATE.** **Done when** the user ruled on every item the message raised.

### Step 4 — Install

Act on the rulings, and touch nothing else:

- Copy `${CLAUDE_SKILL_DIR}/assets/piv-loop.md` to `docs/piv-loop.md` unless it is identical.
- Copy `${CLAUDE_SKILL_DIR}/assets/issue-tracker-<tracker>.md` to `docs/issue-tracker.md`, unless the user kept the existing one, and fill its setup placeholders.
- Copy `${CLAUDE_SKILL_DIR}/assets/.gitignore` to `docs/.gitignore` when there is none; otherwise append only the missing lines, leaving the rest of the file as it is.
- Write `docs/git-conventions.md` from the draft as ruled, unless it stays untouched.
- **Centralizing** — in each agent instructions file that held git rules, replace the rules with one line: "Git conventions — base branch, branch names, commit subjects, PR titles and tags — live in `docs/git-conventions.md`; read it before creating a branch, committing or opening a PR." A rules file left with nothing else is deleted, and the line goes into `CLAUDE.md` instead — or into `AGENTS.md` when that is the file the repo's `CLAUDE.md` defers to. Tooling stays as it is.

Then re-read `docs/git-conventions.md` against *What the skills need from git-conventions.md* and against the harness rules; fix what misses, and check again. **Done when** every success criterion above but the last holds.

### Step 5 — Offer the commit

List each file created, changed, deleted, skipped or kept, and each recurring GATE from Step 3.

Then write the commit message for exactly those files, in the form the `docs/git-conventions.md` just written defines. The setup has no ticket: the subject carries no id. When that form demands one, ask the user for it.

Check out where the commit would land. On the base branch, while `docs/git-conventions.md` puts work on its own branch, say so and offer to create a branch first.

Post the message and ask whether to commit. **GATE.** Commit only what the user approved, on the branch they chose. **Done when** the commit exists, or the user declined it.

## Hand off

Confirm the commit by its short hash and subject, or say the setup is left uncommitted. The loop is ready to run; the user picks where to start it.
