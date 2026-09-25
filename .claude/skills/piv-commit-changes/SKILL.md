---
name: piv-commit-changes
description: Commits the finished work as atomic, conventionally-tagged commits.
argument-hint: "[ticket id] (blank = taken from the branch name)"
disable-model-invocation: true
---

# Commit: One Coherent Piece of Work per Commit

This is part of the **verify** step of the PIV loop `docs/PIV-LOOP.md` describes: the change passed review, and this run turns it into a clean, atomic history before the PR opens.

Commit the work as **atomic** commits — each one a coherent piece of work its subject line can name. Usually that is a single commit; when the tree holds unrelated work, split it. Either way the run ends with a clean tree: everything uncommitted lands in a commit, or the user decides where it goes.

## Process

### Step 1 — Check where you are

`docs/GIT-CONVENTIONS.md` defines which branch is the base branch. Work belongs on its own branch: when you are on the base branch, ask the user before committing anything. **GATE.** Go ahead when they confirm — a solo project with no PR coming commits on the base branch by design.

**Then check the change earned its commit.** Find the review report at the path `docs/ISSUE-TRACKER.md` defines — named from the ticket id, or, with no id, by comparing each report's **Branch** header against this branch, the way `piv-review-changes` does. Read its **Verdict** and nothing else, and check whether a fix report beside it is newer than it. The verdict is not PASS, there is no review report, or the fix report is newer — fixes nobody re-reviewed → say which, and ask the user whether to commit anyway. **GATE.** The loop closes on a PASS; committing past one that never came is the user's call, never yours.

### Step 2 — Inspect

Inspect everything uncommitted: the working tree status plus the full diff against the last commit, tracked files and untracked alike.

### Step 3 — Group it

One group per coherent piece of work, and the groups cover everything uncommitted. When something belongs to no group, ask the user what it is — a group of its own, a stash, or something to drop — before you commit anything. **GATE.**

### Step 4 — Commit each group

Take one group at a time — stage it, then commit it with a subject line in the form `docs/GIT-CONVENTIONS.md` defines: `<tag>: <atomic description> (<ticket id>)`. The id is the one `$ARGUMENTS` carries, or the one the branch name carries, in the form `docs/GIT-CONVENTIONS.md` defines. No id in either place → drop the suffix.

### Step 5 — Add a body when the subject isn't enough

When the subject alone leaves the work unexplained, add a body after one blank line saying what the commit implements. Hard-wrap the body at 72 columns.

Write that body from the diff in front of you. **This step deliberately does not read the implementation report or the fix report** — the narrative of why the change looks like this belongs in the PR, where a human reviewer meets it, and `piv-create-pr` is what reads both, along with the review report, to build it. A commit body that duplicates a report ages into a second, stale copy of it.

Done when every group is committed and the working tree is clean.

## Output — the commit summary

3–6 sentences, printed for the user: the feature/fix/refactor committed, the problem it solves, and the key files it touched. With more than one commit, say what each one carries.

## Hand off

Offer the next move and let the user run it — this skill does not chain into the next one: run `piv-create-pr` to open the PR, in this same session. The ticket id travels on the branch name, in the form `docs/GIT-CONVENTIONS.md` defines, and that is where the next skill reads it from.

## Success criteria

- ✅ The latest review report's verdict was PASS, with no fix report newer than it — or the user ruled to commit anyway.
- ✅ Every uncommitted change landed in a group, or the user decided where it goes.
- ✅ Every group is one coherent piece of work its subject can name.
- ✅ Every subject follows `<tag>: <atomic description> (<ticket id>)`, with the tag the work earns and the id present whenever one exists.
- ✅ The working tree is clean at the end of the run.
