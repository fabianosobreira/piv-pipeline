# Architecture — <intent name>

- **Intent-slug**: <intent-slug>
- **Intent**: <the PRD's path, or "none" when this was architected straight from an idea>

## Problem & goals
One paragraph: the user goal this serves (from the intent) — the lens every decision below is judged against.

## Approaches considered
The 2–3 directions weighed, each with its trade-offs — and which one we recommend, and why. Close each direction we're not taking with the literal label **Rejected alternative(s):** so a downstream agent can tell decided from discarded without reading between the lines.

_That label is the rule for every section below too._

## Recommended approach
The chosen direction in a few sentences — the shape of the solution.
(Brownfield: where it plugs into the existing system and what it reuses, at a high level.)

## Key decisions
One sub-section per menu item this work actually raised, named after the menu item it came from — **Building blocks**, **Data model**, **Boundaries & contracts**, **Operational shape**, **Other**. State each decision as prose.

## Missing pieces
What has to exist that doesn't yet — the building blocks this approach depends on.

## Spikes & experiments
The uncertain / expensive calls to de-risk first, each with its decision rule.

## Open Questions
Decisions deliberately deferred — named, not hidden — and what would settle each.
