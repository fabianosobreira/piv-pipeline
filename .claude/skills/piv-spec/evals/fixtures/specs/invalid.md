# Spec: [PENDING]

Status: ready
Intent-slug: rate-limiting
Language: en-US
Last updated: 2026-10-14
Context sources: package.json

## 1. Goal and context
This paragraph has no list bullet and no source.

## 2. Non-goals
- Per-user quotas are out of scope.

## 3. Functional requirements
- FR-01 (Source: Q3): WHEN a client exceeds 100 requests per minute THE SYSTEM SHALL respond with HTTP 429.
- FR-02 (Source: Q4): The API returns a Retry-After header.
- FR-03 (Source: Q5): WHEN the limiter is disabled THE SYSTEM SHALL pass all requests.

## 4. Acceptance criteria
- AC-01 (FR-01, Source: Q7): Given 100 requests When request 101 arrives Then status 429.
- AC-02 (Source: Q8): Given a rejected request When read Then Retry-After exists.
- AC-03 (FR-09, Source: Q8): Given X When Y Then Z.

## 5. Non-functional requirements
- NFR-01 (Source: Q6): The limiter must be fast and robust.

## 6. Technical constraints
- C-01 (Source: Q8): Node 20.

## 7. Design
- D-01 (Source: Q9): Middleware.
- D-01 (Source: Q9): Counter store.

## 8. Boundaries and open questions
### Open questions
- [DEFERRED] Redis counters. (Source: Q11)

## 9. Task plan
- T-01 (FR-01, C-09, Source: Q10): Implement the middleware | Depends on: - | DoD: tests pass.

## 10. Verification
| AC | Command | Pass criterion | Origin |
|---|---|---|---|
| AC-01 | `npx vitest run` | exit code 0 | |

## Appendix: Decision log
| Q | Phase | Question | User answer | Chosen option |
|---|---|---|---|---|
| Q3 | 2 | FR-01 | 100 per minute | A |
