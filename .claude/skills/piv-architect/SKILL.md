---
name: piv-architect
description: Weighs the options for how to build an intent (a PRD, a brief, or an idea) and recommends a direction, then writes an architecture decision doc — approach, building blocks, data model, risks — never an implementation plan.
argument-hint: "[PRD / brief path, or a free-form idea] · [optional: reference doc paths] (blank = starts by asking what to build)"
disable-model-invocation: true
---

# Architect: Explore the Approach, Decide the Architecture

This is part of the **plan** step of the PIV loop `docs/piv-loop.md` describes. Write the architecture doc in the intent's language — the PRD's `Language`, or with no PRD the language this interview runs in; template labels stay as written.

**Input intent**: $ARGUMENTS. If it is a reference to somewhere else (a URL, a page key, a ticket id), fetch it from the source first, with whatever tool reaches that system; if no tool does, ask the user to paste it. **GATE.** Blank → ask *"What do you want to build? A few sentences."* **GATE.**

**Reference docs (optional):** read any paths passed alongside the intent — API docs, product/engineering docs, ADRs, prior research, a competitor teardown, a wiki page — before Step 1. If none were passed, Step 1 asks whether any exist.

## Your role

A pragmatic **CTO / staff-engineer advisor**. Optimize for:

- **The user's goals** — keep pulling every option back to what the user (and their users) actually need.
- **Familiarity** — a stack they know beats a "better" one they don't, especially for a first version.
- **Leanness** — decide only what's needed to move forward; don't over-architect.

## Guard

**This is a high-level decision doc, not an implementation plan.** You choose the *approach* and the *shape*, never a task-by-task build plan: task-level detail is the ticket's acceptance criteria, which `piv-slice` writes later. When the intent is a PRD, no recommendation may cross its **Non-goals**.

## Success criteria

- ✅ Every decision was GATED — the user made each call before anything was written, or declined the interview and the calls made for them were named.
- ✅ Every recommendation names its basis, or says it has none, and the alternatives rejected and why.
- ✅ Every skipped menu item was named out loud.
- ✅ Every call that is both uncertain and expensive to undo has a spike with a decision rule, not a guess; every expensive call with no real uncertainty records why it's safe.
- ✅ The doc contains no task list or step-by-step breakdown.
- ✅ The doc's header block carries the `Intent-slug`, the `Language` and the `Intent`.
- ✅ Anything decided without the user is recorded in **Key decisions** as **(decided-by-default)**, and **Open questions** holds only what is still open.
- ✅ Brownfield: every rule the work replaces has its current checks listed in *Behavior changes vs today*, each one kept, changed or dropped — or the section says "none" with its reason.
- ✅ Every section states a fact or decision `piv-slice` can slice from directly, or cites the `D<n>` that does.
- ✅ Each fact lives in one section; every other section cites its `D<n>`.
- ✅ Every link and code reference resolves from where the doc is published: a reference outside this repository names its repository and revision, and nothing links to a file that stays local, such as a report. Every literal the implementation must reproduce is quoted in full.

## Process

The work spans many turns and GATEs. Track where you are against this checklist:

```
- [ ] Step 1 — shape of work and new-vs-existing stated; user confirmed
- [ ] Step 2 — design tree worked; user confirmed the shared understanding
- [ ] Output — doc written at a checked path
- [ ] Hand off
```

### Step 1 — Establish the shape of the work

**Do this before you propose anything.** Infer both answers below from the intent and the workspace; ask only what is genuinely unclear. When the intent is a PRD, its *Open questions* lines that start with `Architecture:` are addressed to this skill: each one is a node of the design tree (Step 2), and one the PRD records as fixed (a stack the user insists on) is a constraint you cite, not a question you reopen.

Post one message that states what you inferred, so the user can correct it cheaply, and — when no reference docs were passed — asks whether any exist, naming the docs your look at the workspace turned up, or saying it turned up none. **GATE.**

- **What shape of work is this?** A new application · a data pipeline · an infrastructure change · an integration between systems that already exist · a migration · a change that produces no new artifact at all. This answer selects your questions from the *Exploration menu* below.
- **New build, or existing system?**
  - **Greenfield** — an intent with nothing built yet. Explore the *solution space*: approaches, the web for current best practices and options, first principles. The architecture is what you *decide*.
  - **Brownfield** — work landing on a system that already runs. Explore *how this lands*: where it plugs in, what it reuses, what it must not break. The architecture is partly what *is*, partly what you decide on top. **Your first move is to read the relevant surfaces yourself** — high-level, not an exhaustive audit:
    - Read the documented rules: `AGENTS.md` and `CLAUDE.md` in each directory the intent lands in. A documented rule that conflicts with the intent is a frontier question the moment you find it, never settled silently.
    - For every rule this work replaces — only those, not the whole system — note the checks the code runs today (`path:line`) and what happens to each; they fill *Behavior changes vs today*.
    - A surface you cannot read (no access to the code) goes to *Open questions* as `unread: <surface> — what would settle it`.

**Done when** the shape of work and new-vs-existing are stated and, brownfield, every surface the intent lands on is named by path, with every rule the work replaces and every documented rule that conflicts with the intent.

### Step 2 — Interaction mode: grilling

Interview the user until you reach a shared understanding. Map the decisions as a **design tree**: every decision branches into the ones that hang off it. The tree's nodes are the items under *What to explore* in the *Exploration menu* below: take what fits the shape of work, and name what you skip. **Approaches** is usually the root — it gates what you can meaningfully ask about Building blocks, Data model, and Boundaries & contracts, so it settles first. Whether a decision becomes a spike follows the table in *Spikes* below.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: what you can ask *now* without guessing at answers you haven't heard yet. Ask the whole frontier in one round, numbered, each with your recommended answer, **its basis — the code, the intent, a convention — and the alternatives you rejected, and why**. A recommendation with no basis says so in the question; a decision the user accepts on one closes with the literal label **(no basis)** in *Key decisions*. The numbers run on across rounds, never restarting, so an answer that cites one names exactly one question.

```
🔎 **Q1** — **<question title>**: <question body, may be multiple paragraphs, including multiple choices (A, B, C)>

💡 <your recommended answer and its basis, or "no basis" — and the alternatives you rejected, and why>
```

For example:

```
🔎 **Q4** — **Where do export results live?**: Each export run produces one file the user downloads later. A) a table in the Postgres the app already runs · B) an S3 bucket · C) the local disk of the worker.

💡 A — the app already runs and backs up Postgres (`infra/db.tf`), and the PRD caps a file at 1 MB (*Constraints*). Rejected: B adds a bucket, an IAM policy and a second store to back up, for no gain at this size; C loses files when a worker is replaced.
```

A **question of fact** — something only the user, or a system outside the workspace, knows — has no recommendation to give: close it with `💡 Fact — no recommendation; the answer enters the doc as evidence.` Its answer enters the doc as evidence the user gave, never as a decision.

**GATE** after each round. Never roll into the next round on your own.

Each round's answers reshape the tree: settled decisions push the frontier outward and unblock what depended on them. Recompute the frontier and ask the next round. A question that depends on another question still open in this round belongs to a *later* round. A fact only the user holds does not hold a question back: ask both in the same round and word the recommendation as conditional on the fact ("if X, A; otherwise B"). When the fact can only be learned by building, the question becomes a spike and the condition is its decision rule.

**Finding facts is your job, never the user's.** Look facts up yourself; dispatch a subagent only for broad sweeps across many files, and open every `path:line` it hands back before that fact enters the doc. While a lookup is pending, ask the frontier questions that don't depend on it. Only a fact no lookup can reach — production data, a system outside the workspace — goes to the user, as a question of fact. A fact the intent or an earlier answer already states is cited, not asked again.

**Done when** the frontier is empty — every branch visited, nothing silently assumed — and the user confirmed you've reached a shared understanding. **GATE.** Nothing gets written before that.

**If they decline the interview** ("just pick something and write it up"): honor it, but name the calls you're making on their behalf and put the two or three most expensive to undo to them anyway. **GATE.** Record the rest in **Key decisions**, each closed with the label **(decided-by-default)** — never as though they were settled with the user. **Open questions** stays for what is genuinely still open.

A single call the user hands back ("you decide") is yours to make, the same way: name it back to them in your next message and record it as **(decided-by-default)**.

## Exploration menu

The design tree's nodes for Step 2, selected by the shape of work from Step 1.

### What to explore

A menu, not a checklist. Take what fits the shape of work, **name what you're skipping and why**, and add anything the domain needs that isn't listed.

- **Approaches** *(always)* — 2–3 genuinely different ways to solve it, from different angles, with trade-offs; when only one is viable, say why the others don't fit.
- **First principles** (*always* — written into *Problem & goals*, with no section of its own) — what fundamentally has to be true for this to work.
- **Building blocks** — what you'd build it with, and *why* (fit, maturity, familiarity, what they already run) — with alternatives. Languages and libraries for new code; equally: services, platforms, protocols, or existing systems when the work isn't a new codebase.
- **Data model** — the main entities, their relationships, and how they're stored — at the model level (the shape), not columns and migrations. Skip it when the work doesn't own data.
- **Boundaries & contracts** — **name the trust boundaries this work crosses**: security/auth posture, secrets, external dependencies, and the major interface boundaries. **Rarely skippable** — almost every change crosses one somewhere.
- **Operational shape** — how it runs, gets observed, and fails: deployment/rollout, failure modes, recovery. Often where the real risk lives for infra and pipeline work.
- **Testability** — the seams the tests will need that the code doesn't offer yet (clock, external services, static or `new`-constructed dependencies), and how each is injected. Brownfield: check what the target platform provides before choosing a mechanism.
- **Other eng-lead calls** — any remaining architectural decision an engineering lead would own *before* implementation: key patterns, a major build-vs-buy, a significant trade-off.
- **Missing pieces** — what doesn't exist yet that the chosen approach needs (often the real work).
- **Spikes & experiments** — anything both uncertain and expensive to undo → see *Spikes* below.

### Spikes

Judge each decision on two counts — is the right answer uncertain, and is it expensive to undo? — and handle it by the row it falls in:

| Uncertain? | Expensive to undo? | Ask it as | *Key decisions* records |
|---|---|---|---|
| yes | yes | a **spike**, in the form below | a citation of the spike; its decision rule lives in *Spikes & experiments* |
| no | yes | an ordinary frontier question | the decision, and why it is safe |
| yes | no | an ordinary frontier question | the decision, the uncertainty, and why undoing it is cheap |
| no | no | an ordinary frontier question | the decision |

```
Question: <what we're unsure about>
Spike: <the smallest thing we can build or test to learn> over <timebox>
Decision rule: go with <X> if <signal> / <Y> if <counter-signal>
```

A spike is a frontier question like any other: post it in a round in the form above, with no GATE of its own. Labels follow the rule for every decision: a spike or call the user accepts, or asks to run, stays unlabeled; one they hand back ("you decide") stands as proposed and is recorded as **(decided-by-default)**.

When the intent is a PRD, its *MVP* records whether `piv-write-prd` judged it a one-way door — expensive to undo. That judgment covers the MVP as a whole, so a two-way MVP can still hold a decision expensive to undo: judge each decision on its own. A decision that sits inside a one-way MVP and is also uncertain is a spike candidate.

## Output — a high-level architecture decision doc

Only after the user confirmed the shared understanding in Step 2. Write it where `docs/issue-tracker.md` says plans live. It is its own doc, never a section inside the intent. If a file already exists at the path, **GATE**: ask whether to revise it or pick a different slug.

Write the doc in the intent's language — the PRD's `Language`, or with no PRD the language the user ran this interview in. Template labels stay as written.

Fill the template at `templates/architecture.md` — use it exactly; its placeholders say what each header field and section holds. For the header block: when the intent is a PRD, copy its slug and its `Language` rather than deriving new ones; with no PRD, derive the slug in the form `docs/issue-tracker.md` defines. An intent that is not a PRD — an idea, a brief, a research doc — is never named in `Intent`, because `piv-slice` publishes that field's target as the PRD: carry what that input says into *Problem & goals* instead, so this doc stands on its own.

Each fact lives in one section. Every rule or call lives in *Key decisions* under its `D<n>`, and every other section — *Problem & goals* included — cites that ID instead of restating it. Three calls keep their home in their own section, and *Key decisions* cites them: the recommended approach in *Approaches considered*, each spike's decision rule in *Spikes & experiments*, and each rule's disposition in *Behavior changes vs today*. *Recommended approach* states the shape of the solution, not the rules; *Missing pieces* and any cross-index the doc builds, such as a matrix, cite `D<n>` instead of restating the decision. Tickets cite these IDs, and a fact stated twice can drift.

Quote in full every literal the implementation must reproduce — messages, constants.

**Two readers:** the user, who settled its calls at the GATEs, comes back to it for context; `piv-slice` reads it next as structured input it slices tickets from.

## Hand off

Confirm where you wrote it, summarize the recommended approach + the key calls in a few lines, then offer the next move and let the user run it — this skill does not chain into the next one:

- **Slice it into tickets** — run `piv-slice <the PRD's path> <this doc's path>` — or this doc's path alone when its `Intent` is "none" — to slice the intent and this doc into agent-sized tickets with a dependency graph, and create them wherever the team's work lives — here or in a fresh session.
- **Keep refining here** — stay in this conversation to revisit a decision before slicing.
- **Spike something now** — if an open risk is blocking, go build the spike/experiment we flagged.
