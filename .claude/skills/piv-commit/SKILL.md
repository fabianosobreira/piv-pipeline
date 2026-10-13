---
name: piv-commit
description: Commits the finished work as atomic, conventionally-tagged commits.
argument-hint: "[ticket id] (blank = taken from the branch name)"
disable-model-invocation: true
allowed-tools: Bash(sh *scripts/diff-hash.sh *)
---

# Commit: One Coherent Piece of Work per Commit

This is part of the **verify** step of the PIV loop `docs/piv-loop.md` describes: the change passed review, and this run turns it into a clean, atomic history before the PR opens.

Commit the work as **atomic** commits — each one a coherent piece of work its subject can name. Group it the way `docs/git-conventions.md` says — usually a single commit. Either way the run ends with a clean tree: everything uncommitted lands in a commit, or the user decides where it goes.

The loop's own artifacts — the paths `docs/issue-tracker.md` lists under *Paths* — are never committed and stay on disk. Every step below leaves them out: they are not inspected, grouped or staged, and the clean-tree check ignores them.

## Success criteria

- ✅ The latest review report's verdict was PASS, with no fix report matching its **Round** and the tree matching its **Diff** — or the user ruled to commit anyway.
- ✅ Every uncommitted change landed in a group, or the user decided where it goes.
- ✅ Every group is one coherent piece of work its subject can name.
- ✅ Every subject follows the form `docs/git-conventions.md` defines, with the tag the work earns.
- ✅ The working tree is clean at the end of the run.

## Process

### Step 1 — Check where you are

1. **Branch.** `docs/git-conventions.md` defines which branch is the base branch. Work belongs on its own branch: on the base branch, ask the user whether to commit on it anyway. **GATE.** No → end the run; moving the work to its branch is the user's call.
2. **Ticket id.** Take the one `$ARGUMENTS` carries, else the one the branch name carries, in the form `docs/git-conventions.md` defines. Neither carries one, or the two carry different ids → ask the user which. **GATE.**
3. **Review.** Check the change earned its commit:
   1. Find the review report at the path `docs/issue-tracker.md` defines, named from the ticket id. Read its **Verdict**, **Round**, **Base** and **Diff** and nothing else, then the **Round** of the fix report beside it, when there is one.
   2. Hash the change by running the bundled script — run it, don't read it. Pass the report's **Base** commit, then each exclude glob `docs/issue-tracker.md` lists under *Paths*, every argument single-quoted so the shell hands the globs over unexpanded:

      ```bash
      sh ${CLAUDE_SKILL_DIR}/scripts/diff-hash.sh '<Base>' '<glob>' '<glob>'
      ```

      It needs `git` and a POSIX shell, and prints one hash. A non-zero exit prints no hash: exit 2 names the cause and its fix (a **Base** missing here is fixed by fetching it) — apply the fix and rerun; when you can't, the check fails with the script's message as the reason.
   3. Any of these fails the check: the verdict is not PASS; there is no review report; the fix report's **Round** matches the review's (fixes nobody re-reviewed); the hash differs from the report's **Diff**, or the report records none, or the script gave no hash. Say which failed, and ask the user whether to commit anyway. **GATE.** No → end the run.

**Done when** the run is off the base branch or the user ruled to commit on it, the ticket id is resolved, and the review check passed or the user ruled to commit anyway.

### Step 2 — Inspect

List every uncommitted path, tracked and untracked, and read what changed in each: the diff against `HEAD` for a tracked file, the content for an untracked one.

**Done when** every uncommitted path is on the list Step 3 groups.

### Step 3 — Group it

Group the way `docs/git-conventions.md` says; the groups cover everything uncommitted, a change the ticket doesn't mention included. A path belongs to no group only when it earns no tag — scratch files, local leftovers — and it stays off this branch. List those paths and ask the user, per path, whether to stash it, move it to another branch, or drop it, before you commit anything. **GATE.** Carry out a stash (`git stash push -u -- <path>`) or a drop yourself; a move is the user's to make — wait until it's done.

**Done when** every path from Step 2 sits in exactly one group, or the user decided where it goes.

### Step 4 — Commit each group

Take one group at a time. Stage exactly its paths, by name — never `git add -A`, `git add .` or `git commit -a`, which sweep in the loop's artifacts — then commit it with a subject in the form `docs/git-conventions.md` defines, carrying the ticket id from Step 1.

Add a body after one blank line, hard-wrapped at 72 columns, when the group's diff does something the subject doesn't name: a second surface changed, a behavior removed, or a constraint the code alone doesn't reveal. Write the body from the group's staged diff; read neither the implementation report nor the fix report.

After the last commit, check the working tree status: any path left besides the loop's artifacts → back to Step 3 with it.

**Done when** every group is a commit whose subject follows that form, with a body wherever the rule above calls for one, and the working tree is clean.

## Output — the commit summary

3–6 sentences from the commits' diffs, printed for the user: what each commit changes and the key files it touches.

## Hand off

Confirm each commit by its short hash and subject. Committed on the base branch → no PR follows; say so and end here.

Otherwise offer the next move and let the user run it — this skill does not chain into the next one:

- **Open the PR** — run `piv-open-pr`, in this same session, handed the ticket id.
