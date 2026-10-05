# Agent instructions: Project 3

This is the **canonical** instruction file for every AI agent on this repo. Codex reads it directly. `CLAUDE.md` and `GEMINI.md` import it. Edit rules **here**, never in those wrappers.

**The project:** A 3D horror/puzzle game built in Godot 4.7.2 (GDScript, web export / Compatibility renderer). A ghost moves freely through the dark and slips into uncovered, active paintings in the light. Players manipulate electrical switches and portrait covers to survive and solve the house's mystery. It's a four-person class project (COMP 440) structured into four modular code systems, shared contracts, and integration.

| Area | Owner | Folders |
|---|---|---|
| Portrait / Painting system | Hali | `systems/portraits/`, `tests/portraits/`, `docs/features/portraits/` |
| Electrical & Lighting | Rocky | `systems/electrical/`, `tests/electrical/`, `docs/features/electrical/` |
| Environmental Clues | Daniel | `systems/environment/`, `tests/environment/`, `docs/features/environment/` |
| Ghost / Monster System | John | `systems/ghost/`, `tests/ghost/`, `docs/features/ghost/` |
| Integration / Core (`main.tscn`, `project.godot`) | John | `systems/core/`, `docs/features/integration/` |
| Assets (models, materials, 2D art, audio) | Shared | `assets/` (see `docs/ASSETS.md`) |
| Shared contracts | Joint (all) | `systems/shared/`, `tests/shared/`, `docs/CONTRACTS.md` |

**Deadlines:**
- Game Design Document (GDD): **Wed 2026-10-07**
- Playtest (working playable slice): **Fri 2026-10-09**
- Final Game: **Fri 2026-10-16** (Code freeze Thu 2026-10-15 night)

---

## Rule 0: Pull before anything new

Before starting any new feature, spec, or task, sync with the repo:

```bash
git checkout main && git pull --ff-only
```

Then create the feature branch. When resuming an existing branch, run `git pull` and then `git merge origin/main` before working. Never start new work from a stale `main`.

**`main` is the only shared branch:**
- One short-lived branch per feature, **cut from `main`**, with its PR **into `main`**. Delete it after it merges.
- **No stacked PRs** (a PR whose base is another unmerged branch), no long-lived integration branches, and never branch off a teammate's branch. If you need someone's unmerged work, wait for it to merge.
- Merge small and often, but **`main` must always run**: the full GUT suite passes and Run Project plays.
- **Pull `main` into your branch right before every push** (`git pull origin main`), then re-run the suite and Run Project.

## Rule 1: Read before you act (every session)

Read these, in order:
1. [`docs/PROGRESS.md`](docs/PROGRESS.md): what's on `main`, each system's status, **handoff notes** from other agents.
2. [`docs/CONTRACTS.md`](docs/CONTRACTS.md): the exact interfaces between systems.
3. The relevant section of [`docs/GAME_SPEC.md`](docs/GAME_SPEC.md): rules, state ownership, and seams.
4. The current feature folder, `docs/features/<system>/<NN-slug>/`, especially `03-todo.md` (or `FEATURE-lite.md`).

Reference as needed: [`docs/WORKFLOW.md`](docs/WORKFLOW.md) (the process and prompts), [`docs/TECH_STACK.md`](docs/TECH_STACK.md) (tools and commands), [`docs/ASSETS.md`](docs/ASSETS.md) (asset paths, named parts, audio events), [`docs/DECISIONS.md`](docs/DECISIONS.md) (why things are the way they are), [`docs/TODO.md`](docs/TODO.md) (the backlog), [`docs/TEAM.md`](docs/TEAM.md) (ownership, review pairs, checkpoints).

## Rule 2: Know whose system you're in

- If it isn't clear which teammate you're working for, **ask** before editing.
- Edit only that owner's folders: `systems/<system>/`, `tests/<system>/`, `docs/features/<system>/`, and **their own section** of `docs/PROGRESS.md`.
- Never edit another owner's scenes or scripts directly. Instance their scenes, call their public contract methods, and connect to their signals.
- `systems/core/main.tscn`, `project.godot`, and `export_presets.cfg` belong to the Integration owner. Anyone else proposes changes to Integration.

## Rule 3: Contracts are frozen

- Don't change `docs/CONTRACTS.md` or anything in `systems/shared/` except through the change protocol (`CONTRACTS.md` §Change Protocol): propose → `DECISIONS.md` entry → sign-off → one integration PR.
- If your task seems to need a contract change, **stop and tell the human**. Never change a signature silently to make your code compile.
- Respect system invariants and seams documented in `CONTRACTS.md`.

## Rule 4: Follow the workflow (spec before code)

Every feature: branch → brainstorm → spec → plan → TODO → build → verify → PR, as described in `docs/WORKFLOW.md`.
- **Don't write feature code before `01-spec.md` and `02-plan.md` exist** (or the Lite `FEATURE-lite.md` equivalent) and the human has approved the spec.
- When brainstorming, ask **one question at a time**, multiple choice with your recommendation first, grounded in `GAME_SPEC.md`.
- Build **one plan step at a time**: test first, implement, run the suite, tick `03-todo.md`, commit, stop and report.
- Branch names: `<system>/<NN>-<slug>`. Commits: `<system>: <what changed>`.

## Rule 5: Test before claiming done

- Write the GUT test first for any rule, transition, or logic check.
- Run the **full** suite headless before you say a step works:
  ```bash
  godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
  ```
  (See `TECH_STACK.md` for platform details. Run `godot --headless --import` once after cloning or pulling new assets.)
- Report the real result. If tests fail, say so and show the failure. Never claim success you didn't see.
- A test file with a parse error is **skipped**, and GUT can still say "All tests passed". Treat any `SCRIPT ERROR` line, or a `Scripts` count lower than the number of test files, as a failure.
- Feel, lighting, and visuals need the human to check in the system's test scene (`systems/<system>/test/`). Tell them exactly what to try.
- **Done = playable on `main`**. A feature isn't done when it works in isolation in a test scene. It's done when it's **merged into `main`, wired into the game that Run Project starts (`main.tscn`), and working there together with everyone else's merged work**.

## Rule 6: Leave a trail for the next agent

The other agents don't share your memory. They share the repo.
- At the end of every session (or when asked), update **your owner's section** of `docs/PROGRESS.md`: Status, Updated (date + your agent name), Done, In progress, Next, Needs from others, **Handoff notes**.
- Put anything another system's agent must know in **Handoff notes** (signal timing, units, a helper they can call, a known bug).
- Log decisions others might question in `docs/DECISIONS.md` (append, never rewrite).
- If you change a tuning number, update the tuning table in `GAME_SPEC.md` in the same commit.

## Rule 7: Godot 4.7 and GDScript

- **Godot 4 syntax only.** `@export`, `@onready`, `await`, `CharacterBody3D`, `Node3D`, `instantiate()`, `signal.connect(callable)`, `signal.emit()`. No Godot 3 forms. If unsure, check the Godot 4.7 docs before writing engine code.
- **Static typing everywhere:** typed variables, parameters, returns, `Array[PortraitData]`, `Dictionary[StringName, Variant]`.
- **Signals and public methods across systems.** No `get_node("../../OtherSystem/...")` into someone else's scene.
- **Web limits:** Compatibility renderer (no Forward+ features, few dynamic lights); **no threads**; audio starts only after the first user input gesture.
- Keep scenes, scripts, and assets for a system together in its folder. Tabs for indentation in `.gd` (`.editorconfig`).
- The team is collaborating using agentic workflows. Briefly explain engine terms the first time you use them in a session.

## Ask first

- Deleting or renaming files
- Installing an addon, plugin, or asset pack
- Changing `project.godot`, `export_presets.cfg`, or `main.tscn`
- Any contract change
- `git push`, opening or merging PRs

## Never

- Commit `.godot/`, `builds/`, credentials, or personal editor state
- Add features that aren't in the approved spec (log ideas in the plan's "Improvements and bugs" or `TODO.md` Stretch instead)
- Edit another owner's section of `PROGRESS.md` or their system's files
- Skip Rule 0 or Rule 5
- Stack PRs, open a PR into anything but `main`, or merge anything that breaks `main`

## Agent-specific notes

- **Codex:** request approval for running the headless GUT command rather than skipping tests.
- **Claude Code:** see `CLAUDE.md`.
- **Gemini CLI:** see `GEMINI.md`.
