# 04-prevent-basement-trap: Plan

| | |
|---|---|
| System / Owner | Ghost / Monster System / John |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. **Iteration 1: Entry Hall Heavy Draw (4.0 W/s):** Update `electrical_system.gd` so Entry Hall draws 4.0 W/s while other rooms draw 2.0 W/s. Verify with unit tests in `test_electrical_system.gd`.
2. **Iteration 2: Shadow Teleportation & Flicker Sabotage:** Implement 15s trapped teleportation into unlit rooms and 10s lit threshold flicker sabotage in `ghost_monster.gd`. Verify with unit tests in `test_ghost_behavior.gd`.
3. **Iteration 3: Void Phase Audio & Tuning Documentation:** Synthesize void phasing audio in `procedural_audio.gd`, update `GAME_SPEC.md` §9 Tuning Table, and verify the full GUT test suite.

## 2. Iterations and steps

### Iteration 1: Entry Hall Heavy Draw

- **Step 1.1:** Write unit tests in `tests/electrical/test_electrical_system.gd` asserting Entry Hall drains 4.0 W/s and breaks even alone with the 4.0 W/s generator.
- **Step 1.2:** Implement room-specific drain in `systems/electrical/electrical_system.gd`.

### Iteration 2: Shadow Teleportation & Flicker Sabotage

- **Step 2.1:** Write unit tests in `tests/ghost/test_ghost_behavior.gd` asserting that a ghost trapped in a dark room with all exits lit teleports after 15s to an unlit room, and triggers `trigger_flicker()` after 10s of being blocked.
- **Step 2.2:** Implement in `systems/ghost/ghost_monster.gd`.

### Iteration 3: Void Phase Audio & Tuning Documentation

- **Step 3.1:** Connect `ghost_teleported` in `systems/core/procedural_audio.gd` and synthesize a void phase chime.
- **Step 3.2:** Update `docs/GAME_SPEC.md` §9 Tuning Table.
- **Step 3.3:** Run full headless GUT suite across all 14 test scripts.

## 3. Prompts

### Prompt 1 (Step 1.1 & 1.2): Entry Hall Heavy Drain
Files: `tests/electrical/test_electrical_system.gd`, `systems/electrical/electrical_system.gd`.
Test: `test_entry_hall_heavy_power_drain`.
Implement: Room-based drain rate table (Entry Hall = 4.0, others = 2.0).

### Prompt 2 (Step 2.1 & 2.2): Ghost Teleport & Flicker Sabotage
Files: `tests/ghost/test_ghost_behavior.gd`, `systems/ghost/ghost_monster.gd`.
Test: `test_trapped_ghost_teleports_to_dark_room`, `test_blocked_ghost_triggers_flicker_sabotage`.
Implement: 15s trapped timer and 10s threshold flicker sabotage timer.

### Prompt 3 (Step 3.1, 3.2, 3.3): Audio and Verification
Files: `systems/core/procedural_audio.gd`, `docs/GAME_SPEC.md`.
Implement: Teleport void chime and update Tuning Table.
Verify: Run full GUT test suite.
