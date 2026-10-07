# Exploration menu

Read alongside `SKILL.md` Step 2: the menu is the design tree's nodes, and *Spikes* gives the form for a one-way call.

## What to explore

A menu, not a checklist. Take what fits the shape of work, **name what you're skipping and why**, and add anything the domain needs that isn't listed.

- **Approaches** *(always)* — 2–3 genuinely different ways to solve it, from different angles, with trade-offs.
- **First principles** *(always)* — what fundamentally has to be true for this to work.
- **Building blocks** — what you'd build it with, and *why* (fit, maturity, familiarity, what they already run) — with alternatives. Languages and libraries for new code; equally: services, platforms, protocols, or existing systems when the work isn't a new codebase.
- **Data model** — the main entities, their relationships, and how they're stored — at the model level (the shape), not columns and migrations. Skip it when the work doesn't own data.
- **Boundaries & contracts** — **name the trust boundaries this work crosses**: security/auth posture, secrets, external dependencies, and the major interface boundaries. **Rarely skippable** — almost every change crosses one somewhere.
- **Operational shape** — how it runs, gets observed, and fails: deployment/rollout, failure modes, recovery. Often where the real risk lives for infra and pipeline work.
- **Testability** — the seams the tests will need that the code doesn't offer yet (clock, external services, static or `new`-constructed dependencies), and how each is injected. Brownfield: check what the target platform provides before choosing a mechanism.
- **Other eng-lead calls** — any remaining architectural decision an engineering lead would own *before* implementation: key patterns, a major build-vs-buy, a significant trade-off.
- **Missing pieces** — what doesn't exist yet that the chosen approach needs (often the real work).
- **Spikes & experiments** — anything uncertain or expensive-to-reverse → see *Spikes* below.

## Spikes (for the risky / one-way calls)

When a decision is a **one-way door** — uncertain or expensive to undo — recommend a **spike** instead of guessing:

```
Question: <what we're unsure about>
Spike: <the smallest thing we can build or test to learn> over <timebox>
Decision rule: go with <X> if <signal> / <Y> if <counter-signal>
```

Reversible, low-cost calls skip the spike — recommend an answer as an ordinary frontier question instead of guessing on the user's behalf.

When the intent is a PRD, its *MVP* records the door `piv-create-prd` called: a one-way door there is a spike candidate here. That door is the MVP's as a whole, so a two-way MVP can still hold a one-way decision — judge each decision by its own door.
