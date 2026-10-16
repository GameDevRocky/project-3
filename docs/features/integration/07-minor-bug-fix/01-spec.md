# 07-minor-bug-fix: Spec

| | |
|---|---|
| System / Owner | Integration / John |
| Branch | `integration/minor-bug-fix` |
| Status | Approved by user on 2026-10-15 |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Final Game Delivery |

## 1. Overview

This feature resolves four playtest oversights in the integrated house slice:
1. Keeps the monster invisible and non-colliding while dormant in Phase 0 until the player flips the basement breaker, creating a tense onboarding trek rather than revealing a static monster mesh standing next to the breaker.
2. Prevents moving boxes from being picked up or stowed in the car trunk during Phase 0 ("Restore power at breaker first"), and prevents the family portrait from being taken or stowed before the endgame (Phase 2).
3. Fixes painting orientations so canvases face outward into each room instead of into walls or turned edge-on.
4. Aligns the Parlor room dimensions (Z: 0 to -6, depth 6m) with the house exterior walls and centers the Parlor room label over the entrance archway facing into the Entry Hall.

## 2. Player-facing behavior

- **Basement Trek (Phase 0):** The player descends into the pitch-black basement to flip the breaker. The monster is not visible in front of the breaker box. Upon flipping the breaker, all lights turn on, the breaker clangs, an awakening sting plays, and the ghost becomes active in the house.
- **Carry Restrictions:**
  - In Phase 0, looking at any moving box displays `Restore power at breaker first`. Pressing `E` will not pick up the box.
  - The car trunk will not accept any boxes before Phase 1 (Packing phase).
  - The family portrait cannot be removed from the wall until all 4 boxes are loaded into the trunk (prompt displays `Load all four boxes first`).
  - The car trunk will not accept the family portrait before the final escape phase.
- **Painting Orientations:**
  - Looking at the wall to the left of the basement stairs shows `Painting_Basement_1` facing directly toward the stairs and cellar room.
  - The `FamilyPortrait` beside the front door faces into the Entry Hall foyer.
  - `Painting_Parlor_1` and `Painting_Study_1` face inward from their respective side walls.
- **Parlor Layout & Signage:**
  - Walking into the Entry Hall, looking west displays the `PARLOR` label directly above the center of the doorway archway (`Z = -3.0`).
  - The Parlor exterior walls are flush with the front (`Z = 0`) and back (`Z = -6`) walls of the house.

## 3. Rules and numbers

| Rule / Constant | Value | Source |
|---|---|---|
| Dormant Ghost Mesh Visibility | `false` | Decision D-MBF-1 |
| Dormant Ghost Collision | Disabled (`collision_layer = 0`, `collision_mask = 0`) | Decision D-MBF-1 |
| Active Ghost Collision | `collision_layer = 4`, `collision_mask = 2` | `CONTRACTS.md` §2.3 |
| Phase 0 Box Pickup | Rejected; Prompt: "Restore power at breaker first" | Decision D-MBF-2 |
| CarTrunk Deposit Phase Gate | Requires `Phase.PACKING` for boxes, `Phase.PORTRAIT` for Family Portrait | Decision D-MBF-2 |
| Parlor Dimensions (X, Y, Z) | 8.0 m x 3.0 m x 6.0 m | Decision D-MBF-4 |
| Parlor Z-Range | -6.0 m to 0.0 m (Center Z = -3.0 m) | Decision D-MBF-4 |
| Parlor North Wall Painting | Position Z = -5.85 m | Decision D-MBF-4 |
| Parlor Doorway Label Position | `(-2.95, 2.45, -3.0)`, Yaw: `PI * 0.5` (+X) | Decision D-MBF-4 |
| Study Doorway Label Position | `(2.95, 2.45, -3.0)`, Yaw: `-PI * 0.5` (-X) | Decision D-MBF-4 |

## 4. Interfaces

**Uses:**
- `CONTRACTS.md` §1.1: `GameTypes.RoomId`, `GameTypes.CarriedItemType`, `GameTypes.GhostMode`.
- `CONTRACTS.md` §2.3: `GhostMonster.set_monster_dormant(dormant: bool)`.

**Provides / Emits:**
- `GameCoordinator`: Tracks `phase` and provides queries for whether boxes or portrait can be picked up and packed.
- `CarryableItem`: Contextual prompt and interaction guard during Phase 0.
- `CarTrunk`: Phase-aware interaction guard.

**Contract changes:**
- None.

## 5. Scenes and files

| Path | New / Changed | Purpose |
|---|---|---|
| `systems/ghost/ghost_monster.gd` | Changed | Hide shadow mesh and disable collision when dormant; restore when active. |
| `systems/player/carryable_item.gd` | Changed | Check if power is on / phase allows pickup, update prompt accordingly. |
| `systems/player/car_trunk.gd` | Changed | Reject box/portrait deposits if called outside the appropriate phase. |
| `systems/core/game_coordinator.gd` | Changed | Expose phase checks / helper query `can_pack_boxes()` and `can_pack_portrait()`. |
| `systems/core/main.tscn` | Changed | Correct painting orientations, adjust Parlor room CSG walls/ceiling/floor/RoomVolume to 6m depth, reposition `Painting_Parlor_2`. |
| `systems/core/house_presentation.gd` | Changed | Reposition Parlor & Study labels above doorways facing the Entry Hall. |
| `tests/ghost/test_ghost_behavior.gd` | Changed | Add test for dormant visibility and collision. |
| `tests/player/test_carry_loop.gd` | Changed | Add test for Phase 0 box pickup rejection and trunk gating. |
| `tests/core/test_house_layout.gd` | Changed | Verify Parlor dimensions and painting orientations. |

## 6. Edge cases and failure modes

- **Player tries to pick up dust sheet in Phase 0:** Dust sheet can still be carried (or used) if desired, but boxes cannot.
- **Breaker resets after blackout:** Dormancy only applies to Phase 0 onboarding; during later blackouts the ghost remains active.
- **Dropping a box:** Dropping and re-picking up boxes in Phase 1 works as normal.

## 7. Done when

- [x] Ghost monster shadow mesh is completely hidden and collision disabled when dormant in Phase 0.
- [x] Ghost becomes visible and active upon the initial basement breaker flip.
- [x] Moving boxes cannot be picked up in Phase 0 and show "Restore power at breaker first".
- [x] Light switches cannot turn on lights in Phase 0 and display "Restore power at breaker first".
- [x] Car trunk rejects depositing moving boxes in Phase 0 and rejects the family portrait before all 4 boxes are packed.
- [x] `Painting_Basement_1` faces East into the basement toward the stairs.
- [x] `FamilyPortrait` faces North into the Entry Hall foyer.
- [x] `Painting_Parlor_1` faces East and `Painting_Study_1` faces West.
- [x] Parlor walls match the front and back facade planes of the house (depth 6m).
- [x] Parlor and Study room labels are centered above their respective doorway arches facing the Entry Hall.
- [x] Full GUT test suite passes with 0 errors.
