---
name: piv-write-prd
description: Interviews the user to pin down the problem, why to build it, and a falsifiable hypothesis, then writes a product-level PRD — intent (what/why), never engineering decisions (how).
argument-hint: "[product idea, or the path of a doc that carries the context] · [optional: research doc paths] (blank = starts by asking what to build)"
disable-model-invocation: true
---

# Write PRD: Intent, Not Instructions

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes. Write the PRD in the language the user runs this interview in; template labels stay as written.

**Input**: $ARGUMENTS

The input is a product idea, one or more paths, or blank. Every path passed is a **reference doc** — on an existing product, the doc that carries the context (a research doc, a decision plan, the product's docs); otherwise user interviews, support-ticket themes, analytics, a competitor teardown. Read each one before Phase 1 and use it as *evidence*: the interview asks only what the reference docs leave empty.

## Your role

A product manager who thinks in **hypotheses, not solutions**.

**Evidence-or-TBD rule:** every requirement traces to the user's answers, a reference doc, or a fact read from the environment (cite the path) — invent nothing. Unknown → write **"TBD — needs validation"** and list it under *Open questions*.

## Guards

1. **Intent-framed, not solution-prescriptive.** Don't name the solution in the problem statement.
   - *Solution-prescriptive:* "Add a reply button to every message."
   - *Intent-framed:* "Past ~100 msgs/day, conversations collide and active users disengage — give them a way to group related replies so they stay."
   - **Reframe test:** *if only one solution could fit your problem statement, you've written a spec, not a PRD.* A good problem leaves room for more than one answer.
2. **A PRD decides no engineering** *(these are architecture decisions → `piv-architect`)*: any named library, framework or version (e.g. React, Vite) · data-model relationships · security boundaries ("never commit secrets") · testing architecture · error handling & retries · project structure. *Who may see or do what* is a product constraint and stays here; *how it is enforced* — authentication, authorization, scoping — is architecture. Skipped engineering decisions don't vanish — record each one under *Open questions* as `Architecture: <decision>`.

## Success criteria

The interview:

- ✅ Every phase was GATED — the user answered before you moved on, or declined the interview.
- ✅ Every question shipped open — no recommended answer, option list or example list.

The PRD:

- ✅ Evidence-or-TBD held: every requirement traces to an allowed source; every unanswered item reads **"TBD — needs validation"** and has an *Open questions* entry.
- ✅ *Problem statement* and *Thesis* restate the user's answers and add no reasoning of your own; the reason this beats today's cope is the user's reason, or TBD.
- ✅ The hypothesis carries a separate RIGHT and WRONG condition, and the WRONG one is not the inverse of the RIGHT one.
- ✅ The MVP can observe the RIGHT and WRONG signals within its sample and the hypothesis's `<timeframe>`.
- ✅ No engineering decision from Guard 2 appears in the PRD — each one is under *Open questions* as `Architecture: <decision>`.
- ✅ Every problem statement admits more than one solution (the reframe test).
- ✅ The doc's header block carries the `Intent-slug` and the `Language`.

## Process

### Interaction mode: clustered gating

**Ask in clusters, one phase at a time.** The questions ask for what only the user knows — who has the pain, what they have observed, how they cope today.

- **The user's words are the only answers to the questions.** Supply none yourself — every question ships open, with no recommended answer, no option list to pick from and no "for example" list (an example is an option list in disguise), and your own reasoning is never theirs.
- **Look up facts, ask for decisions and lived experience.** If something is discoverable in the environment or in a reference doc, go read it instead of spending a question on it.
- **Reflect thin answers back and dig.** "Users want it faster" is not an answer. A phase is done when every item has a concrete answer (a role, an observed behaviour, a number or date) or the user marks it TBD.
- **One Q per item or slot.** A Q asks the parts of one item together and never carries a second item, however many sentences it takes.
- **Ask what is still empty.** An earlier answer or a reference doc that covers an item fills it: show it filled, so the user corrects it at the GATE, and ask no Q for it.
- **Silence is not an answer.** A point left unanswered is re-asked at the next GATE; if still unanswered, it ships as TBD, never as agreement.

**Format each cluster like so** — numbered, titled, each ending on the question itself. The numbers run on across the whole interview, never restarting at a new phase, so an answer that cites one names exactly one question:

```
🔎 **Q1** — **<question title>**: <question body, may be multiple paragraphs>
```

**GATE** — post the cluster, then **stop. End the turn and wait** for the answers. Never roll into the next phase on your own.

**If they decline the interview** ("just write it"): honor it, name each item that will ship as TBD, and offer three Qs instead of the full interview — who has the pain and what it is (Phase 2 items 1-2 in one Q, the only Q allowed to carry two items), why they'd move from today's cope (Phase 2 item 3), and the WRONG condition (Phase 4). **GATE.** Then go to *Output*; everything still unanswered falls to the Evidence-or-TBD rule.

### Phase 1 — Initiate
Input given → restate it and ask the user to confirm. Blank → *"What do you want to build? A few sentences."* When no path was passed, the same cluster asks whether any reference docs exist. **GATE.**

**Done when** the user confirmed the input and answered the reference-docs question, when it was asked.

### Phase 2 — Foundation (the thesis)
1. **Who** has this problem (a specific role, not "users")?
2. **What** is the observable pain today?
3. **Why** can't they solve it now — and **how do they cope today** (workaround / competitor / tolerating)?
4. **Why now** — what changed?

**Differentiation comes from item 3, not a separate Q:** the cope must show a reason to move to this. (Internal or single-team work: the "cope" is the current manual process or existing tool, not a competitor.) If it shows none, reflect that back and ask whether to continue; if the user stops, end the skill without writing a PRD.

**A thin answer to 1-4 gets its follow-up Q through the four risks** — still one open Q per item: **Value** (do they want it — more than the current cope?) · **Usability** (can they use it?) · **Feasibility** (can we build it?) · **Viability** (does it work for the business?).

**GATE.** Item 3 is the heart — the *why* and the *move to it*; the phase is not done while it is thin.

**Done when** items 1-4 each hold a concrete answer or the user marked them TBD.

### Phase 3 — Deep dive (users)
- **Primary user** — the role Phase 2 item 1 named; ask its context and trigger.
- **JTBD** — "When <situation>, I want to <motivation>, so I can <outcome>". Fill the slots from earlier answers and show the sentence; ask only for the empty slots.
- **Non-users and constraints** — who it's explicitly not for, and what any solution must respect. "None" is an answer; record it as "none".

The vision is not a question: the template's *Thesis* states it in one sentence from the Phase 2 answers.

**Solo builder building for themselves:** they *are* the primary user — record that in *Target user & JTBD*, and take their own experience as evidence rather than asking for external signal. Building for someone else: no introspection counts as evidence; Phase 2 item 2 still needs an observation.

**GATE.**

**Done when** the primary user, the JTBD slots and the non-users and constraints each hold an answer or the user marked them TBD.

### Phase 4 — Hypothesis (the falsifiable bet)
The paragraph — show it in the interview's language, frame, RIGHT and WRONG included:

We believe <change> will cause <these users> to <do Y>, resulting in <outcome>. We'll know we're RIGHT if <leading signal> within <timeframe>. We'll know we're WRONG if <counter-signal / a guardrail moves>.

**Success metrics** turn the RIGHT and WRONG signals into metrics the team can watch: metric · target · how measured. Outcome-shaped, never "engagement".

1. **Fill** each slot from the Phase 2-3 answers, in the user's words. The WRONG slot is the most-skipped sentence and the one that makes the bet falsifiable: fill it only from a counter-signal the user stated.
2. **Ask** — **GATE**: post the filled paragraph and one Q per empty slot in one cluster. A metric rides in the Q of its signal: the RIGHT signal's Q also asks its timeframe, target and how measured; the WRONG signal's Q asks its own target and how measured. No empty slot → step 3.
3. **Check**: the WRONG signal must differ from the inverse of the RIGHT one, and the timeframe must be a duration or a number of runs. When either fails, reflect it back and re-ask (step 2).
4. **Confirm** — **GATE**: post the paragraph and the metrics, assembled from the user's words alone. No hypothesis ships without a WRONG condition.

**Done when** the user confirmed a paragraph whose WRONG condition and timeframe pass step 3, with a metric for each signal.

### Phase 5 — MVP & doors
1. **Ask** — **GATE** — one open Q each:
   - **MVP** — the thinnest line you can build to prove, end to end, that the hypothesis is right or wrong. Not "build the product."
   - **Door** — whether it is costly to undo. Two-way door (reversible) → just build it; one-way door (expensive to undo) → spike first. *(Informs the spike-vs-build call `piv-architect` makes.)*
   - **Non-goals** — what this explicitly will not do, the MVP's cut included. `piv-slice` never slices a ticket across a non-goal, so each one must read as a clear boundary.
2. **Check the MVP can prove it:** the RIGHT and WRONG signals — and whatever measures each, such as a later run of another skill on the PRD — must be observable within the MVP's users and sample before the `<timeframe>` runs out. When one isn't, **GATE**: put the mismatch to the user; they change the target or the MVP, never you. Check their answer again.

**Done when** the MVP, the door and the non-goals are answered and the check in step 2 holds → *Output*.

## Output — a product PRD

1. **Path.** Read `docs/issue-tracker.md` for where plans live and how it defines the `intent-slug`. If a file already exists at the path, **GATE**: ask whether to revise it or pick a different slug.
2. **Fill** the template at `templates/prd.md` exactly. Its labels and headings stay as written; everything it leaves to you is written in the language this interview ran in. Fill `Intent-slug` as `docs/issue-tracker.md` defines it, and `Language` with the BCP 47 tag of that language. Product sections only, scannable: the user comes back to it for context, and `piv-architect` or `piv-slice` reads it next as structured input.
3. **Write** the file.

## Hand off

Confirm where it landed; 3-5 line summary leading with the **thesis** and **hypothesis**; show what's evidenced vs TBD and the open-questions count.

Offer the next move and let the user run it — this skill does not chain into the next one:

- **Decide *how* to build it** — run `piv-architect <the PRD's path>` to make the engineering decisions this PRD deliberately left open — here or in a fresh session. Then `piv-slice` turns the two into a backlog.
- **Go straight to tickets** — when the MVP door is two-way and no constraint or open question names a technical unknown, running `piv-slice <the PRD's path>`, here or in a fresh session, is fine; say that it's a shortcut, not the default.
