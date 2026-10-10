# Architecture — <intent name>

- **Intent-slug**: <intent-slug>
- **Language**: <the PRD's `Language`, copied verbatim; with no PRD, the BCP 47 tag of the language this interview ran in, such as pt-BR>
- **Intent**: <the PRD's location as `docs/ISSUE-TRACKER.md` defines it (local path, or its published URL once published), or "none" when there is no PRD — an idea, a brief or a research doc is never named here>

## Problem & goals
<one paragraph: the user goal this serves (from the intent) — the lens every decision below is judged against, and what fundamentally has to be true for this to work. With no PRD, what the idea, brief or research doc said, carried here in full enough to slice from, and the success metrics it states>

## Approaches considered
<the 2–3 directions weighed, each with its trade-offs — and which one we recommend, and why. Close each direction we're not taking with the literal label **Rejected alternative(s):** so a downstream agent can tell decided from discarded without reading between the lines. The same label closes every discarded option in the sections below>

## Recommended approach
<the chosen direction in a few sentences — the shape of the solution. Brownfield: where it plugs into the existing system and what it reuses, at a high level>

## Key decisions
<one sub-section per menu item this work actually raised, named after the menu item it came from — **Building blocks**, **Data model**, **Boundaries & contracts**, **Operational shape**, **Testability**, **Other eng-lead calls**. State each decision as prose under its own ID, `D<n>`, assigned when the decision is first raised; a decision table labels each row `D<n>·<row label>`. An ID is never renumbered or reused, so a revised doc can leave IDs out of order, and a dropped decision's number is retired. A call made without the user closes with the literal label **(decided-by-default)**, and one the user accepted on a recommendation with no basis closes with **(no basis)**>

## Behavior changes vs today
<brownfield only: for each rule this work replaces, the checks the code runs today (`path:line`) and what happens to each — kept, changed or dropped; or "none", with the one-line reason no rule is replaced>

## Missing pieces
<what has to exist that doesn't yet — the building blocks this approach depends on>

## Spikes & experiments
<the calls that are both uncertain and expensive to undo, to de-risk first, each in the Question / Spike / Decision rule form the *Spikes* section of the skill's `SKILL.md` gives; or "none", with the one-line reason no call is both>

## Open questions
<decisions deliberately left open — named, not hidden — and what would settle each>
