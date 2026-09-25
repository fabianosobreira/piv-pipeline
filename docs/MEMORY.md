# Memory — rules settled by the maintainer

Decisions the maintainer ruled on, recorded so a later session doesn't re-propose what was already settled. `CLAUDE.md` holds the house rules and `docs/PIV-LOOP.md` the loop's vocabulary; what follows is neither — it is the set of calls that were made **against** a plausible alternative, with the alternative named so nobody walks back into it. Each entry is a ruling: **change one only when the maintainer says to.**

## Who owns what in the pipeline

- **`piv-create-prd` and `piv-create-architecture` know nothing about the epic.** They write local files under `docs/.plans/` and stop. The epic does not exist yet at that point in the loop, and neither skill may depend on one.
- **The epic is `piv-create-tickets`' output, never the planning skills' input.** On an existing product, `piv-create-prd` and `piv-create-architecture` take whatever document carries the context — a research doc, a decision plan, the product's docs — and never name an epic as their input.
- **`piv-create-tickets` is where the epic is born.** It takes the local PRD and architecture doc as input, creates the epic, publishes both onto it, fills the epic's `Intent` and `Architecture`, and only then creates the tickets. It is the single point in the loop that publishes a plan, and the reason later steps point at the epic rather than at a local doc.
- **An architecture doc's `Intent` names a PRD or says "none" — nothing else.** An idea, a brief or a research doc handed to `piv-create-architecture` is carried into its *Problem & goals*, and the doc stands on its own. Pointing the field at the brief, and having `piv-create-tickets` publish it as the intent, was proposed and refused: `piv-create-tickets` publishes whatever the field names as the PRD.
- **`piv-implement-ticket` names `piv-review-changes` flatly instead of offering a menu.** That asymmetry with the other six skills is deliberate, not an oversight — do not normalize it.

## Reports and the PR

- **The reports never travel with the PR.** Not attached, not embedded in collapsed `<details>`, not committed to the branch — `docs/.reports/` stays gitignored. `piv-create-pr` distills them into the body, which is the single source for the human reviewer and for whatever agent that reviewer brings. Raw reports would hand that agent the first reviewer's framing instead of the code.
- **The PR body carries each surviving finding as severity, one-line claim and `file:line`** — never its evidence, impact or fix, for the same reason.
- **`piv-review-changes` does not read the PR body.** It runs right after `piv-implement-ticket`, on the uncommitted branch, before any PR exists. A reviewer's agent working from the PR sits outside the loop.
- **The fix report is overwritten each round, not accumulated.** `piv-create-pr` reads only the latest round. The user clears every *Needs a human look* item before the next review, and the PR lists the latest ones as flagged, never as checked. Deferrals are not listed in the body: it points at the deferral tickets linked to the ticket — or, with no ticket, at the tickets whose *Origin* names the review report's path — because a list built from the latest round alone would read as complete when it isn't.
- **The triage's default cut defers every medium and low, even though a PASS sends the same findings only to the PR body.** Defaulting low to *noise / won't-fix* was proposed and refused: a deferral is the only thing that closes a finding for the next review, so a low dropped without one comes back every round. The asymmetry with the PASS path is accepted.
- **A *Noise / won't-fix* ruling is evidence the re-review weighs, never a closure.** `piv-review-changes` reads the previous fix report's reason in its mitigation filter, and it drops the candidate only when the reason shows the problem is not there; "not worth fixing" admits the problem, so only a deferral settles it — the ruling above still holds. Treating *Noise* as a prior decision that drops the finding outright was proposed and refused, and so was ignoring it: a false positive ruled high would block PASS every round.
- **`piv-commit-changes` gates on the verdict; `piv-create-pr` does not.** Before committing, it reads the latest review report's verdict — and nothing else from the reports — and GATEs when it is not PASS, when there is no review report, or when a fix report is newer than it. Having `piv-create-pr` open a draft on a non-PASS verdict, alone or alongside the commit gate, was proposed and not adopted.

## Skills vs. tracker docs

- **Anything tracker-specific belongs in `docs/ISSUE-TRACKER.md`, never inside a skill.** The tracker is swappable — `ISSUE-TRACKER-jira.md`, `ISSUE-TRACKER-gitlab.md`, `ISSUE-TRACKER-md.md` are the alternatives a project copies over it. A skill that branches on which tracker is in use is a defect; it delegates the procedure instead.
- **A deferral is a ticket, and one set of rules creates every ticket.** The rules — where it lives, its header block, its type (`bug` / `feature` / `task`), its group, its epic, its `Acceptance criteria` heading — live under *Creating a ticket* in each tracker doc, and both `piv-create-tickets` and `piv-fix-findings` delegate to them. `piv-fix-findings` derives the type from the finding (`bug` or `task`, never `feature`), copies the reviewed ticket's group, epic and header block, links it to the reviewed ticket — so the PR body's pointer (above) and the re-review's prior-decision filter still find it — and fills its own `templates/deferral.md`. The origin goes in the body's `## Origin`, not a new header field, so the header block stays the ticket contract. A deferral does not touch the epic's body — neither its *Tickets* list nor its dependency graph, whose one owner is `piv-create-tickets`; it reaches the epic only through the epic link. Appending the deferral to the epic's *Tickets* list was proposed and refused.
- **A re-review finds earlier deferrals on the tracker, by link or by the review report's path.** With a ticket behind the review, the link to that ticket; with none, a search for the review report's path on the deferral's *Origin* `Review` line — each tracker doc says how under *Finding a review's deferrals*. Letting the fix report accumulate its *Deferred* section across rounds was proposed and refused, because it breaks the overwrite-each-round ruling above; so was accepting that a deferral from round 1 resurfaces in round 3 of work with no ticket.
- **Where plans get published is a per-tracker decision.** GitHub: comments on the epic, identified by the doc's own `#` heading. GitLab and Jira: **attachments** on the epic, identified by the file name. Markdown tracker: plans stay local, nothing is published.
- **Templates stay inside their own skill's `templates/` directory.** Extracting them into a shared `docs/templates/` was proposed and refused.

## Artifact format

- **Header block, not YAML front matter.** Every artifact opens with a markdown list of bold labels — `- **Intent-slug**: …` — one field per line, directly under the title. Front matter renders as a stray heading in an issue body; a list renders the same in a file and in a tracker.
- **`Intent-slug`, `Intent` and `Architecture` always get their own line.**
- **The PRD never points at itself**: it is the intent, so it carries `Intent-slug` alone. The epic carries all three, born with the local paths and repointed to the published URLs once the plans are on it.
- **Template placeholders are `<...>`**, in every template. Not `{...}`, not `[...]`. Literal illustrative values (`` `path/to/file.py:42` ``, `PASS | CHANGES REQUESTED`) are not placeholders and stay as they are. The rule reaches every block a skill hands the run to fill — the hypothesis, the JTBD line, the spike — not only the files under `templates/`.
- **Template headings are sentence case** — `Problem statement`, `Target user & JTBD`, `Success metrics`, `Open questions`. Acronyms keep their capitals (`PRD`, `MVP`, `JTBD`), and a skill citing a heading cites it in the same case. Keeping the mixed case because the terms already matched across artifacts was proposed and refused.

## Skill-writing conventions

- **All eight skills carry `disable-model-invocation: true`**, and their descriptions carry no `Use when …` clause.
- **No command examples.** Write the instruction in prose — "post each as an issue comment", not a `gh` invocation. Naming the tool a tracker is reached with is fine; spelling out its flags is not.
- **`PIV-LOOP.md` is a reference an agent loads, not documentation for people.** Write it as terse rules the run can apply: the rule over its explanation, a short list over a table, no cost walkthroughs, examples or lists of what goes wrong. The explaining belongs in `pages/`, where a human learns the loop; an addition to `PIV-LOOP.md` that reads like a manual goes there instead.
- **Centralizing vocabulary in `PIV-LOOP.md` does not license deleting the repetitions from the skills.** A skill restating a loop rule is carrying it into the run that needs it; leave it.
- **A skill carries its own reasons.** `MEMORY.md` is local to this repo and never ships with the skills, which run in other projects' repos. A ruling recorded here still needs its rationale inside the skill that applies it, so a reason living in both places is not duplication to prune.
- **Every "stop and ask, then carry on" in the skills was converted to `GATE` deliberately.** The remaining `STOP`s are the terminal ones. Don't reclassify either direction without a ruling.
- `## Output` may legitimately contain numbered process steps when the output *is* those steps, as in `piv-create-tickets`.

## Working style

- **Resolve open decisions before editing.** When rulings conflict with each other or leave a fork, put the fork to them with a recommendation and wait — do not pick and proceed.
- **Reviewing this repo is not policing its working tree.** Untracked scratch files and a missing `.gitignore` are not findings.
