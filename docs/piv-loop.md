# The PIV loop

**PIV** is **plan → implement → verify**, the loop this project's skills run work through. **Plan** turns an idea into a reviewed spec, cuts it into one ticket per task and publishes it as one GitHub issue (`piv-spec`, `piv-review-spec`, `piv-slice`). **Implement** builds one task at a time on the intent's branch and writes an implementation report (`piv-implement`). **Verify** proves each task wrong before it is committed — a review writes a review report, a triage run fixes or defers what it found, and the task is then committed — and, once every task is in, opens the PR and audits it against the spec (`piv-review`, `piv-fix`, `piv-commit`, `piv-open-pr`, `piv-review-pr`). Each step consumes the artifact the previous one wrote — *Artifacts and layout* below names them and says where they live — and every step is started by the user, never by the step before it.

## The nine steps, in order

1. **`piv-spec`** — the plan: one interview that fixes requirements, design, tasks and verification in a spec.
2. **`piv-review-spec`** — the audit of the plan: the spec checked against the codebase and against the issues and PRs on GitHub, its open items settled with the user, and its revision marked reviewed.
3. **`piv-slice`** — the breakdown: one ticket per task, each a verbatim copy of the part of the spec its task needs, the epic that tracks them, and the one GitHub issue that publishes the spec.

Then, **per task**, in the order the epic gives, one task at a time:

4. **`piv-implement`** — the task, built on the intent's branch, with an implementation report.
5. **`piv-review`** — the gate: the findings that survive scrutiny, with a verdict.
6. **`piv-fix`** — the triage, when the review requests changes or, after a PASS, to clear its *low* findings: every finding fixed, deferred, flagged for a human, or dropped.
7. **`piv-commit`** — the task's atomic history, one coherent piece of work per commit.

Then, once every task is committed:

8. **`piv-open-pr`** — the hand-off out of the loop, to a human who reviews, approves and merges.
9. **`piv-review-pr`** — the audit of the PR against the spec.

`piv-write-prd` stands apart from the loop: a standalone skill that writes the intent — what to build and why, never how. Its PRD (`.piv/[intent-slug]/prd.md`) is an ordinary input of `piv-spec`: the user passes its path. Steps 5 and 6 repeat until a review returns PASS that no later fix run invalidated; steps 4 to 7 repeat until every task of the epic is committed. Tasks never run in parallel.

## GATE and STOP

Two words for two different things, and a skill means exactly one of them:

- **GATE** — post what you have, **end the turn, and wait**. The user's answer is the only thing that moves the run forward, and the run picks up from where it stopped. Your own recommendation is never their answer, and your own judgement is never their approval.
- **STOP** — the run **ends here**. Name the condition that ended it and what would let it run again. Nothing continues on a guess.

## Language

Every artifact of one intent is written in one language: the one the user runs the first planning interview in, which the PRD — or, with no PRD, the spec — sets. Every later step takes it from the `Language` field of the artifact it reads, since a fresh session has no conversation to take it from. Template labels — headings, header block fields, literal labels — stay as the templates write them, because the skills find them by their literal text.

## Nothing chains itself

Every step is started by the user. A skill ends by naming the next move; it never runs it.

That is what keeps a bad plan from becoming a merged PR while nobody was watching — and it is what keeps each run in a context of its own. A review that shares a context with the work it reviews is not an independent review, and a fix run that shares a context with the review cannot rule against it.

## Sessions

Hand-offs travel through artifacts, never through the conversation, so a fresh session loses nothing. Sessions are split by independence, not one per step:

Only `piv-commit` and `piv-open-pr` share a session, plus one case of `piv-commit` with a review. Every other step runs in a session of its own:

- **`piv-write-prd`, `piv-spec`, `piv-review-spec`, `piv-slice`** — each in a session of its own: `piv-review-spec` audits what `piv-spec` wrote, and `piv-slice` only runs on a spec the review marked reviewed.
- **`piv-implement`** — a session of its own, one per task.
- **`piv-review`** and **`piv-fix`** — each in a session of its own, every round.
- **`piv-commit`** — a session of its own, one per task, except when the `piv-review` just before it ended with zero findings: then it may share that review's session. After the last task, **`piv-open-pr`** follows it in the same session: both are light, and the PR body comes from the artifacts, not from the implementation's story.
- **`piv-review-pr`** — a session of its own: it audits what the loop shipped.

A hand-off marks the next step's session with one of three phrases: "in a session of its own" (must be fresh), "here or in a fresh session" (may share), "in this same session" (shares).

## The hand-off

Every skill closes the same way: confirm where the artifact landed and name it by path, then offer the next moves as a short list for the user to pick from and run. Hand on whatever the next step takes as its input — the issue number and the task id, or the report's path.

## Artifacts and layout

### The eleven words

One name per artifact, used the same way across every skill:

- **intent** — the *what and why*: a PRD, an idea, or a brief.
- **spec** — the plan: requirements, design, tasks and verification in one file written by `piv-spec`, from an idea or from a PRD.
- **spec review** — what `piv-review-spec` leaves behind: what it checked, what it settled with the user, and the spec revision it marked reviewed.
- **epic** — the local to-do list of an intent's tasks, with the state of each: born in `piv-slice`, read by every step that picks a task.
- **ticket** — one task of the spec, as a local file: a verbatim slice of the spec, exactly one task per ticket.
- **issue** — the one GitHub issue per intent, whose body is the spec as `piv-slice` published it. Its number is the intent's id in git.
- **deferral** — a finding `piv-fix` set aside for later work, as a local file that names the task whose review raised it.
- **implementation report** — what a finished task leaves behind: what was built, how it was validated, and what deviated.
- **review report** — what the review gate leaves behind: the findings that survived it, with a verdict.
- **fix report** — what the triage of a review leaves behind: which findings were fixed, deferred, flagged for a human, or dropped.
- **PR review** — what `piv-review-pr` leaves behind: the PR held against every item of the spec, with a verdict.

"Report" on its own is fine in prose when only one is in play; name which one whenever more than one could be meant. "Plan", "slice" and "breakdown" are loose synonyms that show up in prose; when it matters which artifact is meant, use one of the eleven.

### Layout

Everything but the issue and the PR stays local, under `.piv/` at the repository root, which the root `.gitignore` ignores:

```
.piv/[intent-slug]/
  prd.md                 piv-write-prd (when the intent starts from a PRD)
  spec.md                piv-spec
  spec.review.md         piv-review-spec
  epic.md                piv-slice
  pr-review.md           piv-review-pr
  deferrals/
    D-01.md              piv-fix
  tasks/
    T-01/
      T-01.md            the ticket, piv-slice
      T-01.report.md     piv-implement
      T-01.review.md     piv-review
      T-01.fixes.md      piv-fix
```

Nothing under `.piv/` is ever committed, and a step that lists or stages uncommitted paths never sees it.

### Header block

The PRD, the epic, every ticket, every deferral and every report open with one **header block** — one bold label per line, directly under the title — carrying the fields that tie them to each other:

- **`Intent-slug`** — the key defined below. Every artifact of one intent carries the same one.
- **`Language`** — the BCP 47 tag of the intent's language, such as `pt-BR`: set by the PRD — or, with no PRD, the spec — and copied verbatim into every other artifact that carries it.

Each template names the other fields it adds. The spec keeps `Status`, `Intent-slug` and `Language` in its own plain header lines.

A header block is a markdown list, not YAML front matter: the PR body carries one, and on GitHub front matter renders as a stray heading instead of as metadata.

### Intent-slug

The kebab-slug of the product title — or, with no PRD, of the spec's goal — in lowercase ASCII with accents stripped. It names the intent's directory under `.piv/`. Later steps **read it from the artifact instead of re-deriving it**, so a PRD written under `user-auth/` never acquires an `authentication/` spec beside it.

### Types

Every task, issue, PR and deferral carries exactly one type: `bug` is behavior that diverges from what was specified or delivered; `feature` delivers a new capability; `none` is any other work — refactor, docs, chore or infra. The issue takes the largest effect among its tasks — `feature` over `bug` over `none` — and the PR takes the issue's.

### Resolving the intent and the task

A step of the per-task loop takes `[#N | intent-slug] [T-xx]`:

- **`#N`** — the intent whose `epic.md` names issue `#N` under `Issue`.
- **`intent-slug`** — the directory `.piv/[intent-slug]/`.
- **Blank** — the issue number the current branch name carries, as `docs/git-conventions.md` defines it; no number there → ask the user. **GATE.**
- **`T-xx` blank** — the next task of the epic: its first `[~]` task, the one in progress; with none, its first `[ ]` task whose every `Depends on` is `[x]`. No task qualifies → **STOP**; when every task is `[x]`, the next step is `piv-open-pr`.

### The epic

`.piv/[intent-slug]/epic.md` follows this grammar exactly, since the skills parse it:

```
- **Intent-slug**: [intent-slug]
- **Language**: [BCP 47 tag]
- **Spec**: [spec path] @ [hash]
- **Issue**: [#N and its URL]
- **Type**: [the issue's type: bug, feature or none]
- **Branch**: [branch name]

## Context
[one sentence from section 1 of the spec]

## Tasks
- [ ] T-01 — [title] | [bug|feature|none] | [S|M|L] | Depends on: [-|T-xx, T-yy]
- [~] T-02 — [title] | [type] | [size] | Depends on: T-01
- [x] T-03 — [title] | [type] | [size] | Depends on: - — commits: a1b2c3d, e4f5a6b

## Deferrals
- D-01 — [title] — origin T-02
[or "None."]

## Not ticketed
- [an open question of the spec that no ticket carries, and the IDs it cites]
[or "None."]
```

`Issue`, `Type` and `Branch` read `pending` until their owner fills them. Each mark has exactly one owner, and no other skill writes to the file:

- **`piv-slice`** — creates the file, and fills `Issue` and `Type` once the issue exists.
- **`piv-implement`** — creates the branch on the first task, named as `docs/git-conventions.md` defines it with the intent-slug as its `[slug]`, fills `Branch` with its name, and turns a task `[ ]` → `[~]`. The branch stays local until `piv-open-pr` pushes it.
- **`piv-commit`** — turns a task `[~]` → `[x]` and appends ` — commits: [short hashes]`.
- **`piv-fix`** — appends a line under *Deferrals*.

### The remote

GitHub is the only remote the loop talks to, through the `gh` CLI. It **receives writes at two points only**:

- **`piv-slice`** — creates the issue: the spec as its body, assigned to the user.
- **`piv-open-pr`** — opens the PR: `Closes #N` in its body, assigned to the user. The merge closes the issue; no step closes it by hand.

Every other step may read from GitHub — `piv-review-spec` and `piv-review-pr` do — and writes nothing there: no comment, no status. The issue is a snapshot of the spec as it was published, never synced.

Before any call, the steps that reach GitHub run `gh auth status`. On failure, `piv-slice` and `piv-open-pr` **STOP**, naming `gh auth login`; `piv-review-spec` and `piv-review-pr` post the message with the same fix and ask whether to rerun or go on without the remote. **GATE.** Going on is recorded in the review as `Remote check: skipped by the user`.
