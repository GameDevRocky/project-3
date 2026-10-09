# 02-place-paintings: Plan

| | |
|---|---|
| System / Owner | Integration / Portraits / Ghost |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. Add `PortraitSystem` node and `PortraitPainting` instances to `systems/core/main.tscn`.
2. Write integration unit test in `tests/core/test_painting_integration.gd` verifying portrait registration and ghost painting entry.
3. Run headless GUT test suite and verify 100% pass.

## 2. Iterations and Steps

### Iteration 1: Scene Integration & Tests
- **Step 1.1:** Update `systems/core/main.tscn` with `PortraitSystem` and `PortraitPainting` nodes in the `portrait_paintings` group.
- **Step 1.2:** Write `tests/core/test_painting_integration.gd` and run headless GUT.
