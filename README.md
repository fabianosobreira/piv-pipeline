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

- **Plan** — `piv-create-prd` or/and `piv-create-architecture` → `piv-create-tickets`
- **Implement** — `piv-implement-ticket`
- **Verify** — `piv-review-changes` → `piv-fix-findings` → `piv-commit-changes` → `piv-create-pr`
  **The loop closes on a PASS.** `piv-fix-findings` always hands back to a fresh `piv-review-changes`. Only a PASS verdict earns a commit.

Read the arrows as *"this is the next move offered"*, not as automation. The three verify skills before the PR are the gate; the PR itself is the handoff out of the loop, to a human who reviews, approves and merges.

### Where do I start?

You rarely need all eight. Find the row that matches what you have in hand.

| What you have | Start with | Why |
| --- | --- | --- |
| A product idea, nothing written | `piv-create-prd` | You need the *what and why* pinned down before anyone argues about the how. |
| A PRD or an epic, and real technical uncertainty | `piv-create-architecture` | Decide the approach deliberately instead of letting tickets encode it by accident. |
| A clear intent with little technical risk | `piv-create-tickets` | A legitimate shortcut — just know you skipped the architecture step on purpose. |
| A ticket id ready to build | `piv-implement-ticket` | Tickets carry their own context, so the loop picks one up cold from its id alone. |
| Work built on a branch, not yet committed | `piv-review-changes` | This is the gate that decides whether the change earns a commit. |
| A review report with findings | `piv-fix-findings` | Findings are input, not a work order — you rule on each one. |
| A PASS verdict | `piv-commit-changes` | Atomic commits, then the PR. |

See `docs/PIV-LOOP.md` for the full description and `docs/ISSUE-TRACKER.md` for where each artifact lives.

## License

MIT — see `LICENSE`.
