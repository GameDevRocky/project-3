# 03-simple-player: Spec

| | |
|---|---|
| System / Owner | Player System / Daniel |
| Branch | `integration/03-simple-player` |
| Status | Approved (2026-10-07) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Playtest (M1) |

## 1. Overview

This feature implements a robust first-person player controller (`systems/player/player_controller.gd` & `.tscn`) owned by Daniel. It provides smooth WASD locomotion, sprint modifier, mouse-look head rotation, interaction raycast (`interact`), and integration into `systems/core/main.tscn`.

## 2. Player-Facing Behavior

1. **Spawn Location:** Spawns on the exterior driveway facing the front porch.
2. **Locomotion:** WASD keys move the player across the navigation floor and through rooms. Holding `sprint` increases speed to 5.8 m/s.
3. **Mouse-Look:** Moving the mouse pans the camera view smoothly, clamped vertically to prevent over-rotation. Clicking captures the mouse; pressing `ESC` releases it.
4. **Interaction Raycast:** A forward-facing RayCast3D detects interactable objects (switches, boxes, paintings, breaker) within 2.5 meters when pressing `E`.

## 3. Scenes and Files

| Path | Purpose |
|---|---|
| `systems/player/player_controller.gd` | First-person movement, mouse look, and interaction script |
| `systems/player/player_controller.tscn` | CharacterBody3D node instance with CollisionShape3D and Camera3D |
| `tests/player/test_player_controller.gd` | GUT unit test verifying player movement and state |

## 4. Done When

- [ ] `systems/player/player_controller.gd` and `.tscn` implemented.
- [ ] Added to `systems/core/main.tscn` at driveway spawn.
- [ ] GUT unit test passes 100% headless.
