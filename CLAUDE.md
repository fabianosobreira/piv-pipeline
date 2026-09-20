# The PIV loop 

Read `docs/PIV-LOOP.md` to understand what a PIV loop is.

Read `docs/MEMORY.md` before proposing any change to a skill, a template or a tracker doc. It records the decisions already settled with the maintainer — who owns what in the pipeline, what belongs in a tracker doc rather than in a skill, and the artifact conventions. Treat an entry there as a ruling, not a suggestion, and change one only when the maintainer says to.

## House Rules

- Nothing chains itself. Each skill ends by offering the next move; you run it. That is what keeps a bad plan from becoming a merged PR while you were away.
- Each step reads the artifact before it. Reports are not paperwork — they are the input the next run works from.
- Skills stop rather than guess. No tracker chosen, an ambiguous ticket id, a dirty tree with work that fits no group, a review report that doesn’t exist: the run stops and asks.
- Review and fixes are separate runs. The reviewer writes findings and touches no code; the triage run decides what happens to each one, with you ruling on the split.
- The loop closes on a PASS. A fix run always hands back to a fresh review, which reads the deferral issues so settled findings stay settled.


## Rules

- All skill files should be writen in plain English with soft wraps.