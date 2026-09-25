# Git conventions

How this project names branches and writes commits. The skills read this file instead of deciding for themselves.

## Base branch

The base branch is whichever branch the remote treats as its default. Ask the remote; only when the remote gives no answer, fall back to `main`.

## Branch names

Work gets built on its own branch, named `<tag>/<ticket-id>-<short-slug>`:

- **`<tag>`** — the same conventional tag the commits will carry (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, …).
- **`<ticket-id>`** — the ticket id, lowercased and stripped of the punctuation branch names reject: `#123` → `123`, `PROJ-123` → `proj-123`, `PLUGGABLE-INGESTION-1` → `pluggable-ingestion-1`. No ticket → drop this segment.
- **`<short-slug>`** — two to four words of the title.

`piv-commit-changes` and `piv-create-pr` read the ticket id back out of this name, so the id has to survive the stripping.

## Commit subjects

`<tag>: <atomic description> (<ticket id>)` — around 72 characters, imperative mood, lowercase, ending on the last word (no trailing period). `<tag>` is the conventional tag the work earns, as *Commit tags* below defines it. The `(<ticket id>)` suffix closes the subject whenever there is an id: the one handed to you, or the one the branch name carries. Write the id in the form `docs/ISSUE-TRACKER.md` defines for the tracker in use; with no file to consult, write it exactly as it reached you. PR titles carry the same shape.

## Commit tags

This repo ships skills: its markdown is the product, not documentation of it. Pick the tag by what the change does to the agent that loads the file, never by the file's extension:

- **`feat`** — the agent does something it didn't before: a new step, template, artifact, GATE or STOP, or a new rule in a doc it reads.
- **`fix`** — an instruction that led the agent wrong: a contradiction between skills or with a doc they read, a broken reference, a dead end, a rule that can't be met.
- **`refactor`** — rewording or restructuring that leaves what the agent does unchanged.
- **`docs`** — what only people read: `README.md`, `pages/`.
- **`chore`** — `tools/`, `.claude/settings*`, repo configuration.

The docs an agent loads — `CLAUDE.md`, `docs/PIV-LOOP.md`, `docs/MEMORY.md`, `docs/ISSUE-TRACKER*.md`, this file — count as skills, not as `docs`. A change that mixes effects is split into one commit per effect; when it can't be split, the largest effect names the tag.
