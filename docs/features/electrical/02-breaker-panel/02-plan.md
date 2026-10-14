# 02-breaker-panel: Plan

| | |
|---|---|
| System / Owner | Electrical & Lighting / Rocky |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. Implement `systems/electrical/breaker_panel.gd` and `systems/electrical/breaker_panel.tscn`.
2. Write unit tests in `tests/electrical/test_breaker_panel.gd`.
3. Instance `BreakerPanel` in `systems/core/main.tscn` under `Sockets/BreakerPanelSocket`.
4. Run full GUT suite headless and verify all tests pass 100%.

## 2. Iterations and Steps

### Iteration 1: BreakerPanel Logic & Unit Tests
- **Step 1.1:** Implement `systems/electrical/breaker_panel.gd` and `.tscn` with `interact()` method and collision shape.
- **Step 1.2:** Implement `tests/electrical/test_breaker_panel.gd` testing Phase 0 startup, blackout reset, and player interaction raycast.

### Iteration 2: Scene Integration & Verification
- **Step 2.1:** Wire `BreakerPanel` into `systems/core/main.tscn` under `Sockets/BreakerPanelSocket`.
- **Step 2.2:** Verify headless GUT test suite across core, electrical, player, and portraits suites.
