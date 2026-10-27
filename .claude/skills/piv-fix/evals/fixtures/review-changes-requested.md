# Review report — T-01 — Implement the middleware

- **Intent-slug**: rate-limiting
- **Issue**: #12
- **Task**: T-01
- **Branch**: feat/12-rate-limiting
- **Round**: 1
- **Base**: 4f1c2a97d3e85b60c1a2f9e8d7b6a5c4e3f2a1b0
- **Diff hash**: 7a2b6c1d9e0f4835b1c2d3e4f5a69788b9c0d1e2
- **Verdict**: CHANGES REQUESTED

## Scope
`src/middleware/rate-limit.js` (ADDED)
`tests/rate-limit.test.js` (ADDED)

## Findings

### Test facts
No findings.

### Critical
No findings.

### High
No findings.

### Medium
- **A client's counter is not reset when the window expires on the exact boundary second** — `src/middleware/rate-limit.js:27` · logic · introduced
  - **Evidence**: `if (now - entry.windowStart > WINDOW_MS)` at `src/middleware/rate-limit.js:27` leaves the counter alone when `now - entry.windowStart === WINDOW_MS`, so a client that sent 100 requests keeps getting 429 for one extra second.
  - **Impact**: a client is rejected after its window ended.
  - **Fix**: compare with `>=` and add a test for the boundary second.
- **The error handler answers 500 with the stack trace in the body** — `src/middleware/error.js:12` · security · pre-existing
  - **Evidence**: `res.status(500).send(err.stack)` at `src/middleware/error.js:12`; the Base has the same line.
  - **Impact**: a client sees file paths and internals of the server.
  - **Fix**: answer a generic message and log the stack.

### Low
No findings.

## Dropped by prior ruling
None.

## Checks run
- `npx vitest run` on the branch → 4 passed.
- Lint: no linter configured.
