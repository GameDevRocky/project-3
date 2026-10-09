# 01-monster-system: Plan

| | |
|---|---|
| System / Owner | Ghost / Monster System / John |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. Implement `systems/ghost/ghost_monster.gd`: CharacterBody3D node with NavigationAgent3D, FSM (`DORMANT`, `FREE_ROAM`, `CHASE`, `PAINTING_BOUND`), and procedural shadow mesh.
2. Implement `systems/ghost/ghost_monster.tscn`: Instantiable scene wrapping the monster script and collision shapes.
3. Write automated unit tests in `tests/ghost/test_ghost_system.gd` covering dormancy, darkness roaming, light-triggered painting entry/freezing, and player collision detection.
4. Run headless test suite and confirm 100% green.

## 2. Iterations and Steps

### Iteration 1: Monster FSM & Seam Integration
- **Step 1.1:** Create `systems/ghost/ghost_monster.gd` implementing state logic, electrical light query, portrait query, and lethal contact.
- **Step 1.2:** Create `systems/ghost/ghost_monster.tscn` wrapping the script and visual mesh.

### Iteration 2: Unit Testing & Verification
- **Step 2.1:** Write `tests/ghost/test_ghost_system.gd` asserting all rules and invariants.
- **Step 2.2:** Run headless GUT test suite and record output.

## 3. Prompts

### Prompt 1 (Step 1.1 & 1.2): Monster Script & Scene
```text
Implement systems/ghost/ghost_monster.gd and systems/ghost/ghost_monster.tscn with NavigationAgent3D, FSM, and procedural model.
```

### Prompt 2 (Step 2.1 & 2.2): Ghost Unit Tests
```text
Write tests/ghost/test_ghost_system.gd, run headless GUT, and verify 100% pass.
```
