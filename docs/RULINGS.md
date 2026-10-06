# Rulings — rules settled by the maintainer

Decisions the maintainer ruled on, recorded so a later session doesn't re-propose what was already settled. An entry is either a ruling with the alternative it refused, or a convention for editing this repo that no skill carries. Behavior a skill or a tracker doc already states stays there, not here. Each entry is a ruling: **change one only when the maintainer says to.**

## Who owns what in the pipeline

- **The epic is born in `piv-create-tickets` and is never an input to any skill.** No planning skill may take, name or depend on an epic; `piv-create-tickets` is the single point that creates it and publishes a plan.
- **`piv-create-tickets` takes a PRD from `piv-create-prd`, an architecture doc from `piv-create-architecture`, or both — nothing else.** Removed earlier rule: slicing an epic that already exists or a free-form brief — neither is a real scenario, and both loaded the skill with decisions it never needs.
- **An architecture doc's `Intent` names a PRD or says "none" — nothing else.** Refused: pointing the field at a brief or idea and having `piv-create-tickets` publish it as the intent — it publishes whatever the field names as the PRD.
- **A published plan is frozen.** Changing it after the tickets exist means a new PRD or architecture doc and a new `piv-create-tickets` run. Refused: documenting a manual revision procedure in the tracker docs, and giving revision an owning skill.
- **`piv-create-tickets` does not guard against a second epic for the same `Intent-slug`.** Not adopted: a STOP or a GATE after searching the tracker for an existing epic.
- **`piv-create-tickets` offers `piv-create-architecture` at a GATE before Step 1**, when it holds a PRD only and the work has real technical uncertainty. Refused: folding the offer into the Step 5 GATE — Steps 1-4 would already be spent slicing against a guessed architecture.
- **Every run downstream of `piv-create-tickets` carries a ticket id.** A skill that finds none asks for it at a GATE. Removed earlier rule: a plan document as `piv-implement-ticket`'s input, with reports named by `intent-slug` and deferrals found by the review report's path.
- **`piv-implement-ticket` names `piv-review-changes` flatly instead of offering a menu.** The asymmetry with the other six skills is deliberate — do not normalize it.

## Reports and the PR

- **The reports never travel with the PR.** Refused: attaching them, embedding them in collapsed `<details>`, committing them to the branch — `docs/.reports/` stays gitignored.
- **The PR body carries every surviving finding, including blocking, critical and high when the commit went ahead on a non-PASS verdict.** Refused: keeping the body to medium and low — it would show CHANGES REQUESTED with nothing to say why.
- **A fix round followed by a PASS review settles the implementation report's `PARTIAL` for the PR; a PASS alone does not.** Refused: having `piv-fix-findings` rewrite the implementation report (a run would edit another run's artifact), a GATE on the mismatch, and writing "none — resolved".
- **`piv-create-pr` never reads the ticket id from commit bodies.** Refused: keeping bodies as a source — a body mentioning another ticket would put its header block on the PR and close it at the merge.
- **The review report's *Checks run* is not a source for the PR's *Validation*.** Not adopted: a PASS already implies a green suite.
- **`piv-review-changes` does not read the PR body.** It runs before any PR exists; a reviewer's agent working from the PR sits outside the loop.
- **The fix report is overwritten each round; a re-review finds earlier deferrals on the tracker, through their link to the reviewed ticket.** Refused: accumulating the fix report's *Deferred* section across rounds.
- **The triage's default cut defers every low.** Refused: defaulting low to *Noise / won't-fix* — a low dropped without a deferral comes back every round. The asymmetry with the PASS path, which sends the same findings only to the PR body, is accepted.
- **A *Noise / won't-fix* ruling is evidence the re-review weighs, never a closure.** Refused: treating it as a prior decision that drops the finding outright, and ignoring it — a false positive ruled high would block PASS every round.
- **Test facts block the verdict outside the severity scale.** Not adopted: mapping the blocking kinds onto `high` — they are observed, not judged.
- **A blocking finding is never deferred.** Refused: allowing the deferral — a deferred red test would reach PASS still red.
- **A test confirmed red on the base becomes `medium` with the `coverage` class.** Refused: mapping it to `bug` — the `bug` proof, a test failing without the fix, is circular for a test already red.
- **A project with no test suite is held to no test.** Removed earlier rule: gating the implementation on the missing suite, and asking whether the ticket or a prerequisite ticket sets one up. Not adopted: one `medium` "no test suite" finding — every review would raise it and every triage would open a duplicate deferral.
- **`piv-implement-ticket` STOPs on a ticket with no actionable tasks.** Reclassified from a GATE asking what to implement — that opened scope outside the ticket.
- **`piv-commit-changes` gates on the verdict; `piv-create-pr` does not.** Not adopted: having `piv-create-pr` open a draft on a non-PASS verdict, alone or alongside the commit gate.

## Skills vs. tracker docs

- **Anything tracker-specific belongs in `docs/ISSUE-TRACKER.md`, never inside a skill.** The tracker is swappable; a skill that branches on which tracker is in use is a defect — it delegates the procedure instead.
- **A branch name keeps the ticket id's case.** Refused: lowercasing the id and restoring the tracker's form on the way back — nothing named the restore, a lowercased id misses the report files on a case-sensitive filesystem, and Jira/Git integrations match on the key as Jira writes it.
- **A deferral is a ticket, created by the same *Creating a ticket* rules as every other.** Its origin goes in the body's `## Origin`, not a new header field — the header block stays the ticket contract. Refused: appending the deferral to the epic's *Tickets* list — `piv-create-tickets` is the one owner of the epic's body.
- **A ticket carries no group.** Removed earlier rule: a group label on every ticket — a ticket with no group read as an error, and the fix reached for was creating a label.

## Skill-writing conventions

- **Every "stop and ask, then carry on" in the skills was converted to `GATE` deliberately.** The remaining `STOP`s are the terminal ones. Don't reclassify either direction without a ruling.

## Working style

- **Resolve open decisions before editing.** When rulings conflict with each other or leave a fork, put the fork to the maintainer with a recommendation and wait — do not pick and proceed.
- **Reviewing this repo is not policing its working tree.** Untracked scratch files and a missing `.gitignore` are not findings.
