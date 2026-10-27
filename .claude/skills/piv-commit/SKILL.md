---
name: piv-commit
description: Commits one reviewed task as atomic, conventionally-tagged commits and marks it done in the epic.
argument-hint: "[#N | intent-slug] [T-xx] (blank = the issue on the branch name, and the epic's task in progress)"
disable-model-invocation: true
allowed-tools: Bash(sh ${CLAUDE_SKILL_DIR}/scripts/diff-hash.sh *)
---

# Commit: One Coherent Piece of Work per Commit

This is part of the **verify** step of the PIV loop `docs/piv-loop.md` describes: one task passed review, and this run turns it into a clean, atomic history on the intent's branch, then marks the task done in the epic.

Commit the work as **atomic** commits — each one a coherent piece of work its subject can name. Group it the way `docs/git-conventions.md` says — usually a single commit per task. Either way the run ends with a clean tree: everything uncommitted lands in a commit, or the user decides where it goes. The loop's own artifacts live under `.piv/`, which git ignores, so no step below ever sees them.

## Success criteria

- ✅ The task's review report verdict was PASS and the tree still matches its **Diff hash** — or the user ruled to commit anyway.
- ✅ Every uncommitted change landed in a group, or the user decided where it goes.
- ✅ Every group is one coherent piece of work its subject can name.
- ✅ Every subject follows the form `docs/git-conventions.md` defines, with the tag the work earns and the issue number.
- ✅ The working tree is clean at the end of the run.
- ✅ The task reads `[x]` in the epic, with the short hash of every commit this run made.

## Process

Copy this checklist into your task list. Tick an item only when its step's **Done when** holds.

```
- [ ] Step 1 — Check where you are
- [ ] Step 2 — Inspect
- [ ] Step 3 — Group it
- [ ] Step 4 — Commit each group
- [ ] Step 5 — Mark the task done
```

### Step 1 — Check where you are

1. **Intent and task.** Resolve them from `$ARGUMENTS` as `docs/piv-loop.md` says under *Resolving the intent and the task*, from `.piv/[intent-slug]/epic.md`. The task is not `[~]` → **STOP**: only the task in progress is committed.
2. **Branch.** The checked-out branch must be the one the epic names under `Branch`. It isn't → **STOP**, naming both.
3. **Review.** Check the change earned its commit:
   1. Read the review report at `.piv/[intent-slug]/tasks/T-xx/T-xx.review.md`: its **Verdict**, **Base** and **Diff hash** and nothing else.
   2. Hash the change by running the bundled script — run it, don't read it — with the report's **Base** and nothing else:

      ```bash
      sh ${CLAUDE_SKILL_DIR}/scripts/diff-hash.sh '[Base]'
      ```

      It needs `git` and a POSIX shell, and prints one hash. A non-zero exit prints no hash: exit 2 names the cause and its fix — apply the fix and rerun; when you can't, the check fails with the script's message as the reason.
   3. Any of these fails the check: the verdict is not PASS; there is no review report; the hash differs from the report's **Diff hash**, or the report records none, or the script gave no hash; the **Base** is not `HEAD`. Say which failed, and ask the user whether to commit anyway. **GATE.** No → end the run.

**Done when** the task is `[~]`, the run sits on the intent's branch, and the review check passed or the user ruled to commit anyway.

### Step 2 — Inspect

List every uncommitted path, tracked and untracked, and read what changed in each: the diff against `HEAD` for a tracked file, the content for an untracked one.

**Done when** every uncommitted path is on the list Step 3 groups.

### Step 3 — Group it

Group the way `docs/git-conventions.md` says; the groups cover everything uncommitted, a change the ticket doesn't mention included. A path belongs to no group only when it earns no tag — scratch files, local leftovers — and it stays off this branch. List those paths and ask the user, per path, whether to stash it, move it to another branch, or drop it, before you commit anything. **GATE.** Carry out a stash (`git stash push -u -- [path]`) or a drop yourself; a move is the user's to make — wait until it's done.

**Done when** every path from Step 2 sits in exactly one group, or the user decided where it goes.

### Step 4 — Commit each group

Take one group at a time. Stage exactly its paths, by name — never `git add -A`, `git add .` or `git commit -a` — then commit it with a subject in the form `docs/git-conventions.md` defines, carrying the issue number from the epic's `Issue`.

Add a body after one blank line, hard-wrapped at 72 columns, when the group's diff does something the subject doesn't name: a second surface changed, a behavior removed, or a constraint the code alone doesn't reveal. Write the body from the group's staged diff; read neither the implementation report nor the fix report.

After the last commit, check the working tree status: any path left → back to Step 3 with it.

**Done when** every group is a commit whose subject follows that form, with a body wherever the rule above calls for one, and the working tree is clean.

### Step 5 — Mark the task done

In the epic, turn the task's line from `[~]` to `[x]` and append ` — commits: [short hashes]`, every commit this run made, oldest first, comma-separated.

**Done when** the task reads `[x]` with its commits.

## Output — the commit summary

3–6 sentences from the commits' diffs, printed for the user: what each commit changes and the key files it touches.

## Hand off

Confirm each commit by its short hash and subject, and the task as done in the epic. Then offer the next move and let the user run it — this skill does not chain into the next one:

- **A task is still `[ ]` in the epic** → run `piv-implement [#N]`, in a session of its own. It picks the next task.
- **Every task is `[x]`** → run `piv-open-pr [#N]`, in this same session.
