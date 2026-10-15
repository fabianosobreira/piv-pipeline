# Git conventions

How this project names branches and writes commits. The skills read this file instead of deciding for themselves.

## Base branch

The base branch is whichever branch the remote treats as its default. Ask the remote; only when the remote gives no answer, fall back to `main`.

**The base** is that branch's tip on the remote — `origin/main`, say — after a fetch, never the local copy, which lags whatever merged since the last pull. The remote is `origin`, else the only remote there is; a fetch that fails stops the run, and a project with no remote has the local branch as its base. A diff of the branch against the commit it forked from is taken against `git merge-base HEAD [the base]`; when that fails — a shallow clone, or a base branch the clone never fetched — stop and say what to fetch.

## Branch names

Work gets built on its own branch, named `[tag]/[ticket-id]-[short-slug]`:

- **`[tag]`** — the same conventional tag the commits will carry, as *Commit tags* below defines it.
- **`[ticket-id]`** — the ticket id in the form `docs/issue-tracker.md` defines, case kept, with only the leading `#` dropped: `#123` → `123`, `PROJ-123` stays as it is. Keeping the case is what lets the id match the tracker's own form and the report file names built from it.
- **`[short-slug]`** — two to four words of the title.

`piv-review`, `piv-fix`, `piv-commit` and `piv-open-pr` read the ticket id back out of this name, so the id has to survive it. Reading it back, put the `#` back when the tracker's form carries one: `123` → `#123`.

## Commit subjects

`[tag]: [atomic description] ([ticket id])` — around 72 characters, imperative mood, lowercase, ending on the last word (no trailing period). `[tag]` is the conventional tag the work earns, as *Commit tags* below defines it. The `([ticket id])` suffix closes the subject whenever there is an id: the one handed to you, or the one the branch name carries. Write the id in the form `docs/issue-tracker.md` defines for the tracker in use; with no file to consult, write it exactly as it reached you. The id counts toward the length: shorten the description to fit, never the id.

## PR titles

The same shape as a commit subject: `[tag]: [concise description] ([ticket id])`.

## Commit tags

Pick the tag by what the change does to the project's behavior, never by the file's extension:

- **`feat`** — a new capability for the project's users.
- **`fix`** — behavior that diverged from what was specified or expected.
- **`refactor`** — restructuring that leaves behavior unchanged.
- **`perf`** — the same behavior, faster or lighter.
- **`test`** — tests only.
- **`docs`** — documentation only.
- **`build`** — the build system or dependencies.
- **`ci`** — the CI configuration.
- **`chore`** — anything else that touches no shipped behavior.

The work of one ticket is one commit, tagged with its largest effect. Split off only a part that stands on its own — one that could be reverted without breaking the rest or leaving it pointless, like an unrelated fix found along the way. A PR whose commits carry different tags takes the largest effect among them.
