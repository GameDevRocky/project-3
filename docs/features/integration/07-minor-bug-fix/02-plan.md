# 07-minor-bug-fix: Plan

| | |
|---|---|
| System / Owner | Integration / John |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. **Iteration 1: Monster Dormancy Visibility & Collision:** Ensure the ghost is completely hidden and collision-free during Phase 0 until the breaker is flipped.
2. **Iteration 2: Carry & Trunk Phase Gating:** Prevent box pickups and trunk deposits before breaker activation, and prevent family portrait removal/deposit before the endgame.
3. **Iteration 3: Painting Orientations & Parlor Alignment:** Orient all house paintings correctly and align Parlor depth and doorway labels flush with the house layout.
4. **Iteration 4: Verification & Integration Testing:** Run the full GUT suite and verify in the integrated house scene.

## 2. Iterations and steps

### Iteration 1: Monster Dormancy Visibility & Collision

- **Step 1.1:** Write GUT test in `tests/ghost/test_ghost_behavior.gd` asserting `shadow_mesh.visible == false` and `collision_layer == 0` when dormant, and visible/layer 4 when activated. Implement in `systems/ghost/ghost_monster.gd`.

### Iteration 2: Carry & Trunk Phase Gating

- **Step 2.1:** Write GUT tests in `tests/player/test_carry_loop.gd` asserting:
  - Boxes reject pickup in Phase 0 / unpowered state, showing "Restore power at breaker first".
  - `CarTrunk` rejects box deposit during Phase 0 and rejects family portrait before Phase 2.
  Implement in `systems/core/game_coordinator.gd`, `systems/player/carryable_item.gd`, and `systems/player/car_trunk.gd`.

### Iteration 3: Painting Orientations & Parlor Layout

- **Step 3.1:** Write GUT tests in `tests/core/test_house_layout.gd` verifying painting orientations (`Painting_Basement_1` +X, `FamilyPortrait` -Z, `Painting_Parlor_1` +X, `Painting_Study_1` -X) and Parlor geometry (depth 6m, Z: 0 to -6, centered labels).
  Implement in `systems/core/main.tscn` and `systems/core/house_presentation.gd`.

## 3. Prompts

### Prompt 1 (Step 1.1): Ghost Dormant Visibility & Collision
Files: `tests/ghost/test_ghost_behavior.gd`, `systems/ghost/ghost_monster.gd`.
Test: `test_ghost_hidden_and_non_colliding_when_dormant`.
Implement: Set `shadow_mesh.visible = false` and collision layer/mask to 0 when dormant. Restore visibility and collision when `set_monster_dormant(false)`.

### Prompt 2 (Step 2.1): Carry & Trunk Phase Gating
Files: `tests/player/test_carry_loop.gd`, `systems/core/game_coordinator.gd`, `systems/player/carryable_item.gd`, `systems/player/car_trunk.gd`.
Test: `test_box_pickup_blocked_in_phase_0` and `test_trunk_rejects_premature_deposits`.
Implement: Gate box pickup and trunk deposit by game phase.

### Prompt 3 (Step 3.1): Painting Orientations & Parlor Layout
Files: `tests/core/test_house_layout.gd`, `systems/core/main.tscn`, `systems/core/house_presentation.gd`.
Test: `test_painting_orientations` and `test_parlor_geometry_alignment`.
Implement: Update painting transforms in `main.tscn`, adjust Parlor CSG geometry to 6m depth, and update doorway label transforms in `house_presentation.gd`.
