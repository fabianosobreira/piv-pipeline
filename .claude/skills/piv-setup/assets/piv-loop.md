# The PIV loop

**PIV** is **plan → implement → verify**, the loop this project's skills run work through. **Plan** turns an idea into a spec and a set of tickets (`piv-spec`, `piv-slice`). **Implement** builds one ticket on its own branch and writes an implementation report (`piv-implement`). **Verify** proves the change wrong before it ships: a review writes a review report, a triage run fixes or defers what it found, and the work is then committed and handed to a human reviewer (`piv-review`, `piv-fix`, `piv-commit`, `piv-open-pr`). Each step consumes the artifact the previous one wrote — `docs/issue-tracker.md` names those artifacts and says where they live — and every step is started by the user, never by the step before it.

## The seven steps, in order

1. **`piv-spec`** — the plan: one interview that fixes requirements, design, tasks and verification in a spec.
2. **`piv-slice`** — the breakdown: the tickets sliced out of the spec, each a verbatim copy of the part its task needs, plus an epic when there is more than one.
3. **`piv-implement`** — one ticket, built on its own branch, with an implementation report.
4. **`piv-review`** — the gate: the findings that survive scrutiny, with a verdict.
5. **`piv-fix`** — the triage: every finding fixed, deferred onto the tracker, flagged for a human, or dropped.
6. **`piv-commit`** — the atomic history, one coherent piece of work per commit.
7. **`piv-open-pr`** — the hand-off out of the loop, to a human who reviews, approves and merges.

`piv-write-prd` stands apart from the loop: a standalone skill that writes the intent — what to build and why, never how. Only `piv-spec` reads its PRD, as optional context. Steps 4 and 5 repeat until a fresh review returns PASS.

## GATE and STOP

Two words for two different things, and a skill means exactly one of them:

- **GATE** — post what you have, **end the turn, and wait**. The user's answer is the only thing that moves the run forward, and the run picks up from where it stopped. Your own recommendation is never their answer, and your own judgement is never their approval.
- **STOP** — the run **ends here**. Name the condition that ended it and what would let it run again. Nothing continues on a guess.

## Language

Every artifact of one intent is written in one language: the one the user runs the first planning interview in, which the PRD — or, with no PRD, the spec — sets. Every later step takes it from the `Language` field of the artifact it reads, since a fresh session has no conversation to take it from. Template labels — headings, header block fields, literal labels — stay as the templates write them, because the skills find them by their literal text.

## Nothing chains itself

Every step is started by the user. A skill ends by naming the next move; it never runs it.

That is what keeps a bad plan from becoming a merged PR while nobody was watching — and it is what keeps each run in a context of its own. A review that shares a context with the implementation it reviews is not an independent review, and a fix run that shares a context with the review cannot rule against it.

## Sessions

Hand-offs travel through artifacts, never through the conversation, so a fresh session loses nothing. Sessions are split by independence, not one per step:

- **Planning** — `piv-spec` → `piv-slice` may share a session: they collaborate rather than audit each other. Past half the window, break at an artifact boundary.
- **`piv-implement`** — a session of its own, one per ticket.
- **`piv-review`** and **`piv-fix`** — each in a session of its own, every round.
- **`piv-commit` → `piv-open-pr`** — one fresh session, shared. Both are light, and the commit body comes from the diff, not from the implementation's story.

A hand-off marks the next step's session with one of three phrases: "in a session of its own" (must be fresh), "here or in a fresh session" (may share), "in this same session" (shares).

## The hand-off

Every skill closes the same way: confirm where the artifact landed and name it by path or id, then offer the next moves as a short list for the user to pick from and run. Hand on whatever the next step takes as its input — the ticket id, the report's path.
