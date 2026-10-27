# PR review — [the PR title]

- **Intent-slug**: [the epic's `Intent-slug`, copied verbatim]
- **Language**: [the epic's `Language`, copied verbatim]
- **PR**: [#N of the PR and its URL]
- **Spec**: [the spec path] @ [the output of `git hash-object --no-filters [the spec path]` at this review]
- **Remote check**: done | skipped by the user
- **Verdict**: CONFORMS | DIVERGES

## Coverage
| Item | Status | Evidence |
|---|---|---|
| [FR-xx, NFR-xx, C-xx, D-xx or AC-xx] | met \| diverges \| not verifiable | `path/to/file.py:42`, or why it cannot be verified from the PR |
[one row per FR, NFR, C, D and AC of the spec, in the spec's order]

## Divergences
[one block per item whose status is diverges, and per change outside the spec's scope — or "None."]

### [the item's ID, or "Out of scope"] — [critical | high | medium | low]
- **Spec**: [the item's line, copied verbatim from the spec; for an out-of-scope change, the task plan or non-goal it falls outside]
- **The PR**: [what the PR does instead]
- **Evidence**: `path/to/file.py:42` — [the quoted line or the traced path]

## Boundaries
[one line per non-goal of section 2 and per *Never* line of section 8, copied verbatim, then — respected, or — violated at `path/to/file.py:42`]

## Spec revision
- **Cited in the PR body**: [the hash after `@` in the body's `Spec` line, or "none"]
- **Current**: [the hash of the spec now]
- **Match**: [yes | no — the spec changed after the PR was opened, so the PR was built from another revision]
