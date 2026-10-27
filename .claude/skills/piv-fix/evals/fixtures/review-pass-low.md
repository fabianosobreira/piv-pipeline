# Review report — T-01 — Implement the middleware

- **Intent-slug**: rate-limiting
- **Issue**: #12
- **Task**: T-01
- **Branch**: feat/12-rate-limiting
- **Round**: 1
- **Base**: 4f1c2a97d3e85b60c1a2f9e8d7b6a5c4e3f2a1b0
- **Diff hash**: 9c0e5d1a7b3f4826a1d0c9b8e7f6a5d4c3b2a190
- **Verdict**: PASS

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
No findings.

### Low
- **The map that holds each client's request count is named `cache`, which says nothing about what it holds** — `src/middleware/rate-limit.js:9` · quality · introduced
  - **Evidence**: `const cache = new Map(); // clientIp -> { count, windowStart }`
  - **Impact**: a reader looking for the cache policy finds a counter table; the next maintainer may add eviction that resets the counts.
  - **Fix**: rename `cache` to `requestCounts` in `src/middleware/rate-limit.js`.
- **The window length is the literal `60000` in two places** — `src/middleware/rate-limit.js:14` · quality · introduced
  - **Evidence**: `src/middleware/rate-limit.js:14` and `:27` both hold `60000`.
  - **Impact**: changing the window means editing two literals, and one can be missed.
  - **Fix**: extract a `WINDOW_MS` constant in `src/middleware/rate-limit.js`.

## Dropped by prior ruling
None.

## Checks run
- `npx vitest run` on the branch → 4 passed.
- Lint: no linter configured.
