## The PIV Loop

📖 **Full manual:** https://fabianosobreira.github.io/piv-pipeline/

Plan → Implement → Verify. Ten skills that carry an idea from a blank page to a pull request a human can approve — one deliberate step at a time, on your machine, with GitHub as the only remote.

### What the PIV loop is

**PIV** stands for **plan → implement → verify**. It is the shape this project's skills run work through.

- **Plan** turns an idea into a spec, audits it against your code and your GitHub issues and PRs, cuts it into one ticket per task, and publishes it as one GitHub issue.
- **Implement** builds one task at a time on the intent's branch and writes an implementation report.
- **Verify** tries to prove each task wrong before it is committed: a review writes findings, a triage run settles each one, and only then is the task committed. Once every task is in, the PR opens and is audited against the spec before a human merges it.

Two properties hold the whole thing together. **Every step reads the artifact the step before it wrote** — the reports are not paperwork, they are the input. And **every step is started by you**, never by the step before it.

> **The core idea** — Nothing chains itself. Each skill finishes by telling you the next move; you decide whether to run it. That is what keeps a bad plan from becoming a merged PR while you were away.

### The chain at a glance

- **Plan** — `piv-spec` → `piv-review-spec` → `piv-slice`
- **Per task** — `piv-implement` → `piv-review` → `piv-fix` (when the review asks for changes, or to optionally clear `low` findings after a PASS) → `piv-commit`
- **Ship** — `piv-open-pr` → `piv-review-pr`
- **Standalone** — `piv-write-prd` writes the intent as a PRD, an ordinary input of `piv-spec` (`piv-spec .piv/[intent-slug]/prd.md`)

**Each task closes on a PASS.** `piv-fix` hands back to a fresh `piv-review` — or to `piv-commit`, when the review was a PASS and the tree still matches it — and only a PASS verdict earns a commit. Tasks run one at a time, in the order the epic gives.

Read the arrows as *"this is the next move offered"*, not as automation. The PR is the handoff out of the loop, to a human who reviews, approves and merges.

### Local first, one issue, one PR

Everything the loop writes lives under `.piv/` at the root of your repo, ignored by git:

```
.piv/[intent-slug]/
  prd.md  spec.md  spec.review.md  epic.md  pr-review.md
  deferrals/D-01.md
  tasks/T-01/T-01.md  T-01.report.md  T-01.review.md  T-01.fixes.md
```

GitHub receives writes at two points only, through the `gh` CLI: `piv-slice` creates the issue, with the spec as its body, and `piv-open-pr` opens the PR that closes it on merge. Every other step works locally.

### Set up the loop first

Install the skills from the root of your project with one command. It needs Node.js and git, on Windows with Git Bash, macOS or Linux, and it installs for Claude Code only:

```
npx skills@1.7.2 add fabianosobreira/piv-pipeline#releases -s '*' -a claude-code --copy -y
```

- **Commit the lock file with the skills.** The command writes `skills-lock.json` at the project root; commit it together with `.claude/skills/`.
- **Keep your own files out of the `piv-*` folders.** Each `.claude/skills/piv-*/` folder is replaced whole on every run, so a file you add there is deleted.
- **A failed install is recovered by running the command again.**
- **To update, run the same command again.** It pins no version: it installs the current state of the `releases` branch, and the lock file records only the hash installed. To pin a version by hand, replace `#releases` with `#vX.Y.Z`.

Then run `/piv-setup`. It checks that `origin` is on GitHub and that `gh` is logged in, then installs the docs the skills read — `docs/piv-loop.md`, and `docs/git-conventions.md`, merged with the git rules your `CLAUDE.md`, `AGENTS.md` or commit tooling already set — and adds `.piv/` to your root `.gitignore`. It ends by showing the commit message and committing only when you say so.

### Where do I start?

You rarely need all ten. Find the row that matches what you have in hand.

| What you have | Start with | Why |
| --- | --- | --- |
| A product idea, nothing written | `piv-write-prd` | Pin the *what and why* down before the spec; it hands the PRD's path to `piv-spec`. |
| A PRD, or just a clear idea of the change | `piv-spec` | One interview fixes requirements, design, tasks and verification in a spec; pass the PRD's path as the input. |
| A spec marked ready | `piv-review-spec` | It checks the spec against your code and your GitHub issues and PRs before anything is published. |
| A spec marked reviewed | `piv-slice` | One ticket per task, each a verbatim slice of the spec, and one issue that publishes it. |
| An issue number | `piv-implement` | It picks the next task from the epic and builds it on the intent's branch. |
| A task built, not yet committed | `piv-review` | This is the gate that decides whether the task earns a commit. |
| A CHANGES REQUESTED verdict | `piv-fix` | Findings are input, not a work order — you rule on each one. |
| A PASS verdict with `low` findings | `piv-fix` (optional) | Fix, defer or leave each one; none blocks the commit. |
| A PASS verdict | `piv-commit` | Atomic commits for the task, then the next task — or the PR. |
| Every task committed | `piv-open-pr` | One PR for the whole intent, closing its issue on merge. |
| An open PR | `piv-review-pr` | It holds the PR to every item of the spec. |

## License

MIT — see `LICENSE`.
