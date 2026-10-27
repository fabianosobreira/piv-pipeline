---
name: piv-review-spec
description: Audits a ready spec against the codebase and the repo's GitHub issues and PRs, settles its open items with the user, and marks the revision reviewed so piv-slice can publish it.
argument-hint: "[intent-slug] (blank = starts by asking for it)"
disable-model-invocation: true
allowed-tools:
  - Bash(sh ${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh *)
  - Bash(git hash-object *)
  - Bash(gh auth status)
  - Bash(gh issue list *)
  - Bash(gh pr list *)
---

# Review spec: Check the Plan Before It Is Published

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes. It audits `.piv/[intent-slug]/spec.md` before `piv-slice` publishes it as the intent's issue: what the codebase already holds, what the repo's issues and PRs already say, and every item the interview left open. It edits the spec only with the user's answers, and writes `.piv/[intent-slug]/spec.review.md`. `piv-slice` runs only on a spec this skill marked `Status: reviewed`, at the revision whose hash `spec.review.md` records. It reads GitHub and writes nothing there.

Talk to the user, and write every spec edit and the content of `spec.review.md`, in the spec's `Language`; headings, labels, IDs and keywords stay as the templates write them.

- Output skeleton: `${CLAUDE_SKILL_DIR}/templates/spec-review.md`
- Validator: `${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh` (execute it, do not read it). It is a copy of `piv-spec`'s and needs only POSIX `sh` and `awk`.

## Success criteria

- ✅ Every spec item the codebase already holds, in part or whole, is listed with its `path:line`.
- ✅ Every GitHub issue or PR that overlaps or contradicts the spec is listed with its number and URL — or the user ruled to skip the remote check, and `spec.review.md` says so.
- ✅ Every `[DEFERRED]` item, overlap, conflict and error found was put to the user as a question. Nothing entered the spec without an answer, and every edit carries `Source: Q<n>` with a decision log row.
- ✅ The lint printed `RESULT: OK` on the final spec.
- ✅ The spec says `Status: reviewed` and `Reviewed-hash` is its hash after its last edit — or it says `Status: draft`, `spec.review.md` says `Outcome: reopened`, and it lists what `piv-spec` has to settle.

## Rules

The rules of `piv-spec` hold here, restated because this run edits the spec:

1. **The agent never fills a gap.** A fact found in the codebase or on GitHub enters the spec only after the user confirms it in a question.
2. **A recommendation requires an empirical basis** (a checkable claim with its source: `path:line`, an issue or PR number, command output) **or a pragmatic one** (the concrete problem in the spec — `FR-xx`, `D-xx`, `Q<n>` — and how the option solves it), or both. No basis → say so.
3. **Questions** — at most 3 per message, numbered on from the highest `Q<n>` in the spec's decision log, each with 1 to 3 options, every message ending on a **GATE**:

```markdown
🔍 **Q23 - Existing limiter**: `src/middleware/throttle.js:12` already caps requests per IP. What happens to FR-02?

- A - Keep FR-02 and replace the throttle
- B - Rewrite FR-02 to extend the throttle

> 💡 Recommend B. Empirical: `src/server.js:18` mounts the throttle on every route. Pragmatic: B keeps one limiter; A leaves two counters for D-01 to reconcile.
```

| User reply | Handling |
|---|---|
| `A`, `B`, `C`, `A with change: ...`, free text | Record it, and apply it in Step 5 |
| `?` or `defer` | The item stays, or becomes, an open question marked `[DEFERRED]` in section 8 |
| "You decide" | Re-ask with the recommended option, when a basis supports one, and require explicit confirmation |

## Process

Copy this checklist into the first message. Tick a step only when its **Done when** holds.

```
- [ ] Step 1 — Read the spec
- [ ] Step 2 — Recon the codebase
- [ ] Step 3 — Check the remote
- [ ] Step 4 — Settle the open items with the user
- [ ] Step 5 — Apply the answers and lint
- [ ] Step 6 — Mark the outcome and write spec.review.md
```

### Step 1 — Read the spec

`$ARGUMENTS` carries the intent-slug. Nothing passed → list each `.piv/[slug]/spec.md` that says `Status: ready` and ask which. **GATE.** No spec at `.piv/[intent-slug]/spec.md` → **STOP**: `piv-spec` writes it first.

Read the spec end to end. Its header decides whether the run goes on:

- `Status: draft` → **STOP**: the spec has to be concluded in `piv-spec`.
- No `Intent-slug` or `Language` line → **STOP**: the spec predates the format and has to be rewritten in `piv-spec`.
- `Status: reviewed`, and `spec.review.md` records a `Reviewed-hash` equal to `git hash-object --no-filters [spec path]` → say it is already reviewed, and **STOP** pointing at `piv-slice`.
- `Status: reviewed` with a different or missing hash — the spec changed after its review — or `Status: ready` → go on.

**Done when** every `FR`, `NFR`, `C`, `D`, `AC` and `T` item and every open question of section 8 is listed, the `[DEFERRED]` ones marked.

### Step 2 — Recon the codebase

For each `FR`, `D` and `T`, search the codebase for what already does it, in part or whole, and read what you find. Check every path sections 6 and 7 name and every command of section 10 against the repo. Record each hit as the item's ID, what exists and its `path:line`. A hit that makes an item moot, or that contradicts it — a file the design creates already exists with another shape, a section 10 command the repo lacks — is an item for Step 4.

**Done when** every `FR`, `D` and `T` was searched, and every path and command the spec names was checked.

### Step 3 — Check the remote

Run `gh auth status`. It fails → post its message with the command that fixes it (`gh auth login`), and ask whether to fix it and rerun, or go on without the remote check. **GATE.** Skipping → `Remote check: skipped by the user`, and go to Step 4.

Search the repo's issues and PRs, open and closed, with terms from the spec's title, its `FR` and its `D` items: `gh issue list --state all --search [terms]` and `gh pr list --state all --search [terms]`, asking for the number, title, state, URL and body. Read each result and keep the ones that overlap the spec or contradict it — an open PR that builds the same thing, a closed issue that rejected it, an issue that asks for the opposite. Each kept one is an item for Step 4.

**Done when** the auth check passed and every search ran with its results read, or the user ruled to skip the remote check.

### Step 4 — Settle the open items with the user

Ask one question per item: every `[DEFERRED]` open question, every item Step 2 found the codebase already holds or contradicts, and every issue or PR Step 3 kept. Follow **Rules**.

An answer that needs a new interview — a new requirement, a task plan reshaped beyond single lines, a phase of `piv-spec` to redo — is not settled here: note it for Step 6 as a reason to reopen.

**Done when** every item has an answer, a `defer`, or a note to reopen.

### Step 5 — Apply the answers and lint

Edit the spec line by line: each changed or new line carries `Source: Q<n>`, as `piv-spec` writes it, and each question gets one decision log row with `review` in its *Phase* column. Set `Last updated`. Leave `Status` for Step 6.

Run `sh ${CLAUDE_SKILL_DIR}/scripts/lint_spec.sh [spec path]`. It prints findings → ask the question that closes each one (Step 4), apply the answer, and run it again until it prints `RESULT: OK`.

**Done when** every answer is in the spec with its decision log row, and the lint printed `RESULT: OK`.

### Step 6 — Mark the outcome and write spec.review.md

- **A note to reopen** → set `Status: draft`. Write `spec.review.md` from `${CLAUDE_SKILL_DIR}/templates/spec-review.md` with `Outcome: reopened` and `Reviewed-hash: none`, listing under *Resolved with the user* each item `piv-spec` has to settle. **STOP**, pointing at `piv-spec [intent-slug]`.
- **Otherwise** → set `Status: reviewed`, the spec's last edit. Run the lint once more, then take `git hash-object --no-filters [spec path]`. Write `spec.review.md` from the template, used exactly, with `Outcome: reviewed` and that hash as `Reviewed-hash`. Never write the hash into the spec: any edit to the spec changes it.

**Done when** `spec.review.md` exists with every section filled, and its `Reviewed-hash` matches the spec — or it says `reopened` and the spec says `Status: draft`.

## Hand off

Confirm where the spec and `spec.review.md` landed, by path, then offer the next move and let the user run it:

- **Reviewed** → run `piv-slice [intent-slug]`, in a session of its own.
- **Reopened** → run `piv-spec [intent-slug]` to settle what `spec.review.md` lists, then this skill again.
