# Git conventions

How this project names branches and writes commits. The skills read this file instead of deciding for themselves.

## Base branch

The base branch is whichever branch the remote treats as its default. Ask the remote; only when the remote gives no answer, fall back to `main`.

**The base** is that branch's tip on the remote — `origin/main`, say — after a fetch, never the local copy, which lags whatever merged since the last pull. The remote is `origin`, else the only remote there is; a fetch that fails stops the run, and a project with no remote has the local branch as its base. A diff of the branch against the commit it forked from is taken against `git merge-base HEAD [the base]`; when that fails — a shallow clone, or a base branch the clone never fetched — stop and say what to fetch.

## Branch names

Each intent is built on one branch, shared by all its tasks, named `[tag]/[N]-[intent-slug]` — for example `feat/142-rate-limiting`. `piv-implement` creates it on the intent's first task, from the issue number `piv-slice` wrote into `Issue`, and writes its name into `Branch` in `.piv/[intent-slug]/epic.md`. It stays local until `piv-open-pr` pushes it.

- **`[tag]`** — the conventional tag of the issue's type: `feature` → `feat`, `bug` → `fix`, `task` → `chore`. The commits on the branch carry the tag each one earns, which may differ.
- **`[N]`** — the number of the intent's GitHub issue, without the `#`: `#123` → `123`.
- **`[intent-slug]`** — the intent's slug, the name of its folder under `.piv/`.

`piv-implement`, `piv-review`, `piv-fix`, `piv-commit`, `piv-open-pr` and `piv-review-pr` read the issue number and the intent-slug back out of this name, so it has to survive it. Reading it back, put the `#` back: `123` → `#123`; the intent-slug locates `.piv/[intent-slug]/`.

## Commit subjects

`[tag]: [atomic description] ([#N])` — around 72 characters, imperative mood, lowercase, ending on the last word (no trailing period). `[tag]` is the conventional tag the work earns, as *Commit tags* below defines it. The `([#N])` suffix closes the subject whenever there is an issue number: the one handed to you, or the one the branch name carries, written as GitHub writes it — `(#123)`. The number counts toward the length: shorten the description to fit, never the number.

## PR titles

The same shape as a commit subject: `[tag]: [concise description] ([#N])`.

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

The work of one task is one commit, tagged with its largest effect. Split off only a part that stands on its own — one that could be reverted without breaking the rest or leaving it pointless, like an unrelated fix found along the way. A PR whose commits carry different tags takes the largest effect among them.
