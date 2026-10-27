---
name: piv-review-pr
description: Audits an intent's open pull request against its spec, item by item, and writes a PR review with a CONFORMS or DIVERGES verdict.
argument-hint: "[#N | intent-slug] (blank = the issue on the branch name)"
disable-model-invocation: true
allowed-tools:
  - Bash(gh auth status)
  - Bash(gh pr view *)
  - Bash(gh pr diff *)
  - Bash(git hash-object *)
---

# Review PR: Hold the Shipped Change to the Spec

This is the last step of the PIV loop `docs/piv-loop.md` describes: the PR is open, and this run audits it against the spec the user confirmed — every requirement, constraint, design item and acceptance criterion, the non-goals and the *Never* boundary. It audits **conformance to the spec, not code quality**: `piv-review` already judged the code, task by task. It reads the PR with `gh` and writes nothing to GitHub — no comment, no label, no review — and edits no code. Its only output is `.piv/[intent-slug]/pr-review.md`, written in the epic's `Language`; template labels stay as written.

## Success criteria

- ✅ Every `FR`, `NFR`, `C`, `D` and `AC` of the spec has a row in *Coverage*, with `met`, `diverges` or `not verifiable` and its evidence.
- ✅ Every `met` and `diverges` cites a `path:line` of the PR's code that says what the row claims.
- ✅ Every change in the PR that no task of the spec asks for is a divergence, `Out of scope`.
- ✅ Every non-goal and *Never* line is marked respected or violated in *Boundaries*.
- ✅ The spec hash the PR body cites was compared with the spec's current hash.
- ✅ The verdict is **DIVERGES** when any row diverges or any boundary is violated, **CONFORMS** otherwise.

## Process

Copy this checklist into your task list. Tick an item only when its step's **Done when** holds.

```
- [ ] Step 1 — Resolve the intent and the PR
- [ ] Step 2 — Index the spec
- [ ] Step 3 — Read the PR end to end
- [ ] Step 4 — Hold every item to the PR
- [ ] Step 5 — Check the spec revision
- [ ] Step 6 — Write the PR review
```

### Step 1 — Resolve the intent and the PR

Resolve the intent as `docs/piv-loop.md` says under *Resolving the intent and the task*, and read `.piv/[intent-slug]/epic.md` and the spec its `Spec` line names.

Run `gh auth status`. It fails → post its message with the command that fixes it (`gh auth login`), and ask whether to fix it and rerun, or go on without the remote: the diff then comes from git, `git diff [base]...[the epic's Branch]` with the base `docs/git-conventions.md` defines, and the PR body goes unread. **GATE.** Going on → `Remote check: skipped by the user`.

With the remote, find the open PR whose head is the epic's `Branch`: `gh pr view [branch] --json number,url,title,body,state,headRefName,baseRefName`. No open PR → **STOP**: `piv-open-pr` opens it first.

**Done when** the epic, the spec and the PR — or, with the remote skipped, the branch diff — are in hand.

### Step 2 — Index the spec

List every `FR`, `NFR`, `C`, `D` and `AC` line of the spec, with its ID and its text; every non-goal of section 2; every *Never* line of section 10; and every task of section 8 with the files and surfaces it names.

**Done when** every item of those sections is on the list.

### Step 3 — Read the PR end to end

Read the whole diff — `gh pr diff [number]` — and, for each changed file, enough of the file on the branch to judge the change in context. Never sample: a PR too large to hold at once is read file by file, keeping a note per file of what it changes.

**Done when** every changed file is read, with a note of what it changes.

### Step 4 — Hold every item to the PR

For each item of Step 2, decide one status and record its evidence:

- **`met`** — the PR's code does what the item says. Cite the `path:line` that shows it; take the line number from `grep -n` on the file, never counted by hand.
- **`diverges`** — the PR does something else, or does nothing, where the item asks for something. Cite the `path:line`, or the place the item's code should be.
- **`not verifiable`** — the item cannot be judged from the code — a latency budget, a behavior only a running system shows. Say what would verify it.

Then hunt the reverse: every change in the PR that no task of section 8 asks for, and every change inside a non-goal or a *Never* line. Each is a divergence; one outside every task is `Out of scope`.

Give every divergence a severity: **critical** — a *Never* line violated, or data loss or a security defect; **high** — an `FR` or `AC` unmet; **medium** — an `NFR`, `C` or `D` departed from, or an out-of-scope change of behavior; **low** — an out-of-scope change that alters no behavior.

**Done when** every item has a status and evidence, and every change of the PR is either asked for by a task or recorded as a divergence.

### Step 5 — Check the spec revision

Take the hash after `@` in the PR body's `Spec` line, and the spec's current hash, `git hash-object --no-filters [spec path]`. They differ → the spec changed after the PR was opened, and the PR was built from another revision: record it under *Spec revision*. A body with no `Spec` line, or the remote skipped → record `none`.

**Done when** both hashes, or `none`, are recorded.

### Step 6 — Write the PR review

Write `.piv/[intent-slug]/pr-review.md` from [${CLAUDE_SKILL_DIR}/templates/pr-review.md](${CLAUDE_SKILL_DIR}/templates/pr-review.md), used exactly: every heading, in the template's order. Copy each divergent item's spec line verbatim. Set the verdict as **Success criteria** says. Then reopen every cited line and confirm it says what its row or divergence claims; a citation that does not → correct it, and check again.

Print the verdict and the count of divergences per severity.

**Done when** the file exists with every section filled, and every cited line was reopened.

## Hand off

Confirm where `pr-review.md` landed, by path, with the PR's number and URL, then offer the next moves and let the user run them:

- **CONFORMS** → a human reviews, approves and merges the PR.
- **DIVERGES** → the user decides, per divergence: fix it by hand on the branch; or plan it as new work — `piv-spec`, `piv-review-spec` and `piv-slice` for a new intent; or accept it and merge. `piv-fix` does not apply here: it triages a task's review, not the PR. The issue stays as published; nothing syncs it.
