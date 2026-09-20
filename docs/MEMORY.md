# Memory — rules settled by the maintainer

Decisions the maintainer ruled on, recorded so a later session doesn't re-propose what was already settled. `CLAUDE.md` holds the house rules and `docs/PIV-LOOP.md` the loop's vocabulary; what follows is neither — it is the set of calls that were made **against** a plausible alternative, with the alternative named so nobody walks back into it. Each entry is a ruling: **change one only when the maintainer says to.**

## Who owns what in the pipeline

- **`piv-create-prd` and `piv-create-architecture` know nothing about the epic.** They write local files under `docs/.plans/` and stop. The epic does not exist yet at that point in the loop, and neither skill may depend on one.
- **`piv-create-tickets` is where the epic is born.** It takes the local PRD and architecture doc as input, creates the epic, publishes both onto it, fills the epic's `Intent` and `Architecture`, and only then creates the tickets. It is the single point in the loop that publishes a plan, and the reason later steps point at the epic rather than at a local doc.
- **`piv-implement-ticket` names `piv-review-changes` flatly instead of offering a menu.** That asymmetry with the other six skills is deliberate, not an oversight — do not normalize it.

## Skills vs. tracker docs

- **Anything tracker-specific belongs in `docs/ISSUE-TRACKER.md`, never inside a skill.** The tracker is swappable — `ISSUE-TRACKER-jira.md`, `ISSUE-TRACKER-gitlab.md`, `ISSUE-TRACKER-md.md` are the alternatives a project copies over it. A skill that branches on which tracker is in use is a defect; it delegates the procedure instead.
- **Where plans get published is a per-tracker decision.** GitHub: comments on the epic, identified by the doc's own `#` heading. GitLab and Jira: **attachments** on the epic, identified by the file name. Markdown tracker: plans stay local, nothing is published.
- **Templates stay inside their own skill's `templates/` directory.** Extracting them into a shared `docs/templates/` was proposed and refused.

## Artifact format

- **Header block, not YAML front matter.** Every artifact opens with a markdown list of bold labels — `- **Intent-slug**: …` — one field per line, directly under the title. Front matter renders as a stray heading in an issue body; a list renders the same in a file and in a tracker.
- **`Intent-slug`, `Intent` and `Architecture` always get their own line.**
- **The PRD never points at itself**: it is the intent, so it carries `Intent-slug` alone. The epic carries all three, born with the local paths and repointed to the published URLs once the plans are on it.
- **Template placeholders are `<...>`**, in every template. Not `{...}`, not `[...]`. Literal illustrative values (`` `path/to/file.py:42` ``, `PASS | CHANGES REQUESTED`) are not placeholders and stay as they are.

## Skill-writing conventions

- **All eight skills carry `disable-model-invocation: true`**, and their descriptions carry no `Use when …` clause.
- **No command examples.** Write the instruction in prose — "post each as an issue comment", not a `gh` invocation. Naming the tool a tracker is reached with is fine; spelling out its flags is not.
- **Centralizing vocabulary in `PIV-LOOP.md` does not license deleting the repetitions from the skills.** A skill restating a loop rule is carrying it into the run that needs it; leave it.
- **Every "stop and ask, then carry on" in the skills was converted to `GATE` deliberately.** The remaining `STOP`s are the terminal ones. Don't reclassify either direction without a ruling.
- `## Output` may legitimately contain numbered process steps when the output *is* those steps, as in `piv-create-tickets`.

## Working style

- **The maintainer rules item by item.** A review is delivered as a markdown report with `- [ ]` checkboxes and a **User comment** field per item; they tick what to implement, leave the rest blank, and annotate. Implement only `[x]`, resolve every filled comment, ignore `[ ]`.
- **Resolve open decisions before editing.** When rulings conflict with each other or leave a fork, put the fork to them with a recommendation and wait — do not pick and proceed.
- **Reviewing this repo is not policing its working tree.** Untracked scratch files and a missing `.gitignore` are not findings.
