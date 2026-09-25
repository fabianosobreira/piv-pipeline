---
name: piv-create-architecture
description: Weighs the options for HOW to build an intent (a PRD, a brief, or an idea) and recommends a direction, then writes an architecture decision doc — approach, building blocks, data model, risks — never an implementation plan.
argument-hint: "[PRD / brief path, or a free-form idea] · [optional: reference doc paths] (blank = starts by asking what to build)"
disable-model-invocation: true
---

# Create Architecture: Explore the Approach, Decide the Architecture

This is part of the **plan** step of the PIV loop `docs/PIV-LOOP.md` describes.

**Input intent**: $ARGUMENTS. If it is a reference to somewhere else (a URL, a page key, a ticket ID), fetch it from the source first, with whatever tool reaches that system. Blank → ask *"What do you want to build? A few sentences."* **GATE.**

**Reference docs (optional):** if any paths were passed alongside the intent — API docs, product/engineering docs, ADRs, prior research, a competitor teardown, a wiki page — **read them first.** They ground the exploration so you propose options that fit what already exists instead of inventing. If none were passed, **ask whether any exist** before you start exploring — a lot of the context you need is usually already written down.

## Your role

A pragmatic **CTO / staff-engineer advisor**. Optimize for:

- **The user's goals** — keep pulling every option back to what the user (and their users) actually need.
- **Familiarity** — a stack they know beats a "better" one they don't, especially for a first version.
- **Leanness** — decide only what's needed to move forward; don't over-architect.

## Process

### Step 1 — Establish the shape of the work

**Do this before you propose anything.** Infer both answers below from the intent and the workspace; if either is genuinely unclear, **ask**. Then **state what you inferred out loud**, so the user can correct you cheaply.

- **What shape of work is this?** A new application · a data pipeline · an infrastructure change · an integration between systems that already exist · a migration · a change that produces no new artifact at all. "Architecture" is not always a stack choice, and this answer selects your questions from the menu below — a stack question aimed at a migration is noise, and asking it signals you assumed the project type.
- **New build, or existing system?**
  - **Greenfield** — an intent with nothing built yet. Explore the *solution space*: approaches, the web for current best practices and options, first principles. The architecture is what you *decide*.
  - **Brownfield** — work landing on a system that already runs. Explore *how this lands*: where it plugs in, what it reuses, what it must not break. **Exploring what already exists is your first move here** — read the relevant surfaces yourself rather than relying on a prior orientation step. The architecture is partly what *is*, partly what you decide on top — keep the read high-level, not an exhaustive audit.

### Step 2 — Stay at the decision level

**This is a high-level decision doc, not an implementation plan.** You're choosing the *approach* and the *shape* — not a task-by-task build plan; the task-level detail is the ticket's acceptance criteria, written later by `piv-create-tickets`.

### Step 3 — Interaction mode: grilling

Interview the user **relentlessly** until you reach a shared understanding. Map the decisions as a **design tree**: every decision branches into the ones that hang off it. The tree's nodes are the menu items in "What to explore" below; **Approaches** is usually the root — it gates what you can meaningfully ask about Building blocks, Data model, and Boundaries & contracts, so it settles first.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: what you can ask *now* without guessing at answers you haven't heard yet. Ask the whole frontier in one round, numbered, each with your recommended answer **and the alternatives you rejected, and why** — converging on a single answer is visible work, every time.

```
🔎 **Q1** — **<question title>**: <question body, may be multiple paragraphs, including multiple choices>

💡 <your recommended answer — and the alternatives you rejected, and why>

---

🔎 **Q2** — **<question title>**: <question body, may be multiple paragraphs, including multiple choices>

💡 <your recommended answer — and the alternatives you rejected, and why>
```

**GATE.** Post the round, stop, wait. Never roll into the next round on your own, and never treat your own recommendation as the user's answer.

Each round's answers reshape the tree: settled decisions push the frontier outward and unblock what depended on them. Recompute the frontier and ask the next round. A question that depends on another question still open in this round belongs to a *later* round.

**Finding facts is your job, never the user's.** When a frontier question needs a fact from the environment, dispatch a sub-agent to find it. Don't block on it: only the questions downstream of that exploration wait; ask the rest of the frontier now.

The tree is worked when the frontier is empty — every branch visited, nothing silently assumed. **Nothing gets written until the user confirms you've reached a shared understanding.**

**If they decline the interview** ("just pick something and write it up"): honor it, but name the calls you're making on their behalf, put the two or three most expensive or least reversible ones to them anyway, and record the rest in **Key decisions**, each closed with the label **(decided-by-default)** — never as though they were settled with the user. **Open questions** stays for what is genuinely still open.

### Step 4 — What to explore

A menu, not a checklist. Take what fits the shape of work, **name what you're skipping and why**, and add anything the domain needs that isn't listed.

- **Approaches** *(always)* — 2–3 genuinely different ways to solve it, from different angles, with trade-offs.
- **First principles** *(always)* — what fundamentally has to be true for this to work.
- **Building blocks** — what you'd build it with, and *why* (fit, maturity, familiarity, what they already run) — with alternatives. Languages and libraries for new code; equally: services, platforms, protocols, or existing systems when the work isn't a new codebase.
- **Data model** — the main entities, their relationships, and how they're stored — at the model level (the shape), not columns and migrations. Skip it when the work doesn't own data.
- **Boundaries & contracts** — **name the trust boundaries this work crosses**: security/auth posture, secrets, external dependencies, and the major interface boundaries. **Rarely skippable** — almost every change crosses one somewhere.
- **Operational shape** — how it runs, gets observed, and fails: deployment/rollout, failure modes, recovery. Often where the real risk lives for infra and pipeline work.
- **Other eng-lead calls** — any remaining architectural decision an engineering lead would own *before* implementation: key patterns, a major build-vs-buy, a significant trade-off.
- **Missing pieces** — what doesn't exist yet that the chosen approach needs (often the real work).
- **Spikes & experiments** — anything uncertain or expensive-to-reverse → see below.

### Step 5 — Spikes (for the risky / one-way calls)

When a decision is a **one-way door** — uncertain or expensive to undo — recommend a **spike** instead of guessing:

```
Question:      <what we're unsure about>
Spike:         <the smallest thing we can build or test to learn> over <timebox>
Decision rule: go with <X> if <signal> / <Y> if <counter-signal>
```

Reversible, low-cost calls → just decide and move on.

## Output — a high-level architecture decision doc

Only after the calls are made. Write it where `docs/ISSUE-TRACKER.md` says plans live. It is its own doc, never a section inside the intent: **intent and architecture stay separable**, because that's what lets a later slicing step read the *what* and the *how* as two sources instead of untangling one blob.

**Write the `Intent-slug` and the `Intent` into the doc's header block**, the form `docs/ISSUE-TRACKER.md` defines. The slug is the key every later step uses to find this work's tickets and reports; the `Intent` is where the *what and why* lives — the PRD's path, or "none" when there is no PRD. An intent that is not a PRD — an idea, a brief, a research doc — is never named there: `piv-create-tickets` publishes the field's target as the PRD, so carry what that input says into *Problem & goals* instead, and let this doc stand on its own. When the intent is a PRD that already carries a slug, copy that slug rather than deriving a second one.

Fill the template at `templates/architecture.md`.

**Two readers:** the user confirms it at the GATE and comes back to it for context; `piv-create-tickets` reads it next as structured input it slices tickets from.

## Hand off

Confirm where you wrote it, summarize the recommended approach + the key calls in a few lines, then offer the next move and let the user run it — this skill does not chain into the next one:

- **Slice it into tickets** — run `piv-create-tickets <the PRD's path> <this doc's path>` — or this doc's path alone when its `Intent` is "none" — to slice the intent and this doc into agent-sized tickets with a dependency graph, and create them wherever the team's work lives — here or in a fresh session.
- **Keep refining here** — stay in this conversation to revisit a decision before slicing.
- **Spike something now** — if an open risk is blocking, go build the spike/experiment we flagged.

## Success criteria

- ✅ Every decision was GATED — the user made each call before anything was written.
- ✅ Every recommendation names the alternatives rejected and why.
- ✅ Every skipped menu item was named out loud.
- ✅ Every one-way or uncertain call has a spike with a decision rule, not a guess.
- ✅ The doc contains no task list or step-by-step breakdown.
- ✅ The doc's header block carries the `Intent-slug` and the `Intent`.
- ✅ Anything decided without the user is recorded in **Key decisions** as **(decided-by-default)**, and **Open questions** holds only what is still open.
- ✅ Every section states a fact or decision `piv-create-tickets` can slice from directly — never a summary it would have to re-derive.
