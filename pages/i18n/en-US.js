// Every string the manual shows in en-US. manual.js reads this constant and
// renders it into the shell in index.html; nothing here touches the DOM.
// Inline marks: `code`, **bold**, *italic* and [text](#anchor).

const MANUAL_EN_US = {
  lang: 'en-US',

  meta: {
    title: 'PIV Loop — Skills Manual',
    description: 'Plan → Implement → Verify. Ten skills that carry an idea from a blank page to a pull request a human can approve.',
  },

  ui: {
    brand: 'PIV Loop Manual',
    skipLink: 'Skip to content',
    navLabel: 'Page navigation',
    menuOpen: 'Contents',
    menuClose: 'Close',
    languageLabel: 'Language',
    languages: { 'en-US': 'English', 'pt-BR': 'Português (BR)' },
    copy: 'Copy',
    copied: 'Copied',
    copyFailed: 'Copy failed',
  },

  nav: [
    { label: 'What the PIV loop is', href: '#overview' },
    { label: 'The chain at a glance', href: '#chain' },
    { label: 'Where do I start?', href: '#picking' },
    { group: 'Setup' },
    { label: 'piv-setup', href: '#piv-setup', skill: true },
    { group: 'Plan' },
    { label: 'piv-spec', href: '#piv-spec', skill: true },
    { label: 'piv-review-spec', href: '#piv-review-spec', skill: true },
    { label: 'piv-slice', href: '#piv-slice', skill: true },
    { label: 'piv-write-prd', href: '#piv-write-prd', skill: true },
    { group: 'Implement' },
    { label: 'piv-implement', href: '#piv-implement', skill: true },
    { group: 'Verify' },
    { label: 'piv-review', href: '#piv-review', skill: true },
    { label: 'piv-fix', href: '#piv-fix', skill: true },
    { label: 'piv-commit', href: '#piv-commit', skill: true },
    { label: 'piv-open-pr', href: '#piv-open-pr', skill: true },
    { label: 'piv-review-pr', href: '#piv-review-pr', skill: true },
    { group: 'Reference' },
    { label: 'Artifacts & where they live', href: '#artifacts' },
    { label: 'House rules', href: '#house-rules' },
    { label: 'A full walkthrough', href: '#walkthrough' },
    { label: 'Which runs share a session', href: '#sessions' },
    { label: 'Troubleshooting', href: '#faq' },
  ],

  hero: {
    eyebrow: 'Skills Manual',
    title: 'The PIV Loop',
    lede: 'Plan → Implement → Verify. Ten skills that carry an idea from a blank page to a pull request a human can approve — one deliberate step at a time, on your machine, with GitHub as the only remote.',
  },

  sections: [
    {
      id: 'overview',
      title: 'What the PIV loop is',
      blocks: [
        { type: 'p', text: '**PIV** stands for **plan → implement → verify**. It is the shape this project\'s skills run work through.' },
        {
          type: 'list',
          items: [
            '**Plan** turns an idea into a spec, audits it against your code and your GitHub issues and PRs, cuts it into one ticket per task, and publishes it as one GitHub issue.',
            '**Implement** builds one task at a time on the intent\'s branch and writes an implementation report.',
            '**Verify** tries to prove each task wrong before it is committed: a review writes findings, a triage run settles each one, and only then is the task committed. Once every task is in, the PR opens and is audited against the spec before a human merges it.',
          ],
        },
        { type: 'p', text: 'Two properties hold the whole thing together. **Every step reads the artifact the step before it wrote** — the reports are not paperwork, they are the input. And **every step is started by you**, never by the step before it.' },
        {
          type: 'callout',
          title: 'The core idea',
          text: 'Nothing chains itself. Each skill finishes by telling you the next move; you decide whether to run it. That is what keeps a bad plan from becoming a merged PR while you were away.',
        },
      ],
    },

    {
      id: 'chain',
      title: 'The chain at a glance',
      blocks: [
        {
          type: 'chain',
          phases: [
            { phase: 'plan', label: 'Plan', skills: ['piv-spec', 'piv-review-spec', 'piv-slice'] },
            {
              phase: 'implement',
              label: 'Implement',
              skills: ['piv-implement'],
              note: '**One task at a time.** Implement, review, fix and commit repeat for each task of the epic, in its order.',
            },
            {
              phase: 'verify',
              label: 'Verify',
              skills: ['piv-review', 'piv-fix', 'piv-commit', 'piv-open-pr', 'piv-review-pr'],
              note: '**Each task closes on a PASS.** `piv-fix` hands back to a fresh `piv-review`, or to `piv-commit` when the review was a PASS and the tree still matches it. Only a PASS verdict earns a commit; the PR opens once every task is committed.',
            },
          ],
        },
        { type: 'p', text: 'Read the arrows as *"this is the next move offered"*, not as automation. The review, the triage and the commit are the gate for each task; the PR is the handoff out of the loop, to a human who reviews, approves and merges.' },
      ],
    },

    {
      id: 'picking',
      title: 'Where do I start?',
      blocks: [
        { type: 'p', text: 'You rarely need all ten. Find the row that matches what you have in hand.' },
        {
          type: 'table',
          head: ['What you have', 'Start with', 'Why'],
          rows: [
            ['The skills installed with the [install command](#setup), no `docs/` for them yet', '`piv-setup`', 'Every step reads the loop and the git conventions from `docs/`, and keeps its files under an ignored `.piv/`; without them the first run has nothing to go on.'],
            ['A product idea, nothing written', '`piv-write-prd`', 'Optional: pin the *what and why* down before the spec.'],
            ['A PRD, or a clear idea of the change', '`piv-spec`', 'One interview fixes requirements, design and verification in a spec; a PRD is an input like any other.'],
            ['A spec marked ready', '`piv-review-spec`', 'It checks the spec against your code and your GitHub issues and PRs before anything is published.'],
            ['A spec marked reviewed', '`piv-slice`', '`piv-slice` cuts the tasks itself: one ticket per task, with the spec lines it needs copied verbatim, and one issue that publishes the spec.'],
            ['An issue number', '`piv-implement`', 'It picks the next task from the epic and builds it on the intent\'s branch.'],
            ['A task built, not yet committed', '`piv-review`', 'This is the gate that decides whether the task earns a commit.'],
            ['A CHANGES REQUESTED verdict', '`piv-fix`', 'Findings are input, not a work order — you rule on each one.'],
            ['A PASS verdict with `low` findings', '`piv-fix` (optional)', 'Fix, defer or leave each one; none blocks the commit.'],
            ['A PASS verdict', '`piv-commit`', 'Atomic commits for the task, then the next task — or the PR.'],
            ['Every task committed', '`piv-open-pr`', 'One PR for the whole intent, closing its issue on merge.'],
            ['An open PR', '`piv-review-pr`', 'It holds the PR to every item of the spec.'],
          ],
        },
      ],
    },

    {
      id: 'setup',
      phase: 'setup',
      title: 'Setup',
      blocks: [
        { type: 'p', text: 'Setup is not a step of the loop: it runs once per project, before the first step, and again whenever a newer version of the skills arrives.' },
        { type: 'p', text: 'Install the skills from the root of your project with one command. It needs Node.js and git, on Windows with Git Bash, macOS or Linux, and it installs for Claude Code only. Then run `/piv-setup`.' },
        { type: 'code', text: 'npx skills@1.7.2 add fabianosobreira/piv-pipeline#releases -s \'*\' -a claude-code --copy -y' },
        {
          type: 'list',
          items: [
            '**Commit the lock file with the skills.** The command writes `skills-lock.json` at the project root; commit it together with `.claude/skills/`.',
            '**Keep your own files out of the `piv-*` folders.** Each `.claude/skills/piv-*/` folder is replaced whole on every run, so a file you add there is deleted.',
            '**A failed install is recovered by running the command again.**',
            '**To update, run the same command again.** It pins no version: it installs the current state of the `releases` branch, and the lock file records only the hash installed. To pin a version by hand, replace `#releases` with `#vX.Y.Z`.',
          ],
        },
        {
          type: 'skill',
          id: 'piv-setup',
          kicker: 'Setup · once per project',
          summary: 'Checks that the project is on GitHub with `gh` logged in, installs the docs every step reads into the project\'s `docs/`, folds the git rules the project already has into `docs/git-conventions.md` — your rules win over the shipped defaults — and has git ignore `.piv/`.',
          fields: [
            { label: 'Input', text: 'None.' },
            { label: 'Output', text: '`docs/piv-loop.md`; `docs/git-conventions.md`; and the line `.piv/` in the root `.gitignore`, created when absent. Then one commit, if you approve it.' },
            { label: 'How it runs', text: 'Check the remote and `gh`, investigate the existing docs and the harness → draft `docs/git-conventions.md` → post the whole plan at one gate → install → show the commit message and wait for you.' },
            {
              label: 'Guards',
              items: [
                '**GitHub or nothing** — an `origin` off `github.com`, or `gh` not logged in, stops the run with the command that fixes it.',
                '**The harness wins** — git rules from `CLAUDE.md`, `AGENTS.md`, rules files and commit tooling override the shipped `git-conventions.md`; each one keeps a note of where it came from.',
                '**The skills\' needs are checked** — a base branch, a commit subject form, a PR title form and the commit tags are required; a rule that breaks one comes back to you. A branch name or subject without the issue number is allowed, at the cost of the skills asking you for the issue every run.',
                '**Nothing overwritten silently** — an existing `.gitignore` only gains the `.piv/` line.',
              ],
            },
            { label: 'Next move', text: 'None in the loop: it ends on the commit. Pick your starting point from [Where do I start?](#picking)' },
          ],
          notes: [
            {
              type: 'list',
              lead: '**Use it when**',
              items: [
                'You have just installed the skills into a repo with the command above.',
                'Your git rules live in `CLAUDE.md` or `AGENTS.md` — it can move them into `docs/git-conventions.md` and leave a pointer behind, at your word.',
                'A newer version of the skills arrived and the docs should follow.',
              ],
            },
          ],
        },
      ],
    },

    {
      id: 'plan',
      phase: 'plan',
      title: 'Plan',
      blocks: [
        { type: 'p', text: 'The plan step produces the **spec**, which fixes requirements, design and verification in one file; its **review**, which checks it against what already exists; and the **tickets**, one per task, which `piv-slice` cuts itself and fills with the spec lines the task needs, tracked by a local **epic** and published as one GitHub **issue**. They are separate skills because they answer different questions. `piv-write-prd` stands apart: its PRD is an ordinary input of `piv-spec`, handed over by path.' },
        {
          type: 'skill',
          id: 'piv-spec',
          kicker: 'Plan · step 1',
          summary: 'Interviews you in fixed phases, then writes one 9-section spec. Every statement comes from an answer you gave; the agent never fills a gap.',
          fields: [
            { label: 'Input', text: '`[intent-slug]` and the concept — a paragraph, a file, or a full document with links. URLs you pass are read without asking; links it finds on its own are asked first. A PRD is one such document: pass its path, `.piv/[intent-slug]/prd.md`, and its folder is reused. Blank starts with questions.' },
            { label: 'Output', text: '`.piv/[intent-slug]/spec.md` — goal, non-goals, functional requirements (`FR`), non-functional requirements (`NFR`), acceptance criteria (`AC`), constraints (`C`), design (`D`), verification commands, boundaries and a decision log. `Intent-slug` and `Language` sit in its header.' },
            { label: 'How it runs', text: 'Eight phases of numbered questions; every statement traces to an answer you gave. A bundled validator checks structure and traceability: every reference must resolve and every `AC` needs a verification row. `Status: ready` once the lint is clean.' },
            { label: 'Next move', text: '`piv-review-spec [intent-slug]`, in a session of its own.' },
          ],
          notes: [
            {
              type: 'list',
              lead: '**Use it when**',
              items: [
                'You have a change in mind, with or without a PRD, and want it pinned down before anyone builds.',
                'An AI agent will implement it and needs requirements it can verify.',
              ],
            },
            { type: 'p', text: '**Skip it when** the change is a one-line fix you can make by hand.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-review-spec',
          kicker: 'Plan · step 2',
          summary: 'Audits a ready spec before it is published: what the codebase already holds, what the repo\'s issues and PRs already say, and every item the interview left deferred. It settles each one with you, and marks the spec\'s revision reviewed.',
          fields: [
            { label: 'Input', text: '`[intent-slug]`, for a spec with `Status: ready`. A `draft` stops the run.' },
            { label: 'Output', text: 'The spec, edited only with your answers, at `Status: reviewed`; and `.piv/[intent-slug]/spec.review.md` — what exists in the code, the conflicting issues and PRs, what you settled, what changed, and the `Reviewed-hash` of the spec. A problem that needs a new interview reopens the spec as `draft` instead.' },
            { label: 'How it runs', text: 'Read the spec → search the codebase → search the repo\'s issues and PRs with `gh`, read-only → ask, in the same numbered format as `piv-spec` → apply the answers and lint → mark the outcome. Without `gh` logged in it stops, unless you rule to go on without the remote check.' },
            { label: 'Next move', text: '`piv-slice [intent-slug]`, in a session of its own.' },
          ],
          notes: [
            { type: 'p', text: '**Why a separate run.** The interview that wrote the spec is the worst judge of it. A fresh session finds the code that already does half the job, and the closed issue that already rejected the idea, before the spec becomes a public issue.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-slice',
          kicker: 'Plan · step 3',
          summary: 'Cuts a reviewed spec into tasks, one ticket per task and an epic that tracks them, then publishes the spec as the intent\'s one GitHub issue. The cut is its own call; the spec lines in each ticket are copied, never created or reworded.',
          fields: [
            { label: 'Input', text: '`[intent-slug]`, for a spec at `Status: reviewed` whose hash matches its review. A `draft`, a `ready`, or a spec edited after its review stops the run.' },
            { label: 'Output', text: '`tasks/T-xx/T-xx.md`, one ticket per task, each with a header block (`Spec` with the revision hash, `Task`, `Title`, `Type`, `Blocked by`, `Size`, `DoD`, `Cites`, `Intent-slug`, `Language`) and the spec\'s sections; `epic.md`, the to-do list of tasks; and one GitHub issue, with the whole spec as its body, one type label — `bug`, `feature` or `task` — and you as assignee.' },
            { label: 'How it runs', text: 'Non-interactive through slicing, linting and the `gh` preflight, then **one gate** where you approve the issue: its title, its label, and the warning that the spec is published in full. A bundled validator, `lint_ticket.sh`, rejects any ticket line that is not a verbatim line of the spec, and `lint_epic.sh` checks that the cut covers every `AC`, `NFR`, `C` and `D`; nothing reaches GitHub until both pass.' },
            { label: 'Next move', text: '`piv-implement [#N]`, in a session of its own.' },
          ],
          notes: [
            { type: 'p', text: '**Use it when** a spec is reviewed and you need it sliced into units an agent can finish and prove, one at a time.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-write-prd',
          kicker: 'Standalone',
          summary: 'Interviews you to pin down the problem, why to build it, and a falsifiable hypothesis — then writes a product-level PRD. Intent only: *what* and *why*, never engineering decisions. It is not a step of the loop: its PRD is an ordinary input of `piv-spec`, handed over by path.',
          fields: [
            { label: 'Input', text: '`[product idea]` plus optional paths to research docs — user interviews, support-ticket themes, analytics, competitor teardowns. Blank starts with questions.' },
            { label: 'Output', text: '`.piv/[intent-slug]/prd.md` — problem statement, evidence, thesis, hypothesis, target user & JTBD, constraints, MVP, success metrics, non-goals, open questions.' },
            { label: 'How it runs', text: 'A clustered interview in five phases, each ending at a gate where it waits for you. Questions are numbered across the whole run, and the hypothesis comes back to you assembled from your own words before it is final.' },
            {
              label: 'Guards',
              items: [
                '**Evidence-or-TBD** — every requirement traces to something you said or a doc showed; unknowns are written as "TBD — needs validation".',
                '**Intent-framed, not solution-prescriptive** — if only one solution could fit the problem statement, it\'s a spec, not a PRD.',
              ],
            },
            { label: 'Next move', text: '`piv-spec .piv/[intent-slug]/prd.md`, in a session of its own.' },
          ],
          notes: [
            {
              type: 'list',
              lead: '**Use it when**',
              items: [
                'You\'re starting something greenfield and no one has written down the problem yet.',
                'Two people on the team would describe "the problem" differently.',
              ],
            },
            { type: 'p', text: '**Skip it when** the change is already clear enough to go straight to `piv-spec`.' },
          ],
        },
      ],
    },

    {
      id: 'implement',
      phase: 'implement',
      title: 'Implement',
      blocks: [
        {
          type: 'skill',
          id: 'piv-implement',
          kicker: 'Implement · per task',
          summary: 'Builds one task from its ticket on the intent\'s branch, validating at every step, and writes an implementation report. The work stays uncommitted for the review.',
          fields: [
            { label: 'Input', text: '`[#N | intent-slug] [T-xx]`. Blank takes the issue from the branch name and the next task from the epic: the one in progress, else the first whose dependencies are all committed.' },
            { label: 'Output', text: '`tasks/T-xx/T-xx.report.md` — summary, tasks completed, tests added, validation results, **deviations from the ticket**, problems encountered. Status is `COMPLETE` or `PARTIAL` — `PARTIAL` also when a changed file is one git ignores, since it never travels with the branch. The task turns `[~]` in the epic.' },
            { label: 'How it runs', text: 'Resolve the task and check its dependencies → work on the intent\'s branch, created by the first task as `[tag]/[N]-[intent-slug]` → read the ticket end to end and check for drift → execute tasks in order → close the testing strategy → run the checks → final verification.' },
            { label: 'Next move', text: '`piv-review [#N] [T-xx]`, in a session of its own.' },
          ],
          notes: [
            { type: 'p', text: '**Why deviations matter.** The reviewer reads this report. A deviation recorded here is an *intentional* decision the reviewer should not flag; the same deviation left unwritten comes back as a finding. The exception is a test: one skipped, loosened, rewritten or deleted still blocks the review, even when a deviation explains it.' },
          ],
        },
      ],
    },

    {
      id: 'verify',
      phase: 'verify',
      title: 'Verify',
      blocks: [
        { type: 'p', text: 'Verify is five skills and one rule: **review and fixes are separate runs**. The reviewer writes findings and touches no code. The triage run decides what happens to each finding, with you ruling on the split. Review, triage and commit run per task; the PR and its audit run once, for the whole intent.' },
        {
          type: 'skill',
          id: 'piv-review',
          kicker: 'Verify · the gate, per task',
          summary: 'Reviews one task\'s uncommitted change for bugs, security defects and standards violations, and writes a review report. It is a report, never an edit.',
          fields: [
            { label: 'Input', text: '`[#N | intent-slug] [T-xx]` — blank and it takes the issue from the branch name and the task in progress from the epic.' },
            { label: 'Output', text: '`tasks/T-xx/T-xx.review.md` — scope (every file read), findings grouped `test-fact` / `critical` / `high` / `medium` / `low`, and the checks run, the full test suite among them. A `test-fact` finding is a red, missing or weakened test, or a behavior with no test — a fact, outside the severity scale. Every other finding carries an origin: `introduced` by the change, `aggravated` — an old defect the change made reachable — or `pre-existing`, reproduced on the base and untouched by the change. Each finding carries evidence, impact and a concrete fix.' },
            { label: 'Verdict', text: '**CHANGES REQUESTED** when any test-fact finding, or any `introduced` or `aggravated` one of severity critical, high or medium, survives. **PASS** otherwise — a PASS leaves only `pre-existing` findings, which the PR body carries, and `introduced` or `aggravated` `low` findings, which stay only in the report.' },
            { label: 'How it runs', text: 'Resolve the change against `HEAD`, the last commit before the task → resolve prior deferrals → read the standards the change must meet → examine every changed file in its context → build the case → run three filters that kill unproven findings. The change is held to the ticket\'s acceptance criteria as well as its testing strategy: a criterion the code doesn\'t meet is a `high` finding.' },
            { label: 'Next move', text: '**PASS** with no findings → `piv-commit [#N] [T-xx]`, here or in a fresh session. **PASS** with `pre-existing` findings → `piv-commit [#N] [T-xx]`, in a session of its own. **PASS** with `introduced` or `aggravated` `low` findings → `piv-commit [#N] [T-xx]`, in a session of its own; to clear them first, `piv-fix`, which points back to `piv-commit` while the tree still matches the report, and to a fresh `piv-review` otherwise. **CHANGES REQUESTED** → `piv-fix`, in a session of its own, handed this report\'s path.' },
          ],
          notes: [
            { type: 'p', text: '**Use it** before committing a task, and again after every fix run. On a re-review it overwrites the previous report: it is the current state of the task, and the rulings on old findings live in the deferrals, not here.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-fix',
          kicker: 'Verify · triage',
          summary: 'Triages the review\'s findings, fixes the ones you choose one at a time with tests, defers the rest as local deferrals, validates, and writes a fix report.',
          fields: [
            { label: 'Input', text: '`[review report path]` — blank and it uses the review of the task in progress.' },
            { label: 'Output', text: '`tasks/T-xx/T-xx.fixes.md` — **Fixed**, **Deferred** (with their `D-xx`), **Needs a human look**, **Noise / won\'t-fix**, and the checks run. Each deferral lands in `deferrals/D-xx.md` and in the epic\'s list; no issue is created.' },
            { label: 'How it runs', text: 'Triage every finding into one of the four buckets, by the test-fact kind and the origin the review recorded — test-fact, `introduced` and `aggravated` to *fix now*, `pre-existing` to *defer*, an `introduced` or `aggravated` `low` one being optional (fix, defer or leave it); a test-fact finding only into *fix now* or *noise*, never deferred → fix the *fix now* set one at a time, each with a test that proves it → validate the whole branch.' },
            { label: 'Next move', text: 'When the review was a PASS and the tree still matches its Diff hash, `piv-commit [#N] [T-xx]`; otherwise `piv-review [#N] [T-xx]` again, in a session of its own. With a *Needs a human look* entry still open, the hand-off waits: inspect it, then rerun `piv-fix`.' },
          ],
          notes: [
            { type: 'p', text: '**Why the report exists.** Triage is a human decision, and a decision that lives only in the conversation is gone by the next run. The fix report and the deferral files are what tell the re-review that a finding was already settled — so settled findings stay settled.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-commit',
          kicker: 'Verify · commit, per task',
          summary: 'Commits one reviewed task as atomic, conventionally-tagged commits — each one a coherent piece of work its subject line can name — and marks the task done in the epic.',
          fields: [
            { label: 'Input', text: '`[#N | intent-slug] [T-xx]` — blank and it takes the issue from the branch name and the task in progress from the epic.' },
            { label: 'Output', text: 'Commits on the intent\'s branch, each subject closing on `(#N)`, plus a "What Changed" summary. The task turns `[x]` in the epic, with its commits\' short hashes. The run ends with a clean tree.' },
            { label: 'How it runs', text: 'Check where you are and that the tree still matches the PASS → inspect the tree → group the changes → commit each group → mark the task done.' },
            { label: 'Next move', text: 'A task still open → `piv-implement [#N]`, in a session of its own. Every task done → `piv-open-pr [#N]`, in this same session.' },
          ],
          notes: [
            { type: 'p', text: '**Use it** once the task\'s review verdict is PASS. Usually this is a single commit; when the tree holds unrelated work it splits, and anything that fits no group stops the run and asks you.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-open-pr',
          kicker: 'Verify · handoff',
          summary: 'Opens the GitHub pull request for an intent whose tasks are all committed, closing its issue on merge, and hands the URL to a human reviewer.',
          fields: [
            { label: 'Input', text: '`[#N | intent-slug] · [base branch]` — blank and it takes the issue from the branch name and uses the project\'s base branch.' },
            { label: 'Output', text: 'A published branch and an open PR, with the issue\'s label and you as assignee. Its body carries `Closes #N`, the spec\'s revision, and per task the summary, validation, deviations, surviving findings and open problems — plus every deferral in full. It reports the PR number, the URL and the base ← head branches.' },
            { label: 'How it runs', text: 'Resolve the intent and the base branch → check every task is done and every commit is on the branch → gather the body from the reports and the deferrals → publish → open the PR with `gh`.' },
            { label: 'Next move', text: '`piv-review-pr [#N]`, in a session of its own — then a human reviews, approves and merges.' },
          ],
          notes: [
            { type: 'p', text: '**The issue closes itself.** `Closes #N` in the body closes the issue when the PR merges; no step closes it by hand.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-review-pr',
          kicker: 'Verify · audit',
          summary: 'Audits the open PR against the spec, item by item, and writes a PR review with a **CONFORMS** or **DIVERGES** verdict. It judges conformance, not code quality — `piv-review` already did that, task by task.',
          fields: [
            { label: 'Input', text: '`[#N | intent-slug]` — blank and it takes the issue from the branch name.' },
            { label: 'Output', text: '`.piv/[intent-slug]/pr-review.md` — every `FR`, `NFR`, `C`, `D` and `AC` marked *met*, *diverges* or *not verifiable* with its evidence; the divergences, out-of-scope changes included, with a severity; the non-goals and *Never* lines, respected or violated; and whether the spec changed after the PR opened.' },
            { label: 'How it runs', text: 'Read the PR with `gh`, read-only → index the spec → read the whole diff → hold every item to it → compare the spec\'s revisions → write the review. It never comments on the PR.' },
            { label: 'Next move', text: '**CONFORMS** → a human merges. **DIVERGES** → you decide: fix it by hand, plan it as a new intent, or accept it. **The agent\'s loop ends at the merge.**' },
          ],
        },
      ],
    },

    {
      id: 'artifacts',
      title: 'Artifacts & where they live',
      blocks: [
        { type: 'p', text: 'Every step reads the artifact before it, so the paths matter. They are defined in `docs/piv-loop.md`, which [`piv-setup`](#piv-setup) installs alongside a `docs/git-conventions.md` merged with the git rules your `CLAUDE.md`, `AGENTS.md` or commit tooling already set. Everything below lives under `.piv/[intent-slug]/` at the repo root, which git ignores.' },
        {
          type: 'table',
          head: ['Artifact', 'Path', 'Written by', 'Read by'],
          rows: [
            ['PRD', '`prd.md`', '`piv-write-prd`', 'spec'],
            ['Spec', '`spec.md`', '`piv-spec`', 'spec review, slice, PR review'],
            ['Spec review', '`spec.review.md`', '`piv-review-spec`', 'slice'],
            ['Epic', '`epic.md`', '`piv-slice`, then each step that marks a task', 'every step from implement on'],
            ['Tickets', '`tasks/T-xx/T-xx.md`', '`piv-slice`', 'implement, review, fix'],
            ['Implementation report', '`tasks/T-xx/T-xx.report.md`', '`piv-implement`', 'review, PR'],
            ['Review report', '`tasks/T-xx/T-xx.review.md`', '`piv-review`', 'fix, re-review, commit, PR'],
            ['Fix report', '`tasks/T-xx/T-xx.fixes.md`', '`piv-fix`', 're-review, PR'],
            ['Deferrals', '`deferrals/D-xx.md`', '`piv-fix`', 're-review, PR'],
            ['PR review', '`pr-review.md`', '`piv-review-pr`', 'you'],
          ],
        },
        { type: 'p', text: 'GitHub holds only two things: the issue, created by `piv-slice` with the spec as its body, and the PR, opened by `piv-open-pr`. Every other artifact stays on your machine.' },
        {
          type: 'callout',
          title: 'Why local first',
          text: 'A plan is cheap to change while it is a file and expensive once it is a tracker full of tickets, comments and links. Keeping the spec, the tickets and every report local lets the loop rewrite them freely, and leaves GitHub with what people actually read: one issue that states the intent, and one PR that delivers it.',
        },
        {
          type: 'callout',
          title: 'Why one issue, one branch, one PR',
          text: 'The issue\'s number is the intent\'s identity in git: the branch is `[tag]/[N]-[intent-slug]`, every commit ends on `(#N)`, and the PR closes `#N`. One task is one commit on that branch, so the history reads task by task, and a human reviews the whole intent once instead of a stack of small PRs.',
        },
        {
          type: 'callout',
          title: 'The intent-slug',
          text: 'Every artifact of one intent carries the same `intent-slug`: the kebab-slug of the product title, or of the spec\'s goal, in lowercase ASCII with accents stripped. It names the intent\'s folder under `.piv/`, and every artifact opens with a **header block** — a short markdown list, one bold field per line — that carries it. Later steps **read it from the artifact instead of re-deriving it** — so a PRD written under `user-auth/` never grows an `authentication/` spec beside it.',
        },
      ],
    },

    {
      id: 'house-rules',
      title: 'House rules',
      blocks: [
        {
          type: 'list',
          ordered: true,
          items: [
            '**Nothing chains itself.** Each skill ends by offering the next move; you run it.',
            '**Each step reads the artifact before it.** Reports are the input the next run works from, not paperwork.',
            '**Skills stop rather than guess.** A spec not reviewed, a task whose dependency isn\'t committed, a dirty tree with work that fits no group, `gh` not logged in — the run stops and asks.',
            '**GitHub is written twice.** `piv-slice` creates the issue and `piv-open-pr` opens the PR; every other step reads, or stays local.',
            '**Review and fixes are separate runs.** The reviewer writes findings and touches no code; the triage run decides what happens to each one, with you ruling on the split.',
            '**Each task closes on a PASS.** A fix run hands back to a fresh review, which reads the deferrals so settled findings stay settled. After a PASS the tree still matches, it goes straight to the commit.',
            '**One task at a time.** Tasks run in the epic\'s order, never in parallel, each committed before the next starts.',
            '**One language per intent.** The PRD — or, with no PRD, the spec — is written in the language you interview in, and every later artifact follows it. Template headings and labels stay as the templates write them.',
          ],
        },
        {
          type: 'callout',
          title: 'If a run stops and asks you something',
          text: 'That\'s the design, not a failure. Answer it and re-run — guessing is the one thing these skills won\'t do for you.',
        },
      ],
    },

    {
      id: 'walkthrough',
      title: 'A full walkthrough',
      blocks: [
        { type: 'p', text: 'One intent with two tasks, start to merge. Each line is something you type, and the steps are grouped by the session they run in; the note beside each group says why, and [which runs share a session](#sessions) explains the reasoning.' },
        {
          type: 'walkthrough',
          groups: [
            {
              steps: [{ n: 1, cmd: 'piv-write-prd', text: 'interview, then a PRD lands at `.piv/team-inbox/prd.md`.' }],
              note: '**Its own session.** The PRD is written to a file, and the next step reads it from there; nothing needs to stay in the conversation.',
            },
            {
              steps: [{ n: 2, cmd: 'piv-spec .piv/team-inbox/prd.md', text: 'it takes the PRD as input; the interview, then a spec lands at `.piv/team-inbox/spec.md`.' }],
              note: '**Fresh session.** The PRD already holds the intent; the spec interview starts from the file, not from the PRD interview\'s context.',
            },
            {
              steps: [{ n: 3, cmd: 'piv-review-spec team-inbox', text: 'it finds an open PR that overlaps one requirement; you settle it, and the spec is reviewed.' }],
              note: '**Fresh session.** The review must not share the interview\'s context.',
            },
            {
              steps: [{ n: 4, cmd: 'piv-slice team-inbox', text: 'two tickets and the epic; you approve the issue at the gate, and issue `#123` opens with the spec as its body.' }],
              note: '**Fresh session.** The slice only runs on what the review approved, and the spec and its review already hold everything it needs.',
            },
            {
              steps: [{ n: 5, cmd: 'piv-implement #123', text: 'branch `feat/123-team-inbox`, task `T-01`, its tests, and `tasks/T-01/T-01.report.md`.' }],
              note: '**Fresh session, one per task.** The heaviest step needs the whole window; in the planning session it would miss the ticket\'s gaps and bring back alternatives the interviews rejected.',
            },
            {
              steps: [{ n: 6, cmd: 'piv-review #123', text: 'verdict **CHANGES REQUESTED**, 1 high and 3 medium in `tasks/T-01/T-01.review.md`.' }],
              note: '**Fresh session, always.** In the implementation\'s session the review re-reads its own decisions and tends to confirm them.',
            },
            {
              steps: [{ n: 7, cmd: 'piv-fix .piv/team-inbox/tasks/T-01/T-01.review.md', text: 'you fix the high and one medium, defer the two pre-existing ones as `D-01` and `D-02`; `T-01.fixes.md` records every ruling.' }],
              note: '**Fresh session.** The run that raised the findings tends to defend them; the triage has to be free to rule against the review.',
            },
            {
              steps: [{ n: 8, cmd: 'piv-review #123', text: 'it reads the deferrals, and the verdict is **PASS**.' }],
              note: '**Fresh session, always.** In the fix\'s session the review would approve its own fix; only an independent PASS closes the loop.',
            },
            {
              steps: [{ n: 9, cmd: 'piv-commit #123', text: 'one commit ending on `(#123)`; `T-01` turns `[x]` in the epic.' }],
              note: '**Fresh session.** The commit body comes from the diff, not the reports. Then steps 5–9 run again for `T-02`.',
            },
            {
              steps: [
                { n: 10, cmd: 'piv-commit #123', text: 'the last task is committed.' },
                { n: 11, cmd: 'piv-open-pr #123', text: 'the PR opens with `Closes #123` and both deferrals in its body.' },
              ],
              note: '**One session for both.** Carrying a review-sized context costs more than starting over; the PR describes what the commits recorded, so nothing between them needs to stay independent.',
            },
            {
              steps: [{ n: 12, cmd: 'piv-review-pr #123', text: 'every item of the spec is *met*: **CONFORMS**, and a human merges.' }],
              note: '**Fresh session.** The audit must not share the context of the run that shipped what it audits.',
            },
          ],
        },
        { type: 'p', text: 'Steps 6–8 repeat as many times as a task needs, each pass in fresh sessions. That cycle *is* the loop.' },
      ],
    },

    {
      id: 'sessions',
      title: 'Which runs share a session',
      blocks: [
        { type: 'p', text: 'Every hand-off travels through an artifact — the spec, the epic, the tickets, the reports, the commits, the branch name — never through the conversation. A fresh session never loses anything the next step needs, so the choice weighs two things: whether the next run has to be independent, and what the session costs in tokens.' },
        { type: 'p', text: 'A shared session saves re-reading files, but every turn resends the whole session, and that cost grows with every tool call. A fresh session pays the re-read once and keeps later turns light. Sharing only pays when the next step would re-read almost everything the last one read **and** independence doesn\'t matter — which is why only the last commit and the PR share one (and a commit with a review that ended clean).' },
        {
          type: 'callout',
          title: 'Combinations to avoid',
          text: '**spec + spec review**: the interview judges itself. **implement + review**: self-approval. **review + fix**: the triage can\'t rule against the findings. **fix + re-review**: the loop closes without an independent PASS. **fix or re-review + commit**: a bloated session, and a commit body that retells the reports. **planning + implement**: the ticket\'s gaps go unseen and rejected alternatives come back. **open PR + PR review**: the audit inherits the story of what shipped.',
        },
      ],
    },

    {
      id: 'faq',
      title: 'Troubleshooting',
      blocks: [
        {
          type: 'faq',
          items: [
            { q: 'The review keeps re-raising something I already decided to defer.', a: 'The deferral has to exist as a file under `deferrals/` whose *Origin* names the task, not just a line in the conversation. `piv-fix` writes those files; `piv-review` reads them in its step 2. If the file isn\'t there, the finding legitimately comes back. A test-fact finding comes back even when deferred: it closes only by fixing it, or by showing the problem isn\'t there.' },
            { q: 'The reviewer flagged something I changed on purpose.', a: 'Record it under **Deviations from the ticket** in the implementation report. That section is the reviewer\'s signal of intent. A test you changed is the exception: skipped, loosened, rewritten or deleted, it still blocks the review.' },
            { q: 'Can I skip the PRD?', a: 'Yes. The PRD is one input among others for `piv-spec`, and the spec is what the rest of the loop reads.' },
            { q: 'Can I run several tasks at once?', a: 'No. Tasks share one branch and are committed in the epic\'s order, so each review sees exactly one task\'s change against the last commit.' },
            { q: 'I edited the spec and now piv-slice stops.', a: 'Expected. The review approved one revision of the spec, by its hash; any edit after it needs `piv-review-spec` again.' },
            { q: 'The PR review says DIVERGES. Does piv-fix handle it?', a: 'No. `piv-fix` triages a task\'s review. A divergence in the PR is fixed by hand on the branch, planned as a new intent, or accepted at merge — your call.' },
            { q: 'Nothing moved after a skill finished.', a: 'Expected. Skills don\'t chain — read the next move it offered and run it yourself.' },
          ],
        },
      ],
    },
  ],
};
