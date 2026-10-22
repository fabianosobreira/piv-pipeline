# Skill-writing rules

Rules for writing any document an agent consumes — a skill, a template, a doc under `docs/` the skills read, `CLAUDE.md` — that the guides in `docs/best-practices/` do not cover. Read those first; where a guide conflicts with this document, this document wins. The goal is a predictable run: the agent takes the same _process_ every time, not that it produces the same output.

## Language and wrapping

- Write `SKILL.md` and everything that ships with a skill in plain English with soft wraps: templates, disclosed references, examples, bundled scripts and their messages, and the labels and placeholders inside them.
- The artifacts a run writes follow the intent's language; only the template labels stay as the template writes them.

## Frontmatter and invocation

- `name`: `piv-[verb]-[object]`, or `piv-[verb]` when the verb alone names the skill.
- `description`: key use case first. No placeholders.
- A PIV step skill is **user-invoked**: set `disable-model-invocation: true` and write the `description` as a one-line human-facing summary. **The human starts every step.**
- A user-invoked skill's `description` carries no "Use when…" clause: it is never in the model's listing, and neighbouring skills named in it go stale.
- Make a skill model-invoked only when the agent or another skill must reach it on its own. Its `description` carries the trigger branches.
- Shared reference only the agent loads is a skill with `user-invocable: false`.
- Put reference shared by user-invoked skills in a plain file outside the skill system that each skill points at.
- When user-invoked skills outgrow memory, add a router skill: one user-invoked skill that names the others and when to reach for each.
- Take input through `$ARGUMENTS` (or `$0`, `$1`) and advertise it with `argument-hint`.
- `allowed-tools` lists the narrowest patterns the steps need (`Bash(git status *)`). `disallowed-tools` removes what the run must not call.
- A skill that must also run outside Claude Code uses only spec fields: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`.

## Context pointers

A **context pointer** is a line in the agent's context that names out-of-context material and states when to reach it — a skill's `description`, a line in `SKILL.md`, `AGENTS.md` or `CLAUDE.md` naming a doc.

- A pointer states what the material is and when to reach it, listing the distinct branches that trigger it.
- Use the words a user or a run actually produces for each branch. Collapse only restatements the author invented.
- Front-load the key use case.
- Cut how, keep what. The description names the capability; the body carries the procedure.
- When must-have material is reached unreliably, sharpen the pointer first. Inline the material only if sharpening fails.

## The two loads

- **Context load** — what the agent's window pays: the listing (model-invoked skills, every turn), the body (from invocation on), disclosed files (only when read). A bundled script costs only its output.
- **Cognitive load** — what the human pays to remember which documents exist and when to reach for each. Spend it where human judgement matters.

## Information hierarchy

A document mixes **steps** (ordered actions) and **reference** (definitions, rules, facts consulted on demand). Place each piece on the ladder by how immediately the agent needs it:

1. In-file step — what the agent does, in order.
2. In-file reference — consulted on demand.
3. Disclosed reference — a separate file behind a pointer.
4. Bundled script — executed, not read.

- Inline what every branch needs; disclose what only some branches reach.
- Disclose reference that buries steps.
- Co-locate. A concept's definition, rules and caveats sit under one heading.
- Put the goal, hard constraints and completion criterion at the top of `SKILL.md`.
- Past about 150 lines, disclose reference or split by sequence.
- Write a reference doc as terse rules the run can apply — `piv-loop.md` is one. Add an example only where it fixes a format the rule cannot state.

## Steps and completion criteria

- Every step ends on an observable completion criterion — not "understanding reached".
- Make the criterion exhaustive where the set is enumerable ("every modified model accounted for"); bound it where the set is open ("up to 5 risks").
- Name the validator that closes a feedback loop.
- Write guidance that spans the run as a standing instruction ("after every edit, run the tests").
- `## Output` may contain numbered process steps when the output _is_ those steps, as in `piv-slice`.
- Against premature completion, sharpen the bound first. Split only when the bound is irreducibly fuzzy and the rush is observed, and only across a real context boundary: the hand-off to the human, or a `context: fork` subagent.

## When to split

- By sequence — when the post-completion steps tempt the agent to rush the current one.
- By invocation — split off a model-invoked skill only when a distinct trigger should fire it, or another skill must reach it.
- By isolation — use `context: fork` only for a self-contained task; the skill names every input it reads.

## Wording

A **leading word** is a compact concept already in the model's pretraining that the agent thinks with while running the document (_lesson_, _fog of war_, _tracer bullets_).

- Repeat the token, never the sentence.
- Reach for an existing word before coining one.
- Collapse restatements into one word. "fast, deterministic, low-overhead" → _tight_; "a loop you believe in" → _red_.
- A skill says "ticket" for the local file of one task (`T-xx.md`) and "issue" only for the GitHub issue `piv-slice` publishes. It names a classification its _type_, and says "label" only for the GitHub label that carries the type on the issue and the PR. A problem is a _problem_ — the reports say *Problems encountered* and *Open problems*.
- State the target behaviour. Keep a prohibition only as a hard guardrail, paired with the positive target.
- Give the reason in one clause only when the rule needs it:
  - the agent must extend the rule to cases it does not name;
  - the rule overrides another rule or a plausible default.
  A reason that serves only the maintainer goes in `pages/`.
- Bound behaviour with observables, not intensity. Reserve emphasis (`ALWAYS`, `NEVER`, `MUST`) for the few rules where a deviation breaks a downstream consumer — an exact template structure, a fixed output format. State it once, at the rule, and pair it with the observable it protects.
- A rule that must hold every time and that a tool call can enforce is a hook or a `disallowed-tools` entry, not louder prose.

## Pruning

- Keep each meaning in a single source of truth. A leading word repeats a token on purpose; duplication repeats a meaning.
- A skill restating a `piv-loop.md` rule is not duplication — the rule travels with the run that applies it.
- A skill that cannot reach `docs/piv-loop.md` at run time — `piv-setup` — defines GATE in one line; every other skill points at the doc.
- A skill carries its own reasons. `rulings.md` never ships with the skills.
- Leave lookups to the environment. Cache only what looking cannot find: the unwritten convention, the reason behind a choice, the gotcha.
- Inject load-time state with `` !`command` `` instead of a step that runs it.
- Reach GitHub through `gh`: name the command, and leave its flags to the environment.
- Spell a command out only when it is fixed: a bundled script or a fragile sequence. Reference bundled files through `${CLAUDE_SKILL_DIR}`.
- Delete no-ops — a sentence whose removal changes nothing in an eval. Delete the whole sentence.

## Templates

- Templates stay inside their own skill's `templates/` directory.
- An artifact opens with a header block, not YAML front matter.
- Placeholders are `[...]` — not `<...>`, not `{...}` — in every template, script message, doc and `SKILL.md` that indicates a value to fill. Literal illustrative values (`` `path/to/file.py:42` ``), shell syntax (`<`, `<<`), HTML and the `Q<n>` of a decision log are not placeholders.
- Template headings are sentence case — `Problem statement`, `Target user & JTBD`.

## Bundled scripts

- Pre-approve exactly the script in `allowed-tools`.

## Evaluation

- Run each scenario in a fresh session.
- For a model-invoked skill, measure triggering apart from output.
- A reference file read every run belongs inline; a template stays in `templates/`.
