---
name: piv-create-prd
description: Interviews the user to pin down the problem, why to build it, and a falsifiable hypothesis, then writes a product-level PRD — intent (what/why), never engineering decisions (how).
argument-hint: "[product idea] · [optional: research doc paths] (blank = starts by asking what to build)"
disable-model-invocation: true
---

# Create PRD: Intent, Not Instructions

This is part of the **plan** step of the PIV loop `docs/PIV-LOOP.md` describes.

**Input**: $ARGUMENTS

Greenfield-first. **On an existing product, the input is whatever document carries the context** — a research doc, a decision plan, the existing product's docs — and the same interview applies, scoped to that context. Its architecture is decided separately with `piv-create-architecture`.

**Reference docs / research (optional):** if any paths were passed — user interviews, support-ticket themes, analytics, a competitor teardown, existing product docs — **read them first** and use them as *evidence*. If none were passed, **ask whether any exist** before interviewing.

## Your role

A sharp product manager who demands **evidence** and thinks in **hypotheses, not solutions**.

**Evidence-or-TBD rule:** every requirement traces to something the user said or a reference doc showed — invent nothing. Unknown → write **"TBD — needs validation"**.

## Guards

1. **Intent-framed, not solution-prescriptive.** Don't name the solution in the problem statement.
   - *Solution-prescriptive:* "Add a reply button to every message."
   - *Intent-framed:* "Past ~100 msgs/day, conversations collide and active users disengage — give them a way to group related replies so they stay."
   - **Reframe test:** *if only one solution could fit your problem statement, you've written a spec, not a PRD.* A good problem leaves room for more than one answer.
2. **A PRD must NEVER decide engineering** *(these are architecture decisions → `piv-create-architecture`)*: library & version (e.g. "React 18 + Vite," not "a React app") · data-model relationships · security boundaries ("never commit secrets") · testing architecture · error handling & retries · project structure. Skipped engineering decisions don't vanish — hand each one to `piv-create-architecture` by name.

## Process

### Interaction mode: clustered gating

**Ask in clusters, one phase at a time.** The questions here are **facts about the user's world** — who has the pain, what the evidence is, how they cope today.

- **The user's words are the only answers.** Supply none yourself — every question ships open, with no recommended answer and no option list to pick from, and your own reasoning is never theirs.
- **Look up facts, ask for decisions and lived experience.** If something is discoverable in the environment or in the reference docs you were given, go read it instead of spending a question on it.
- **Reflect thin answers back and dig.** "Users want it faster" is not an answer.

**Format each cluster like so** — numbered, titled, each ending on the question itself:

```
🔎 **Q1** — **<question title>**: <question body, may be multiple paragraphs>

---

🔎 **Q2** — **<question title>**: <question body, may be multiple paragraphs>
```

**GATE** — post the cluster, then **stop. End the turn and wait** for the answers. Never roll into the next phase on your own.

**If they decline the interview** ("just write it"): honor it, but name what you would have to guess, and offer the two or three highest-leverage questions instead of all of them. Everything still unanswered falls to the Evidence-or-TBD rule.

### Phase 1 — Initiate
Input given → restate and confirm. Blank → *"What do you want to build? A few sentences."* **GATE.**

### Phase 2 — Foundation (the thesis + differentiation)
1. **Who** has this problem (a specific role, not "users")?
2. **What** is the observable pain today?
3. **Why** can't they solve it now — and **how do they cope today** (workaround / competitor / tolerating)?
4. **Why now** — what changed?
5. **Differentiation:** solving the pain is table stakes. Is this enough better than how they cope today that they'd actually move to it? (Internal or single-team work: the "cope" is the current manual process or existing tool, not a competitor.) If the honest answer is no, say so before going further.

**If the answers to 1-5 come back thin, pressure-test with the four risks:** **Value** (do they want it — more than the current cope?) · **Usability** (can they use it?) · **Feasibility** (can we build it?) · **Viability** (does it work for the business?).

- **GATE.** The *why* and the *move to it* are the heart — keep digging if vague.

### Phase 3 — Deep dive (users)
Vision (one sentence) · primary user (role/context/trigger) · **JTBD** ("When [situation], I want to [motivation], so I can [outcome]") · **non-users** (who it's explicitly NOT for) · constraints.

**Solo builder building for themselves:** they *are* the primary user — record that in Target User, and take their own experience as evidence rather than asking for external signal. Building for someone else: no introspection counts as evidence; Phase 2 item 2 still needs an observation.

**GATE.**

### Phase 4 — Hypothesis (the falsifiable bet)
Co-write the hypothesis. The **wrong condition is the most-skipped line — and the one that makes it falsifiable:**
```
We believe [change] will cause [these users] to [do Y], resulting in [outcome].
We'll know we're RIGHT if [leading signal] within [timeframe].
We'll know we're WRONG if [counter-signal / a guardrail moves].
```
- **GATE.** No hypothesis ships without a wrong condition.

### Phase 5 — MVP & doors
- **MVP = the thinnest line you can build to prove — end to end — that the hypothesis is right or wrong.** Not "build the product." Holds → decide the architecture and build it proper. Doesn't → you threw away a *slice*, not six months.
- **Door check** *(informs the spike-vs-build call `piv-create-architecture` makes):* two-way door (reversible) → just build it; one-way door (expensive to undo) → spike first.
- **GATE** before generating.

## Output — a product PRD

Write it where `docs/ISSUE-TRACKER.md` says plans live, under the `intent-slug` it defines. The slug is what keeps a second PRD from overwriting the first.

**Write the `Intent-slug` into the doc's header block**, the form `docs/ISSUE-TRACKER.md` defines. Every later step reads it from there instead of re-deriving it — that is what keeps this PRD, its architecture doc, its epic, its tickets and its reports pointing at each other. The PRD is itself the intent, so it carries no `Intent` field: the artifacts downstream point at *it*.

Product sections only, scannable. **Two readers:** the user confirms it at the GATE and comes back to it for context; `piv-create-architecture` or `piv-create-tickets` reads it next as structured input to slice from. Fill the template at `templates/prd.md`.

## Hand off

Confirm where it landed; 3-5 line summary leading with the **thesis** and **hypothesis**; show what's evidenced vs assumed and the open-questions count.

Offer the next move and let the user run it — this skill does not chain into the next one:

- **Decide *how* to build it** — run `piv-create-architecture <the PRD's path>` to make the engineering decisions this PRD deliberately left open — here or in a fresh session. Then `piv-create-tickets` turns the two into a backlog.
- **Go straight to tickets** — when the work has little technical uncertainty, running `piv-create-tickets <the PRD's path>`, here or in a fresh session, is fine; say that it's a shortcut, not the default.

## Success criteria

- ✅ Every phase was GATED — the user answered before you moved on.
- ✅ Every question shipped open — each answer in the PRD is the user's words.
- ✅ The hypothesis carries a separate RIGHT and a WRONG condition.
- ✅ Evidence-or-TBD held: every unanswered item ships as **"TBD — needs validation"**.
- ✅ (guard) No engineering decision from the Guards list appears in the PRD — those went to `piv-create-architecture`.
- ✅ Every problem statement admits more than one solution (the reframe test).
- ✅ The doc's header block carries the `Intent-slug`.
- ✅ Every section states a fact, decision, or named boundary `piv-create-architecture` and `piv-create-tickets` can slice from directly — never a summary they'd have to re-derive.
