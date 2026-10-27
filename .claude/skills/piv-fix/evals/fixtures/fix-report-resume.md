# Fix report — T-01 — Implement the middleware

- **Intent-slug**: rate-limiting
- **Issue**: #12
- **Task**: T-01
- **Branch**: feat/12-rate-limiting
- **Review**: .piv/rate-limiting/tasks/T-01/T-01.review.md
- **Round**: 1

## Fixed
- **The map that holds each client's request count is named `cache`, which says nothing about what it holds** — `src/middleware/rate-limit.js:9` → renamed `cache` to `requestCounts` · proof: `grep -nw cache src/middleware/rate-limit.js` → no match

## Deferred
None.

## Needs a human look
- **The window length is the literal `60000` in two places** — `src/util/window.js:4` → check by hand whether another module reads the same window before extracting a constant

## Noise / won't-fix
None.

## Checks run
- test: `npx vitest run` → green
