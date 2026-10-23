# Git conventions

How this project names branches and writes commits and PR titles.

## Base branch

The base branch is whichever branch the remote treats as its default. Ask the remote; only when the remote gives no answer, fall back to `main`.

**The base** is that branch's tip on the remote — `origin/main`, say — after a fetch, never the local copy, which lags whatever merged since the last pull. The remote is `origin`, else the only remote there is; a fetch that fails stops the run, and a project with no remote has the local branch as its base. A diff of the branch against the commit it forked from is taken against `git merge-base HEAD [the base]`; when that fails — a shallow clone, or a base branch the clone never fetched — stop and say what to fetch.

## Branch names

Each piece of work is built on one branch, shared by all its tasks, named `[tag]/[N]-[slug]` — for example `feat/142-rate-limiting`. It stays local until the PR is opened.

- **`[tag]`** — the conventional tag of the issue's type: `feature` → `feat`, `bug` → `fix`, `task` → `chore`. The commits on the branch carry the tag each one earns, which may differ.
- **`[N]`** — the number of the work's GitHub issue, without the `#`: `#123` → `123`.
- **`[slug]`** — a short kebab-case name for the work.

The issue number and the slug can be read back out of the branch name, so it has to survive that. Reading it back, put the `#` back: `123` → `#123`.

## Commit subjects

`[tag]: [atomic description] ([#N])` — around 72 characters, imperative mood, lowercase, ending on the last word (no trailing period). `[tag]` is the conventional tag the work earns, as *Commit tags* below defines it. The `([#N])` suffix closes the subject whenever there is an issue number: the one handed to you, or the one the branch name carries, written as GitHub writes it — `(#123)`. The number counts toward the length: shorten the description to fit, never the number. PR titles carry the same shape.

## Language

Commit subjects and commit bodies are written in en-US, whatever language the rest of the work is written in. The tag and the issue number stay as this file defines them.

## Commit tags

This repo ships skills: its markdown is the product, not documentation of it. Pick the tag by what the change does to the agent that loads the file, never by the file's extension:

- **`feat`** — the agent does something it didn't before: a new step, template, artifact, GATE or STOP, or a new rule in a doc it reads.
- **`fix`** — an instruction that led the agent wrong: a contradiction between skills or with a doc they read, a broken reference, a dead end, a rule that can't be met.
- **`refactor`** — rewording or restructuring that leaves what the agent does unchanged.
- **`docs`** — what only people read: `README.md`, `pages/`.
- **`chore`** — `tools/`, `.claude/settings*`, repo configuration.

The docs an agent loads — `AGENTS.md`, `CLAUDE.md`, `docs/piv-loop.md`, this file — count as skills, not as `docs`. The work of one task is one commit, tagged with its largest effect. Split off only a part that stands on its own — one that could be reverted without breaking the rest or leaving it pointless, like an unrelated fix found along the way. The tag names a commit; it never decides where commits split.
