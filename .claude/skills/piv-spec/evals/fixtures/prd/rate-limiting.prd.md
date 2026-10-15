# PRD — Rate limiting for the public API

- **Intent-slug**: rate-limiting
- **Language**: en-US

## Problem statement
Abusive clients send enough traffic to the public API to slow it down for everyone else, and the on-call engineer has no lever short of blocking a client by hand.

## Evidence
**Evidenced:** three latency incidents in the last quarter, each traced to one client sending more than 500 requests per minute.

## Thesis (why build it)
A public API that protects itself keeps every client's latency steady; today the cost of one noisy client lands on all of them.

## Hypothesis
If each client is held to a fixed request budget, the incidents caused by a single client stop, and no honest client notices.

## Target user & JTBD
The on-call engineer, who needs one noisy client to stop affecting the rest. Non-users: the clients themselves.

## Constraints
The budget applies to every client alike; no client sees another client's usage.

## MVP
One fixed budget per client on `/v1/items`. Two-way door: just build it.

## Success metrics
| Metric | Target | How it is measured |
|---|---|---|
| Incidents caused by a single client | 0 per quarter | incident log |

## Non-goals
Per-user quotas and billing tiers.

## Open questions
- [ ] TBD — needs validation: the budget per minute. Settled by the p95 of honest clients' traffic.
- [ ] `Architecture: where the counters live`, one process or shared between instances.
