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
No findings.

### Low
- **The window length is the literal `60000` in two places** — `src/middleware/rate-limit.js:14` · quality · introduced
  - **Evidence**: `src/middleware/rate-limit.js:14` and `:27` both hold `60000`.
  - **Impact**: changing the window means editing two literals, and one can be missed.
  - **Fix**: extract a `WINDOW_MS` constant in `src/middleware/rate-limit.js`.

## Dropped by prior ruling
None.

## Checks run
- `npx vitest run` on the branch → 4 passed.
- Lint: no linter configured.
