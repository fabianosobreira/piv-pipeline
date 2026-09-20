# Code smells to match the diff against

Read alongside the **Quality** class of `SKILL.md` Step 5, which this list extends. Each entry is a judgement call, never a hard violation, and anything the project's tooling already enforces is skipped here:

- **Feature Envy** — a method that reads or writes another object's fields more than its own → move the method onto that data.
- **Data Clumps** — the same group of fields or parameters keeps travelling together across the diff → bundle them into one type.
- **Primitive Obsession** — a primitive or string stands in for a domain concept the diff treats specially → give the concept its own type.
- **Repeated Switches** — the same switch/if-cascade on the same type recurs in more than one hunk — distinct from the duplicated logic the **Quality** class names, since the fix here is polymorphism, not extraction → replace with polymorphism or one shared map.
- **Shotgun Surgery** — one conceptual change in this diff forced edits scattered across unrelated files → gather what changes together into one module.
- **Divergent Change** — one file in the diff was edited for more than one unrelated reason — distinct from the **Quality** class's "a function doing several jobs", which is function-level; this is file-level → split so each module changes for one reason.
- **Speculative Generality** — the diff adds an abstraction, parameter, or hook that neither the ticket nor the implementation report resolved in `SKILL.md` Step 1 ever asked for → delete it, inline back until a real need shows.
- **Message Chains** — the diff introduces or extends a long `a.b().c().d()` navigation → hide the walk behind one method.
- **Middle Man** — a new class or function mostly just delegates onward without adding logic → cut it, call the real target direct.
- **Refused Bequest** — where the diff touches inheritance, a subclass or implementer ignores or overrides most of what it inherits → drop the inheritance, use composition.
