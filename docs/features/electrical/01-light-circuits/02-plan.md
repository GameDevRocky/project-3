# 01-light-circuits: Plan

| | |
|---|---|
| System / Owner | Electrical & Lighting / Rocky |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. Implement `tests/electrical/test_electrical_system.gd` with unit tests for lighting states, switch toggles, wattage drain/recharge, automatic breaker tripping at 0W, and manual trip/reset methods.
2. Implement `systems/electrical/electrical_system.gd`: `Node3D` class inheriting public contract methods and signals, maintaining circuit dictionaries, and updating power reserve in `_process`.
3. Implement `systems/electrical/electrical_system.tscn`: Instantiable scene root.
4. Run headless GUT test suite and confirm 100% green for electrical tests.
5. Update `docs/PROGRESS.md` with Rocky's status, handoff notes, and integration guidelines for John's Ghost System.

## 2. Iterations and Steps

### Iteration 1: Contract Methods & Circuit States
- **Step 1.1:** Write unit tests in `tests/electrical/test_electrical_system.gd` for `get_room_light_state()`, `is_room_lit()`, `set_room_light()`, `turn_on_all_lights()`, and `light_state_changed` signal.
- **Step 1.2:** Implement `systems/electrical/electrical_system.gd` and scene `electrical_system.tscn` to pass Step 1.1 tests.

### Iteration 2: Wattage Simulation & Breaker State Machine
- **Step 2.1:** Write unit tests in `tests/electrical/test_electrical_system.gd` for wattage drain (1.0 W/s per lit room), recharge (5.0 W/s when all rooms dark), automatic breaker trip at 0W, manual `trip_breaker()`, and `reset_breaker()`.
- **Step 2.2:** Implement `_process(delta)` power simulation loop, trip logic, and reset handling in `systems/electrical/electrical_system.gd`.

### Iteration 3: Verification & Integration Readiness
- **Step 3.1:** Run full headless GUT suite, verify all electrical tests pass cleanly without errors or warnings.
- **Step 3.2:** Update `docs/PROGRESS.md` (Rocky's section) documenting public API and how Ghost Monster interacts with it.

## 3. Prompts

### Prompt 1 (Iteration 1): Circuit State Logic & Test
```text
Write tests in tests/electrical/test_electrical_system.gd and implement systems/electrical/electrical_system.gd covering room lighting states and signals.
```

### Prompt 2 (Iteration 2): Wattage Simulation & Breaker Logic
```text
Extend tests/electrical/test_electrical_system.gd with wattage drain/recharge and breaker trip tests; implement _process simulation and reset in systems/electrical/electrical_system.gd.
```

### Prompt 3 (Iteration 3): Verification & Documentation
```text
Run headless GUT test suite, record results, tick 03-todo.md, and update docs/PROGRESS.md.
```
