## The PIV Loop

📖 **Full manual:** https://fabianosobreira.github.io/piv-pipeline/

Plan → Implement → Verify. Eight skills that carry an idea from a blank page to a pull request a human can approve — one deliberate step at a time.

### What the PIV loop is

**PIV** stands for **plan → implement → verify**. It is the shape this project's skills run work through.

- **Plan** turns an idea into a spec and a set of tickets.
- **Implement** builds one ticket on its own branch and writes an implementation report.
- **Verify** tries to prove the change wrong before it ships: a review writes findings, a triage run settles each one, and only then is the work committed and handed to a human.

Two properties hold the whole thing together. **Every step reads the artifact the step before it wrote** — the reports are not paperwork, they are the input. And **every step is started by you**, never by the step before it.

> **The core idea** — Nothing chains itself. Each skill finishes by telling you the next move; you decide whether to run it. That is what keeps a bad plan from becoming a merged PR while you were away.

### The chain at a glance

- **Plan** — `piv-spec` → `piv-slice`
- **Standalone** — `piv-write-prd` writes a PRD that only `piv-spec` reads, as optional context
- **Implement** — `piv-implement`
- **Verify** — `piv-review` → `piv-fix` → `piv-commit` → `piv-open-pr`
  **The loop closes on a PASS.** `piv-fix` always hands back to a fresh `piv-review`. Only a PASS verdict earns a commit.

Read the arrows as *"this is the next move offered"*, not as automation. The three verify skills before the PR are the gate; the PR itself is the handoff out of the loop, to a human who reviews, approves and merges.

### Set up the loop first

Install the skills from the root of your project with one command. It needs Node.js and git, on Windows with Git Bash, macOS or Linux, and it installs for Claude Code only:

```
npx skills@1.7.2 add fabianosobreira/piv-pipeline#releases -s '*' -a claude-code --copy -y
```

- **Commit the lock file with the skills.** The command writes `skills-lock.json` at the project root; commit it together with `.claude/skills/`.
- **Keep your own files out of the `piv-*` folders.** Each `.claude/skills/piv-*/` folder is replaced whole on every run, so a file you add there is deleted.
- **A failed install is recovered by running the command again.**
- **To update, run the same command again.** It pins no version: it installs the current state of the `releases` branch, and the lock file records only the hash installed. To pin a version by hand, replace `#releases` with `#vX.Y.Z`.

Then run `/piv-setup`. It installs the docs the skills read: `docs/piv-loop.md`; `docs/issue-tracker.md` for your tracker — GitHub, GitLab, Jira, or local markdown files; `docs/git-conventions.md`, merged with the git rules your `CLAUDE.md`, `AGENTS.md` or commit tooling already set; and a `docs/.gitignore` that keeps the plans and the reports on your machine. It ends by showing the commit message and committing only when you say so.

### Where do I start?

You rarely need all eight. Find the row that matches what you have in hand.

| What you have | Start with | Why |
| --- | --- | --- |
| A product idea, nothing written | `piv-write-prd` | Optional: pin the *what and why* down before the spec. |
| A PRD, or just a clear idea of the change | `piv-spec` | One interview fixes requirements, design, tasks and verification in a spec; a PRD is optional context. |
| A spec marked ready | `piv-slice` | Each ticket is a verbatim slice of the spec, so nothing is invented between the plan and the work. |
| A ticket id ready to build | `piv-implement` | A ticket carries the part of the spec it needs, so the loop picks one up from its id alone. |
| Work built on a branch, not yet committed | `piv-review` | This is the gate that decides whether the change earns a commit. |
| A review report with findings | `piv-fix` | Findings are input, not a work order — you rule on each one. |
| A PASS verdict | `piv-commit` | Atomic commits, then the PR. |

## License

MIT — see `LICENSE`.
