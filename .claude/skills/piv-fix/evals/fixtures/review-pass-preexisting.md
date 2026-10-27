# Review report — T-01 — Implement the middleware

- **Intent-slug**: rate-limiting
- **Issue**: #12
- **Task**: T-01
- **Branch**: feat/12-rate-limiting
- **Round**: 1
- **Base**: 4f1c2a97d3e85b60c1a2f9e8d7b6a5c4e3f2a1b0
- **Diff hash**: 3e8f1b6a0d2c47958e1f3a4b5c6d7e8f90a1b2c3
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
- **The request logger writes the full `Authorization` header to the log** — `src/util/log.js:18` · security · pre-existing
  - **Evidence**: `logger.info({ headers: req.headers })` at `src/util/log.js:18`; reproduced on the Base in a worktree outside the repository, where a request with `Authorization: Bearer abc` logs the token.
  - **Impact**: anyone with log access can replay a user's token.
  - **Fix**: drop `authorization` from the logged headers in `src/util/log.js`.

### Low
No findings.

## Dropped by prior ruling
None.

## Checks run
- `npx vitest run` on the branch → 4 passed.
- Lint: no linter configured.
