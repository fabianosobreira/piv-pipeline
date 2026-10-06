# Skill-writing rules

Rules for writing any document an agent consumes — a skill, a template, a tracker doc, `CLAUDE.md`. The goal is a predictable run: the agent takes the same _process_ every time, not that it produces the same output.

## Context pointers

A **context pointer** is a line in the agent's context that names out-of-context material and states when to reach it — a skill's `description`, a line in `CLAUDE.md` naming a doc. Its wording, not its target, decides how reliably the agent reaches the material.

- **A pointer states what the material is and lists its branches** — the distinct cases that should trigger reaching it.
- **One trigger per branch.** Collapse synonyms that rename the same branch.
- **Front-load the leading word.**
- **Cut identity the body already carries.** Every word of an always-loaded pointer costs on every turn.
- **When must-have material is reached unreliably, sharpen the pointer first.** Inline the material only if sharpening fails.

## The two loads

- **Context load** — what always-loaded material costs the agent's window every turn, whether or not it fires.
- **Cognitive load** — what the human pays to remember which documents exist and when to reach for each. Spend it where human judgement matters; remove it where it does not.
- Material behind a pointer pays only for the pointer's line. Material with no pointer rides entirely on cognitive load.

## Information hierarchy

A document mixes **steps** (ordered actions) and **reference** (definitions, rules, facts consulted on demand). Place each piece on the ladder by how immediately the agent needs it:

1. **In-file step** — what the agent does, in order.
2. **In-file reference** — consulted on demand. A flat peer-set of rules on one rung is fine.
3. **Disclosed reference** — a separate file behind a pointer, loaded only when the pointer fires.

- **Inline what every branch needs; disclose what only some branches reach.** This is the test for progressive disclosure.
- **Disclose reference that buries steps.** Buried steps get attended to by coin-flip.
- **Co-locate.** A concept's definition, rules and caveats sit under one heading. The document should read like documentation written for the agent.
- **Cure sprawl with the ladder, not by trimming live lines.** Disclose reference behind pointers, and split by branch or sequence so each path carries only what it needs.
- **A skill runs to about 100 lines or fewer.** A guide, not a hard limit: past it, check whether reference should be disclosed or the skill split by sequence.
- **Write a reference doc an agent loads as terse rules the run can apply** — `PIV-LOOP.md` is one. The rule over its explanation, a short list over a table, no cost walkthroughs, examples or lists of what goes wrong. The explaining belongs in `pages/`.

## Steps and completion criteria

- **Every step ends on a completion criterion** — the condition that tells the agent the step is done.
- **Make the criterion clear.** A vague bound ("understanding reached") invites premature completion, pulled by the post-completion steps in view.
- **Make the criterion demanding.** "Every modified model accounted for" forces legwork that "produce a change list" does not. Demand binds reference too: "every rule applied" carries an exhaustiveness bar into an all-reference document.
- **The strongest criteria are both checkable and exhaustive.**
- **`## Output` may contain numbered process steps when the output _is_ those steps**, as in `piv-create-tickets`.
- **Against premature completion, sharpen the bound first.** Hide later steps by splitting only when the bound is irreducibly fuzzy and the rush is observed — and only across a real context boundary (a hand-off or a subagent dispatch). An inline call clears nothing.

## When to split

A split spends one of the two loads; make the cut earn it.

- **By sequence** — split a run of steps when the post-completion steps tempt the agent to rush the current one. Merging sequences does the reverse and invites premature completion.
- **By invocation** — split off a model-invoked skill only when a distinct leading word you actually use should trigger it on its own, or another skill must reach it. The new always-loaded description has to be worth its context load.

## Leading words

A **leading word** is a compact concept already in the model's pretraining that the agent thinks with while running the document (_lesson_, _fog of war_, _tracer bullets_). It anchors execution in the body and invocation in a pointer, and it anchors invocation best when the same word lives in the prompts, the docs and the code.

- **Repeat the token, never the sentence.** The word accumulates a distributed definition.
- **Reach for an existing word before coining one.** A coined word recruits no priors; it must be defined, and the definition costs tokens.
- **Hunt restatements and collapse them into one word.** "fast, deterministic, low-overhead" → _tight_; "a loop you believe in" → _red_, which turns a fuzzy gate into a binary observable state.
- **A skill says "ticket", never "issue", and assumes no labels.** It names the tracker item a _ticket_, the epic "an epic of its own" when the tracker keeps one, and a ticket's classification its _type_; "issue" and "label" are one tracker's words and survive only in `docs/ISSUE-TRACKER*.md`. A problem is a _problem_ — the reports say *Problems encountered* and *Open problems*.
- **Prompt the positive.** State the target behaviour ("write one-line comments"); a prohibition makes the forbidden behaviour more available. Keep a prohibition only as a hard guardrail with no positive phrasing, and pair it with the positive target.

## Pruning

- **Keep each meaning in a single source of truth.** Duplication costs maintenance and tokens and inflates the meaning's rank on the ladder. A leading word repeats a token on purpose; duplication repeats a meaning.
- **A skill restating a `PIV-LOOP.md` rule is not duplication.** It carries the rule into the run that needs it; centralizing vocabulary in `PIV-LOOP.md` does not license deleting it.
- **A skill carries its own reasons.** `RULINGS.md` is local to this repo and never ships with the skills, which run in other projects' repos. A ruling recorded there still needs its rationale inside the skill that applies it; a reason living in both places is not duplication.
- **Leave lookups to the environment.** `package.json` scripts, config files, directory layout and `--help` output are sources of truth; restating them is a cache that goes stale. Cache only what looking cannot find: the unwritten convention, the reason behind a choice, the gotcha no config confesses.
- **No command examples.** Write the instruction in prose — "post each as an issue comment", not a `gh` invocation. Naming the tool a tracker is reached with is fine; spelling out its flags is not.
- **Check every line for relevance.** A line loses it by never bearing on the task (exposition, or a branch that should be disclosed) or by going stale. Prune so stale layers do not settle into sediment.
- **Delete no-ops.** A sentence the model already obeys by default says nothing. The test — does it change behaviour versus the default? — is settled by running the document, not by debate. Delete the whole sentence rather than trimming words.
- **Replace a leading word too weak to beat the default with a stronger one** (_be thorough_ → _relentless_).

## Templates

- **Templates stay inside their own skill's `templates/` directory.**
- **An artifact opens with a header block, not YAML front matter.**
- **Template placeholders are `<...>`**, in every template — not `{...}`, not `[...]`. Literal illustrative values (`` `path/to/file.py:42` ``, `PASS | CHANGES REQUESTED`) are not placeholders. The rule reaches every block a skill hands the run to fill — the hypothesis, the JTBD line, the spike — not only the files under `templates/`.
- **Template headings are sentence case** — `Problem statement`, `Target user & JTBD`. Acronyms keep their capitals, and a skill citing a heading cites it in the same case.

## Skill mechanics

- **Model-invoked skill** — omit `disable-model-invocation` and write a model-facing `description` carrying the trigger branches; the pointer rules above apply in full. It pays permanent context load for discoverability, and other skills can reach it. An all-reference model-invoked skill can host reference several skills share.
- **User-invoked skill** — set `disable-model-invocation: true`; the `description` becomes a one-line human-facing summary with no trigger list. Zero context load; the human is the index, and no other skill can reach it.
- **Pick model-invocation only when the agent or another skill must reach the skill on its own.** Otherwise make it user-invoked.
- **Put reference shared by user-invoked skills in a plain file outside the skill system** that each skill points at — neither skill can fire the other.
- **When user-invoked skills outgrow memory, add a router skill**: one user-invoked skill that names the others and when to reach for each. It can only hint, never fire them.
