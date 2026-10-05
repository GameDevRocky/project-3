# Workflow: Spec-Driven Development

Every feature goes through the same cycle, whichever teammate or AI agent (Gemini, Claude, Codex) does the work. This disciplined cycle enables four developers to work autonomously in parallel without merge conflicts, breaking interfaces, or stepping on each other's code.

```
0 Sync → 1 Branch → 2 Brainstorm → 3 Spec → 4 Plan → 5 TODO → 6 Build → 7 Verify → 8 PR
                     00-brainstorm  01-spec   02-plan   03-todo   code+tests  PROGRESS    main
```

---

## Full or Lite?

| Use **Full** (four markdown files in feature folder) when… | Use **Lite** (single `FEATURE-lite.md`) when… |
|---|---|
| It touches `CONTRACTS.md` or `systems/shared/` | It stays entirely inside your own system's folder |
| Another system interfaces with it across a seam | Nobody else consumes it directly (e.g. internal shader, camera wobble) |
| It represents a major system milestone | It's a quick bug fix or small task (< 2 hours) |

When in doubt, use **Full**.

---

## Naming Conventions

| Item | Format | Example |
|---|---|---|
| Feature folder | `docs/features/<system>/<NN>-<slug>/` | `docs/features/electrical/01-light-switches/` |
| Branch | `<system>/<NN>-<slug>` | `electrical/01-light-switches` |
| Cross-system / Integration | `integration/<NN>-<slug>` | `integration/00-foundation` |
| Commit message | `<system>: <concise description>` | `electrical: add circuit breaker toggle and trip signal` |

`<system>` must be one of: `portraits`, `electrical`, `environment`, `ghost`, `integration`.

---

## The Step-by-Step Cycle

### Step 0: Sync (Every session, before anything new)

Always start from the latest `main`:

```bash
git checkout main && git pull --ff-only
```

When resuming an existing feature branch:

```bash
git checkout <branch> && git pull && git merge origin/main
```

### Step 1: Branch
Create your feature branch from `main`:
```bash
git checkout -b <system>/<NN>-<slug>
```
Create the feature directory under `docs/features/<system>/<NN>-<slug>/`.

### Step 2: Brainstorm (`00-brainstorm.md`)
Copy `docs/templates/00-brainstorm.md`. Clarify requirements, grounding them in `GAME_SPEC.md` and `CONTRACTS.md`.
Ask **one question at a time** with options and your recommendation first.

### Step 3: Spec (`01-spec.md`)
Copy `docs/templates/01-spec.md`. Detail player-facing behavior, audio/visual cues, typed interfaces used/provided, scenes, and explicit "Done when" criteria. Get owner approval.

### Step 4: Plan (`02-plan.md`)
Copy `docs/templates/02-plan.md`. Break the feature into small iterations and test-first steps. Each step specifies:
1. What test to write first in `tests/<system>/`.
2. How to implement the logic.
3. How to verify it passes.

### Step 5: TODO (`03-todo.md`)
Copy `docs/templates/03-todo.md`. Mirrors the plan checklist. Tick each item in the same commit as the code.

### Step 6: Build (Test-Driven Iteration)
Follow the plan prompt by prompt:
- Write the GUT test first in `tests/<system>/test_<feature>.gd`. Run it and confirm it fails.
- Implement the minimal GDScript code in `systems/<system>/`.
- Run headless GUT test suite:
  ```bash
  godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
  ```
- Tick off the corresponding step in `03-todo.md`.
- Commit with clear message: `<system>: <what changed>`.

### Step 7: Verify
- Confirm full test suite passes with zero script errors.
- Hand-check visual feel and lighting in the system's test scene (`systems/<system>/test/`).
- Pull `origin/main` into the branch.
- Test in the integrated `main.tscn` using **Run Project**.

### Step 8: PR & Post-Merge
- Open PR into `main`. Include summary, affected contracts, and test verification output.
- Review by the designated review pair partner (see `TEAM.md`).
- Merge into `main` and delete the feature branch.
- Update `docs/PROGRESS.md` and `docs/TODO.md` on `main`.
