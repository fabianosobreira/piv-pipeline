- **Spec**: .piv/rate-limiting/spec.md @ 77c3c9cdf53be34e77c291fc806119caa44837be
- **Task**: T-01
- **Title**: Implement the middleware
- **Type**: feature
- **Blocked by**: none
- **Size**: S
- **DoD**: AC-01
- **Cites**: C-01, C-02, D-01
- **Intent-slug**: rate-limiting
- **Language**: en-US

## 1. Goal and context
- Limit abusive clients on the public API to protect availability. (Source: Q1)

## 2. Non-goals
- Per-user quotas are out of scope. (Source: Q2)

## 3. Functional requirements
- FR-01 (Source: Q3): WHEN a client exceeds 100 requests per minute THE SYSTEM SHALL respond with HTTP 429.

## 4. Acceptance criteria
- AC-01 (FR-01, Source: Q6): Given a client with 100 requests in the last minute When it sends request 101 Then the response status is 429.

## 5. Non-functional requirements
None in this ticket.

## 6. Technical constraints
- C-01 (Source: Q8): Node 20 and vitest, as declared in package.json.
- C-02 (Source: Q10): The middleware keeps its counters in a module-level `Map`, overriding the project CLAUDE.md rule "No module-level mutable state".

## 7. Design
- D-01 (Source: Q9): Middleware in src/middleware/rate-limit.js following the pattern of src/middleware/auth.js, with the counters in a module-level `Map` (C-02).

## 8. Boundaries and open questions
### Always
- Run `npm test` before finishing. (Source: Q11)
### Ask first
- Adding a dependency. (Source: Q11)
### Never
- Edit test files that exist at the base commit. (Source: Q11)
### Open questions
None in this ticket.

## 9. Verification
| AC | Command | Pass criterion | Origin |
|---|---|---|---|
| AC-01 | `npx vitest run tests/rate-limit.test.js` | exit code 0 | package.json:7 |

## Appendix: Decision log
| Q | Phase | Question | User answer | Chosen option |
|---|---|---|---|---|
| Q1 | 1 | Goal | Protect availability | A |
| Q2 | 1 | Non-goals | No per-user quotas | A |
| Q3 | 2 | FR-01 | 100 requests per minute | A |
| Q6 | 2 | AC for FR-01 | Confirmed | A |
| Q8 | 3 | Stack | Node 20, vitest | A |
| Q9 | 4 | Design | Middleware | A |
| Q10 | 3 | Counter storage | Module-level Map, overriding the CLAUDE.md rule | A |
| Q11 | 5 | Boundaries | Confirmed | A |
