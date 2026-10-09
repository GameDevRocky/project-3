# 03-simple-player: Plan

| | |
|---|---|
| System / Owner | Player System / Daniel |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. Implement `systems/player/player_controller.gd`: CharacterBody3D movement, mouse look, gravity, and input handling.
2. Implement `systems/player/player_controller.tscn`: Instantiable scene wrapping the controller script.
3. Write unit test in `tests/player/test_player_controller.gd` verifying player state initialization and movement.
4. Instance player in `systems/core/main.tscn`.
5. Run headless test suite and confirm 100% pass.

## 2. Iterations and Steps

### Iteration 1: Controller Script & Scene
- **Step 1.1:** Write `systems/player/player_controller.gd`.
- **Step 1.2:** Create `systems/player/player_controller.tscn`.
- **Step 1.3:** Write `tests/player/test_player_controller.gd`.

### Iteration 2: Scene Integration
- **Step 2.1:** Instance player in `systems/core/main.tscn`.
- **Step 2.2:** Run headless GUT test suite.
