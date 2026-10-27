# Spec: Rate limiting

Status: ready
Intent-slug: two-tasks
Language: en-US
Last updated: 2026-10-14
Context sources: none

## 1. Goal and context
- Show the slicing. (Source: Q1)

## 2. Non-goals
- Do not publish the spec. (Source: Q2)

## 3. Functional requirements
- FR-01 (Source: Q3): WHEN a client sends request 101 THE SYSTEM SHALL respond with HTTP 429.
- FR-02 (Source: Q3): WHEN a request is rejected THE SYSTEM SHALL include a Retry-After header.
- FR-03 (Source: Q4): WHEN the limiter is disabled THE SYSTEM SHALL pass all requests.
- FR-05 (Source: Q4): WHEN the limit resets THE SYSTEM SHALL accept requests again.

## 4. Acceptance criteria
- AC-01 (FR-01, FR-02, Source: Q6): Given 100 requests When request 101 arrives Then the status is 429.
- AC-02 (FR-01, FR-05, Source: Q6): Given a blocked client When the minute ends Then request 102 passes.
- AC-03 (FR-03, Source: Q6): Given the limiter is off When 200 requests arrive Then none is rejected.

## 5. Non-functional requirements
- NFR-01 (Source: Q5): Added latency p95 below 5 ms.

## 6. Technical constraints
- C-01 (Source: Q7): Node 20 and vitest.

## 7. Design
- D-01 (Source: Q8): Middleware in src/middleware/rate-limit.js.

## 8. Boundaries and open questions
### Always
- Run `npm test` before finishing. (Source: Q11)
### Ask first
- Adding a dependency. (Source: Q11)
### Never
- Edit test files. (Source: Q11)
### Open questions
- Should FR-01 count retries? (Source: Q12)
- Should FR-03 log a warning? (Source: Q12)
- None of the others. (Source: Q12)

## 9. Task plan
- T-01 (FR-01, FR-02, C-01, Source: Q9): Reject request 101 | Depends on: - | DoD: AC-01 and AC-02 pass.
- T-02 (FR-03, FR-05, NFR-01, D-01, Source: Q9): Add the off switch | Depends on: T-01 | DoD: AC-03 passes.

## 10. Verification
| AC | Command | Pass criterion | Origin |
|---|---|---|---|
| AC-01 | `npx vitest run a` | exit code 0 | Q10 |
| AC-02 | `npx vitest run b` | exit code 0 | Q10 |
| AC-03 | `npx vitest run c` | exit code 0 | Q10 |

## Appendix: Decision log
| Q | Phase | Question | User answer | Chosen option |
|---|---|---|---|---|
| Q1 | 1 | Goal | Show it | A |
| Q2 | 1 | Non-goals | No publishing | A |
| Q3 | 2 | FR-01 and FR-02 | Confirmed | A |
| Q4 | 2 | FR-03 and FR-05 | Confirmed | A |
| Q5 | 3 | Latency | p95 below 5 ms | A |
| Q6 | 2 | Acceptance criteria | Confirmed | A |
| Q7 | 3 | Stack | Node 20 | A |
| Q8 | 4 | Design | Middleware | A |
| Q9 | 6 | Tasks | Two tasks | A |
| Q10 | 6 | Commands | Confirmed | A |
| Q11 | 5 | Boundaries | Confirmed | A |
| Q12 | 5 | Open questions | Kept | A |
