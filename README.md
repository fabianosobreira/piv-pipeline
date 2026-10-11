## The PIV Loop

📖 **Full manual:** https://fabianosobreira.github.io/piv-pipeline/

Plan → Implement → Verify. Eight skills that carry an idea from a blank page to a pull request a human can approve — one deliberate step at a time.

### What the PIV loop is

**PIV** stands for **plan → implement → verify**. It is the shape this project's skills run work through.

- **Plan** turns an idea into an intent, an architecture and a set of tickets.
- **Implement** builds one ticket on its own branch and writes an implementation report.
- **Verify** tries to prove the change wrong before it ships: a review writes findings, a triage run settles each one, and only then is the work committed and handed to a human.

Two properties hold the whole thing together. **Every step reads the artifact the step before it wrote** — the reports are not paperwork, they are the input. And **every step is started by you**, never by the step before it.

> **The core idea** — Nothing chains itself. Each skill finishes by telling you the next move; you decide whether to run it. That is what keeps a bad plan from becoming a merged PR while you were away.

### The chain at a glance

- **Plan** — `piv-write-prd`, `piv-architect`, or both → `piv-slice`
- **Implement** — `piv-implement`
- **Verify** — `piv-review` → `piv-fix` → `piv-commit` → `piv-open-pr`
  **The loop closes on a PASS.** `piv-fix` always hands back to a fresh `piv-review`. Only a PASS verdict earns a commit.

Read the arrows as *"this is the next move offered"*, not as automation. The three verify skills before the PR are the gate; the PR itself is the handoff out of the loop, to a human who reviews, approves and merges.

### Set up the loop first

Copy `.claude/skills/` into your repo, then run `piv-setup`. It installs the docs the skills read: `docs/piv-loop.md`; `docs/issue-tracker.md` for your tracker — GitHub, GitLab, Jira, or local markdown files; `docs/git-conventions.md`, merged with the git rules your `CLAUDE.md`, `AGENTS.md` or commit tooling already set; and a `docs/.gitignore` that keeps the plans and the reports on your machine. It ends by showing the commit message and committing only when you say so.

### Where do I start?

You rarely need all eight. Find the row that matches what you have in hand.

| What you have | Start with | Why |
| --- | --- | --- |
| A product idea, nothing written | `piv-write-prd` | You need the *what and why* pinned down before anyone argues about the how. |
| A PRD whose MVP door is one-way, or that names a technical unknown | `piv-architect` | Decide the approach deliberately instead of letting tickets encode it by accident. |
| Any other PRD | `piv-slice` | A legitimate shortcut — just know you skipped the architecture step on purpose. |
| A ticket id ready to build | `piv-implement` | Tickets cite the architecture and the intent, so the loop picks one up from its id alone and reads the sources itself. |
| Work built on a branch, not yet committed | `piv-review` | This is the gate that decides whether the change earns a commit. |
| A review report with findings | `piv-fix` | Findings are input, not a work order — you rule on each one. |
| A PASS verdict | `piv-commit` | Atomic commits, then the PR. |

## License

MIT — see `LICENSE`.
