# 02-place-paintings: Spec

| | |
|---|---|
| System / Owner | Integration / Portraits / Ghost |
| Branch | `integration/02-place-paintings` |
| Status | Approved (2026-10-07) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Playtest (M1) |

## 1. Overview

This feature integrates Haliyah's `PortraitSystem` and `PortraitPainting` scenes into the main house scene (`systems/core/main.tscn`), placing concrete paintings in every room and by the front door (Family Portrait). It ensures that the `GhostMonster` successfully interacts with the portrait system across Seam 3 and Seam 4 (freezing in valid uncovered paintings when lights turn ON).

## 2. Player-Facing Behavior

1. **Decorated Walls:** Every room (Entry Hall, Parlor, Study, Dining Room) features framed oil paintings mounted on the walls.
2. **Family Portrait by Front Door:** The prominent Family Portrait hangs right beside the front door in the Entry Hall.
3. **Monster Canvas Integration:** When room lights turn ON and force the ghost into a painting, the target portrait canvas visibly renders the trapped monster using Haliyah's `canvas_paint.gdshader`.

## 3. Scenes and Files

| Path | Purpose |
|---|---|
| `systems/core/main.tscn` | Updated to include `PortraitSystem` node and instantiated `PortraitPainting` instances across all rooms |
| `tests/core/test_painting_integration.gd` | GUT test verifying portrait registration and monster entry query in `main.tscn` |

## 4. Done When

- [ ] `systems/core/main.tscn` contains `PortraitSystem` and registered `PortraitPainting` nodes in all rooms.
- [ ] Family portrait is present by the front door.
- [ ] GUT integration test in `tests/core/test_painting_integration.gd` passes 100% headless.
