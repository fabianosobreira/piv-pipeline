# Git conventions

How this project names branches and writes commits. The skills read this file instead of deciding for themselves.

## Base branch

The base branch is whichever branch the remote treats as its default. Ask the remote; only when the remote gives no answer, fall back to `main`.

**The base** is that branch's tip on the remote — `origin/main`, say — after a fetch, never the local copy, which lags whatever merged since the last pull. The remote is `origin`, else the only remote there is; a fetch that fails stops the run, and a project with no remote has the local branch as its base. A diff of the branch against the commit it forked from is taken against `git merge-base HEAD [the base]`; when that fails — a shallow clone, or a base branch the clone never fetched — stop and say what to fetch.

## Branch names

Work gets built on its own branch, named `[tag]/[ticket-id]-[short-slug]`:

- **`[tag]`** — the same conventional tag the commits will carry (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, …).
- **`[ticket-id]`** — the ticket id in the form `docs/issue-tracker.md` defines, case kept, with only the leading `#` dropped: `#123` → `123`, `PROJ-123` and `PLUGGABLE-INGESTION-1` stay as they are. Keeping the case is what lets the id match the tracker's own form and the report file names built from it.
- **`[short-slug]`** — two to four words of the title.

`piv-review`, `piv-fix`, `piv-commit` and `piv-open-pr` read the ticket id back out of this name, so the id has to survive it. Reading it back, put the `#` back when the tracker's form carries one: `123` → `#123`.

## Commit subjects

`[tag]: [atomic description] ([ticket id])` — around 72 characters, imperative mood, lowercase, ending on the last word (no trailing period). `[tag]` is the conventional tag the work earns, as *Commit tags* below defines it. The `([ticket id])` suffix closes the subject whenever there is an id: the one handed to you, or the one the branch name carries. Write the id in the form `docs/issue-tracker.md` defines for the tracker in use; with no file to consult, write it exactly as it reached you. The id counts toward the length: shorten the description to fit, never the id. PR titles carry the same shape.

## Language

Commit subjects and commit bodies are written in en-US, whatever the intent's language. The ticket's `Language` does not apply to them. The tag and the ticket id stay as this file defines them.

## Commit tags

This repo ships skills: its markdown is the product, not documentation of it. Pick the tag by what the change does to the agent that loads the file, never by the file's extension:

- **`feat`** — the agent does something it didn't before: a new step, template, artifact, GATE or STOP, or a new rule in a doc it reads.
- **`fix`** — an instruction that led the agent wrong: a contradiction between skills or with a doc they read, a broken reference, a dead end, a rule that can't be met.
- **`refactor`** — rewording or restructuring that leaves what the agent does unchanged.
- **`docs`** — what only people read: `README.md`, `pages/`.
- **`chore`** — `tools/`, `.claude/settings*`, repo configuration.

The docs an agent loads — `AGENTS.md`, `CLAUDE.md`, `docs/piv-loop.md`, `docs/rulings.md`, `docs/issue-tracker*.md`, this file — count as skills, not as `docs`. The work of one ticket is one commit, tagged with its largest effect. Split off only a part that stands on its own — one that could be reverted without breaking the rest or leaving it pointless, like an unrelated fix found along the way. The tag names a commit; it never decides where commits split.
