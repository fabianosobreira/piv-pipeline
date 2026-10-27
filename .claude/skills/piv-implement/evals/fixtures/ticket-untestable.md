- **Spec**: .piv/rate-limiting/spec.md @ 77c3c9cdf53be34e77c291fc806119caa44837be
- **Task**: T-01
- **Title**: Notify the on-call channel on repeated rejections
- **Type**: feature
- **Blocked by**: none
- **Size**: S
- **DoD**: AC-01, AC-02
- **Cites**: FR-01, FR-02, C-01, D-01
- **Intent-slug**: rate-limiting
- **Language**: en-US

## 1. Goal and context
- Limit abusive clients on the public API and alert the on-call team when one keeps being rejected. (Source: Q1)

## 2. Non-goals
- Per-user quotas are out of scope. (Source: Q2)

## 3. Functional requirements
- FR-01 (Source: Q3): WHEN a client exceeds 100 requests per minute THE SYSTEM SHALL respond with HTTP 429.
- FR-02 (Source: Q4): WHEN a client is rejected 10 times in a minute THE SYSTEM SHALL post a message to the on-call Slack channel through the Slack webhook.

## 4. Acceptance criteria
- AC-01 (FR-01, Source: Q6): Given a client with 100 requests in the last minute When it sends request 101 Then the response status is 429.
- AC-02 (FR-02, Source: Q7): Given a client rejected 10 times in a minute When the 10th rejection happens Then the on-call Slack channel receives one message naming the client.

## 5. Non-functional requirements
None in this ticket.

## 6. Technical constraints
- C-01 (Source: Q8): Node 20 and vitest, as declared in package.json. The Slack webhook is a real external service; the sample API has no fake or stub for it.

## 7. Design
- D-01 (Source: Q9): Middleware in src/middleware/rate-limit.js following the pattern of src/middleware/auth.js, calling the webhook at the URL in `SLACK_WEBHOOK_URL`.

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
| AC-02 | `npx vitest run tests/rate-limit.test.js` | exit code 0 | package.json:7 |

## Appendix: Decision log
| Q | Phase | Question | User answer | Chosen option |
|---|---|---|---|---|
| Q1 | 1 | Goal | Protect availability and alert on-call | A |
| Q2 | 1 | Non-goals | No per-user quotas | A |
| Q3 | 2 | FR-01 | 100 requests per minute | A |
| Q4 | 2 | FR-02 | Slack alert after 10 rejections | A |
| Q6 | 2 | AC for FR-01 | Confirmed | A |
| Q7 | 2 | AC for FR-02 | Confirmed | A |
| Q8 | 3 | Stack | Node 20, vitest | A |
| Q9 | 4 | Design | Middleware | A |
| Q11 | 5 | Boundaries | Confirmed | A |
