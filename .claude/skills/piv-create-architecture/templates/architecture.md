# Architecture — <intent name>

- **Intent-slug**: <intent-slug>
- **Intent**: <the PRD's path, or "none" when there is no PRD — an idea, a brief or a research doc is never named here>

## Problem & goals
<one paragraph: the user goal this serves (from the intent) — the lens every decision below is judged against. With no PRD, what the idea, brief or research doc said, carried here in full enough to slice from>

## Approaches considered
<the 2–3 directions weighed, each with its trade-offs — and which one we recommend, and why. Close each direction we're not taking with the literal label **Rejected alternative(s):** so a downstream agent can tell decided from discarded without reading between the lines>

_That label is the rule for every section below too._

## Recommended approach
<the chosen direction in a few sentences — the shape of the solution. Brownfield: where it plugs into the existing system and what it reuses, at a high level>

## Key decisions
<one sub-section per menu item this work actually raised, named after the menu item it came from — **Building blocks**, **Data model**, **Boundaries & contracts**, **Operational shape**, **Other eng-lead calls**. State each decision as prose; a call made without the user closes with the literal label **(decided-by-default)**>

## Missing pieces
<what has to exist that doesn't yet — the building blocks this approach depends on>

## Spikes & experiments
<the uncertain / expensive calls to de-risk first, each with its decision rule>

## Open questions
<decisions deliberately left open — named, not hidden — and what would settle each>
