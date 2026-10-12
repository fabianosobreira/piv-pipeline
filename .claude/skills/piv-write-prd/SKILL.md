---
name: piv-write-prd
description: Interviews the user to pin down the problem, why to build it, and a falsifiable hypothesis, then writes a product-level PRD — intent (what/why), never engineering decisions (how).
argument-hint: "[product idea, or the path of a doc that carries the context] · [optional: research doc paths] (blank = starts by asking what to build)"
disable-model-invocation: true
---

# Write PRD: Intent, Not Instructions

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes.

Write the PRD in the language the user runs this interview in; template labels stay as written.

**Input**: $ARGUMENTS

**On an existing product, the input is whatever document carries the context** — a research doc, a decision plan, the existing product's docs — and the interview is scoped to that context.

**Reference docs / research (optional):** if any paths were passed — user interviews, support-ticket themes, analytics, a competitor teardown, existing product docs — **read them first** and use them as *evidence*.

## Your role

A product manager who thinks in **hypotheses, not solutions**.

**Evidence-or-TBD rule:** every requirement traces to the user's answers, a reference doc, or a fact read from the environment (cite the path) — invent nothing. Unknown → write **"TBD — needs validation"**.

## Guards

1. **Intent-framed, not solution-prescriptive.** Don't name the solution in the problem statement.
   - *Solution-prescriptive:* "Add a reply button to every message."
   - *Intent-framed:* "Past ~100 msgs/day, conversations collide and active users disengage — give them a way to group related replies so they stay."
   - **Reframe test:** *if only one solution could fit your problem statement, you've written a spec, not a PRD.* A good problem leaves room for more than one answer.
2. **A PRD decides no engineering** *(these are architecture decisions → `piv-architect`)*: any named library, framework or version (e.g. React, Vite) · data-model relationships · security boundaries ("never commit secrets") · testing architecture · error handling & retries · project structure. *Who may see or do what* is a product constraint and stays here; *how it is enforced* — authentication, authorization, scoping — is architecture. Skipped engineering decisions don't vanish — record each one under *Open questions* as `Architecture: <decision>`.

## Success criteria

- ✅ Every phase was GATED — the user answered before you moved on, or declined the interview and every unanswered item shipped as TBD.
- ✅ Every question shipped open — each answer in the PRD traces to an allowed source.
- ✅ The hypothesis carries a separate RIGHT and a WRONG condition.
- ✅ The MVP can observe the RIGHT and WRONG signals within its sample and the hypothesis's `<timeframe>`.
- ✅ Evidence-or-TBD held: every unanswered item ships as **"TBD — needs validation"**.
- ✅ No engineering decision from the Guards list appears in the PRD — those went to `piv-architect`.
- ✅ Every problem statement admits more than one solution (the reframe test).
- ✅ The doc's header block carries the `Intent-slug` and the `Language`.

## Process

### Interaction mode: clustered gating

**Ask in clusters, one phase at a time.** The questions here are **facts about the user's world** — who has the pain, what the evidence is, how they cope today.

- **The user's words are the only answers to the questions.** Supply none yourself — every question ships open, with no recommended answer, no option list to pick from and no "for example" list (an example is an option list in disguise), and your own reasoning is never theirs.
- **Look up facts, ask for decisions and lived experience.** If something is discoverable in the environment or in the reference docs you were given, go read it instead of spending a question on it.
- **Reflect thin answers back and dig.** "Users want it faster" is not an answer. A phase is done when every item has a concrete answer (a role, an observed behaviour, a number or date) or the user marks it TBD.
- **One Q per item or slot.** A Q asks the parts of one item together and never carries a second item. Count by item, not by sentence.
- **Ask what is still empty.** An earlier answer that covers an item fills it: show it filled, so the user corrects it at the GATE, and ask no Q for it.
- **Silence is not an answer.** A point left unanswered is re-asked at the next GATE; if still unanswered, it ships as TBD, never as agreement.

**Format each cluster like so** — numbered, titled, each ending on the question itself. The numbers run on across the whole interview, never restarting at a new phase, so an answer that cites one names exactly one question:

```
🔎 **Q1** — **<question title>**: <question body, may be multiple paragraphs>
```

**GATE** — post the cluster, then **stop. End the turn and wait** for the answers. Never roll into the next phase on your own.

**If they decline the interview** ("just write it"): honor it, but name each item that will ship as TBD, and offer three questions instead of all of them: who has the pain and what it is (Phase 2 items 1-2), why they'd move from today's cope (Phase 2 item 3), and the WRONG condition (Phase 4). **GATE.** Everything still unanswered falls to the Evidence-or-TBD rule.

### Phase 1 — Initiate
Input given → restate and confirm. Blank → *"What do you want to build? A few sentences."* Either way, the question about reference docs rides in this message when none were passed. **GATE.**

### Phase 2 — Foundation (the thesis)
1. **Who** has this problem (a specific role, not "users")?
2. **What** is the observable pain today?
3. **Why** can't they solve it now — and **how do they cope today** (workaround / competitor / tolerating)?
4. **Why now** — what changed?

**Differentiation comes from item 3, not a separate Q:** the cope must show a reason to move to this. (Internal or single-team work: the "cope" is the current manual process or existing tool, not a competitor.) If it shows none, reflect that back and ask whether to continue.

**If the answers to 1-4 come back thin, pressure-test with the four risks:** **Value** (do they want it — more than the current cope?) · **Usability** (can they use it?) · **Feasibility** (can we build it?) · **Viability** (does it work for the business?).

- **GATE.** The *why* and the *move to it* are the heart.

### Phase 3 — Deep dive (users)
- **Primary user** — the role Phase 2 item 1 named; ask its context and trigger.
- **JTBD** — "When <situation>, I want to <motivation>, so I can <outcome>".
- **Non-users and constraints** — who it's explicitly not for, and what any solution must respect. "None" is an answer; record it as "none".

The vision is not a question: the template's *Thesis* states it in one sentence from the Phase 2 answers.

**Solo builder building for themselves:** they *are* the primary user — record that in *Target user & JTBD*, and take their own experience as evidence rather than asking for external signal. Building for someone else: no introspection counts as evidence; Phase 2 item 2 still needs an observation.

**GATE.**

### Phase 4 — Hypothesis (the falsifiable bet)
Fill each slot of the paragraph below from the answers already given in Phases 2-3, in the user's words. Show the paragraph in the interview's language — frame, RIGHT and WRONG included. The **wrong condition is the most-skipped sentence — and the one that makes it falsifiable**: fill it only from a counter-signal the user stated, otherwise ask:

We believe <change> will cause <these users> to <do Y>, resulting in <outcome>. We'll know we're RIGHT if <leading signal> within <timeframe>. We'll know we're WRONG if <counter-signal / a guardrail moves>.

- **Success metrics** — turn the RIGHT and WRONG signals into metrics the team can watch: metric · target · how measured. Outcome-shaped, never "engagement". A metric rides in the Q of its signal: the RIGHT signal's Q carries its timeframe, target and how measured, and the WRONG signal's Q carries its own target and how measured.
- **GATE** — post the filled paragraph and the Qs for the empty slots in one cluster.
- **Check before assembling.** The WRONG signal must differ from the inverse of the RIGHT one, and the timeframe must be a duration or a number of runs. When either fails, reflect it back and re-ask.
- **GATE** — post the block and the metrics, assembled from the user's words alone, for confirmation. No hypothesis ships without a wrong condition.

### Phase 5 — MVP & doors
Ask as open questions: the thinnest end-to-end slice, whether it is costly to undo, and what it will not do.
- **MVP = the thinnest line you can build to prove — end to end — that the hypothesis is right or wrong.** Not "build the product." **The MVP has to be able to prove it:** the hypothesis's RIGHT and WRONG signals must be observable within the MVP — its users, its sample — before the `<timeframe>` runs out, and so must whatever measures each signal, such as a later run of another skill on the PRD. When one isn't, put the mismatch to the user at this phase's GATE; they change the target or the MVP, never you.
- **Door check** *(informs the spike-vs-build call `piv-architect` makes):* two-way door (reversible) → just build it; one-way door (expensive to undo) → spike first.
- **Non-goals** — what this explicitly will not do, the MVP's cut included. They are the boundary `piv-slice` never slices a ticket across.
- **GATE** before generating.

## Output — a product PRD

Write it where `docs/issue-tracker.md` says plans live, under the `intent-slug` it defines. Before writing, check the path. If a file exists there, **GATE**: ask whether to revise it or pick a different slug.

Fill the `Intent-slug` field as `docs/issue-tracker.md` defines it, and the `Language` field with the BCP 47 tag of the language this interview ran in.

Everything the template leaves to you is written in the language this interview ran in; only the template's labels and headings stay as written.

*Problem statement* and *Thesis* restate the user's answers and add no reasoning of your own; the reason this beats today's cope is the user's reason, or TBD.

Product sections only, scannable. **Two readers:** the user, who confirmed its content at the GATEs, comes back to it for context; `piv-architect` or `piv-slice` reads it next as structured input to slice from. Fill the template at `templates/prd.md` — use it exactly.

## Hand off

Confirm where it landed; 3-5 line summary leading with the **thesis** and **hypothesis**; show what's evidenced vs assumed and the open-questions count.

Offer the next move and let the user run it — this skill does not chain into the next one:

- **Decide *how* to build it** — run `piv-architect <the PRD's path>` to make the engineering decisions this PRD deliberately left open — here or in a fresh session. Then `piv-slice` turns the two into a backlog.
- **Go straight to tickets** — when the MVP door is two-way and no constraint or open question names a technical unknown, running `piv-slice <the PRD's path>`, here or in a fresh session, is fine; say that it's a shortcut, not the default.