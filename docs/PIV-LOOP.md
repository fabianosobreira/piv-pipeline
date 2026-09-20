# The PIV loop

**PIV** is **plan → implement → verify**, the loop this project's skills run work through. **Plan** turns an idea into an intent, an architecture and a set of tickets (`piv-create-prd`, `piv-create-architecture`, `piv-create-tickets`). **Implement** builds one ticket on its own branch and writes an implementation report (`piv-implement-ticket`). **Verify** proves the change wrong before it ships: a review writes a review report, a triage run fixes or defers what it found, and the work is then committed and handed to a human reviewer (`piv-review-changes`, `piv-fix-findings`, `piv-commit-changes`, `piv-create-pr`). Each step consumes the artifact the previous one wrote — `docs/ISSUE-TRACKER.md` names those artifacts and says where they live — and every step is started by the user, never by the step before it.

## The eight steps, in order

1. **`piv-create-prd`** — the intent: what to build and why, never how.
2. **`piv-create-architecture`** — the how: the engineering decisions the intent deliberately left open.
3. **`piv-create-tickets`** — the breakdown: the epic, and the tickets sliced out of the two above.
4. **`piv-implement-ticket`** — one ticket, built on its own branch, with an implementation report.
5. **`piv-review-changes`** — the gate: the findings that survive scrutiny, with a verdict.
6. **`piv-fix-findings`** — the triage: every finding fixed, deferred onto the tracker, flagged for a human, or dropped.
7. **`piv-commit-changes`** — the atomic history, one coherent piece of work per commit.
8. **`piv-create-pr`** — the hand-off out of the loop, to a human who reviews, approves and merges.

Steps 1 and 2 are entry points, not obligations: work with no open product question starts at the architecture, and work with no technical uncertainty starts at the tickets. Steps 5 and 6 repeat until a fresh review returns PASS.

## GATE and STOP

Two words for two different things, and a skill means exactly one of them:

- **GATE** — post what you have, **end the turn, and wait**. The user's answer is the only thing that moves the run forward, and the run picks up from where it stopped. Your own recommendation is never their answer, and your own judgement is never their approval.
- **STOP** — the run **ends here**. Name the condition that ended it and what would let it run again. Nothing continues on a guess.

## Nothing chains itself

Every step is started by the user. A skill ends by naming the next move; it never runs it.

That is what keeps a bad plan from becoming a merged PR while nobody was watching — and it is what keeps each run in a context of its own. A review that shares a context with the implementation it reviews is not an independent review, and a fix run that shares a context with the review cannot rule against it.

## The hand-off

Every skill closes the same way: confirm where the artifact landed and name it by path or id, then offer the next moves as a short list for the user to pick from and run. Hand on whatever the next step takes as its input — the epic id, the ticket id, the report's path.
