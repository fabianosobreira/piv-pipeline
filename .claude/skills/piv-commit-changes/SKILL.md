---
name: piv-commit-changes
description: Commits the finished work as atomic, conventionally-tagged commits.
argument-hint: "[ticket id] (blank = taken from the branch name)"
disable-model-invocation: true
allowed-tools: Bash(sh *scripts/diff-hash.sh *)
---

# Commit Changes: One Coherent Piece of Work per Commit

This is part of the **verify** step of the PIV loop `docs/PIV-LOOP.md` describes: the change passed review, and this run turns it into a clean, atomic history before the PR opens.

Commit the work as **atomic** commits — each one a coherent piece of work its subject line can name. Split by effect, the way `docs/GIT-CONVENTIONS.md` says — usually a single commit. Either way the run ends with a clean tree: everything uncommitted lands in a commit, or the user decides where it goes.

The loop's own artifacts — the paths `docs/ISSUE-TRACKER.md` lists under *Paths* — are never committed and stay on disk; the clean-tree check ignores them.

Copy this checklist into your task list. Tick an item only when its step's completion criterion holds.

- [ ] 1. Check where you are
- [ ] 2. Inspect
- [ ] 3. Group it
- [ ] 4. Commit each group

## Success criteria

- ✅ The latest review report's verdict was PASS, with no fix report matching its **Round** and the tree matching its **Diff** — or the user ruled to commit anyway.
- ✅ Every uncommitted change landed in a group, or the user decided where it goes.
- ✅ Every group is one coherent piece of work its subject can name.
- ✅ Every subject follows `<tag>: <atomic description> (<ticket id>)`, with the tag the work earns.
- ✅ The working tree is clean at the end of the run, the loop's artifacts aside.

## Process

### Step 1 — Check where you are

`docs/GIT-CONVENTIONS.md` defines which branch is the base branch. Work belongs on its own branch: when you are on the base branch, ask the user before committing anything. **GATE.**

**Then resolve the ticket id** — the one `$ARGUMENTS` carries, or the one the branch name carries, in the form `docs/GIT-CONVENTIONS.md` defines. Neither carries one → ask the user for it. **GATE.** Then read the ticket where `docs/ISSUE-TRACKER.md` says tickets live, for the language it is written in.

**Then check the change earned its commit.** Find the review report at the path `docs/ISSUE-TRACKER.md` defines, named from the ticket id. Read its **Verdict**, **Round**, **Base** and **Diff** and nothing else, then the **Round** of the fix report beside it, when there is one. Hash the diff by running the bundled `scripts/diff-hash.sh` with `sh` (it needs `git` and a POSIX shell), handed the report's **Base** and each path `docs/ISSUE-TRACKER.md` lists under *Paths*, its `<...>` parts written as `*`. The verdict is not PASS, there is no review report, the fix report's **Round** matches the review's — fixes nobody re-reviewed — or the hash differs from the report's **Diff** or the report records none → say which, and ask the user whether to commit anyway. **GATE.** **Done when** the run is off the base branch or the user ruled to commit on it, the ticket id is resolved and the ticket read, and the review check passed or the user ruled to commit anyway.

### Step 2 — Inspect

Inspect everything uncommitted except the loop's artifacts: the working tree status plus the full diff against the last commit, tracked files and untracked alike. **Done when** every uncommitted path, tracked and untracked, is on the list Step 3 groups.

### Step 3 — Group it

One group per effect, and the groups cover everything uncommitted. What belongs to no group stays out of this branch: the user stashes it, moves it to another branch, or drops it. Ask which before you commit anything. **GATE.** **Done when** every path from Step 2 sits in exactly one group, or the user decided where it goes.

### Step 4 — Commit each group

Take one group at a time — stage it, then commit it with a subject line in the form `docs/GIT-CONVENTIONS.md` defines: `<tag>: <atomic description> (<ticket id>)`, with the id resolved in Step 1.

Add a body after one blank line, hard-wrapped at 72 columns, when the diff does something the subject doesn't name: a second surface changed, a behavior removed, or a constraint the code alone doesn't reveal. Write the body from the diff; read neither the implementation report nor the fix report.

Write subjects and bodies in the intent's language — the ticket's, read in Step 1 — as `docs/PIV-LOOP.md` says.

**Done when** every group is a commit whose subject follows that form, with a body wherever the rule above calls for one, and the working tree is clean.

## Output — the commit summary

3–6 sentences from the diff, printed for the user: what each commit changes and the key files it touches.

## Hand off

Confirm each commit by its short hash and subject. Committed on the base branch → no PR follows; say so and end here.

Otherwise offer the next move and let the user run it — this skill does not chain into the next one:

- **Open the PR** — run `piv-create-pr`, in this same session, handed the ticket id.
