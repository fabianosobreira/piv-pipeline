# Spec: Rate limiting for the public API

Status: reviewed
Intent-slug: rate-limiting
Language: en-US
Last updated: 2026-10-14
Context sources: package.json, .github/workflows/ci.yml

## 1. Goal and context
- Limit abusive clients on the public API to protect availability. (Source: Q1)

## 2. Non-goals
- Per-user quotas are out of scope. (Source: Q2)

## 3. Functional requirements
- FR-01 (Source: Q3): WHEN a client exceeds 100 requests per minute THE SYSTEM SHALL respond with HTTP 429.
- FR-02 (Source: Q4): WHEN a request is rejected THE SYSTEM SHALL include a Retry-After header.

## 4. Acceptance criteria
- AC-01 (FR-01, Source: Q6): Given a client with 100 requests in the last minute When it sends request 101 Then the response status is 429.
- AC-02 (FR-02, Source: Q7): Given a rejected request When the response is read Then Retry-After is present and greater than 0.

## 5. Non-functional requirements
- NFR-01 (Source: Q5): Added latency p95 below 5 ms at 1000 requests per second.

## 6. Technical constraints
- C-01 (Source: Q8): Node 20 and vitest, as declared in package.json.

## 7. Design
- D-01 (Source: Q9): Middleware in src/middleware/rate-limit.js following the pattern of src/middleware/auth.js.

## 8. Boundaries and open questions
### Always
- Run `npm test` before finishing. (Source: Q11)
### Ask first
- Adding a dependency. (Source: Q11)
### Never
- Edit test files that exist at the base commit. (Source: Q11)
### Open questions
- [DEFERRED] Redis-backed counters for multi-instance deployment. (Source: Q12)

## 9. Verification
| AC | Command | Pass criterion | Origin |
|---|---|---|---|
| AC-01 | `npx vitest run tests/rate-limit.test.js` | exit code 0 | package.json:7 |
| AC-02 | `npx vitest run tests/rate-limit.test.js` | exit code 0 | package.json:7 |

## Appendix: Decision log
| Q | Phase | Question | User answer | Chosen option |
|---|---|---|---|---|
| Q1 | 1 | Goal | Protect availability | A |
| Q2 | 1 | Non-goals | No per-user quotas | A |
| Q3 | 2 | FR-01 | 100 requests per minute | A |
| Q4 | 2 | FR-02 | Retry-After header | A |
| Q5 | 3 | Latency budget | p95 below 5 ms | A |
| Q6 | 2 | AC for FR-01 | Confirmed | A |
| Q7 | 2 | AC for FR-02 | Confirmed | A |
| Q8 | 3 | Stack | Node 20, vitest | A |
| Q9 | 4 | Design | Middleware | A |
| Q11 | 5 | Boundaries | Confirmed | A |
| Q12 | 5 | Open questions | Redis deferred | defer |
