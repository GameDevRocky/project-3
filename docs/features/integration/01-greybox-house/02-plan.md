# 01-greybox-house: Plan

| | |
|---|---|
| System / Owner | Integration / John |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. Shared enums in `systems/shared/game_types.gd` defining `RoomId` and associated types.
2. `systems/core/room_volume.gd` implementing `Area3D` room zone detection with typed signals.
3. GUT unit test verifying `RoomVolume` behavior in `tests/core/test_room_volume.gd`.
4. `systems/core/main.tscn` assembling the 5-room CSG layout (Entry Hall, Parlor, Study, Dining Room, Basement) plus exterior driveway, with visual sockets for boxes, car, paintings, switches, and breaker panel.
5. GUT test in `tests/core/test_house_layout.gd` verifying all 6 room volumes and socket nodes exist in `main.tscn`.
6. Run headless test suite and confirm 100% green.

## 2. Iterations and Steps

### Iteration 1: Room Trigger Volumes & Shared Types

- **Step 1.1:** Create `systems/shared/game_types.gd` defining `RoomId`, `LightState`, `BreakerState`, `CarriedItemType`, `GhostMode`.
- **Step 1.2:** Write test in `tests/core/test_room_volume.gd` for `RoomVolume`. Create `systems/core/room_volume.gd` implementing room trigger logic.

### Iteration 2: Greybox House Geometry & Sockets

- **Step 2.1:** Construct `systems/core/main.tscn` with CSG geometry for the Central Hub layout, basement stairs, exterior driveway, and all sockets.
- **Step 2.2:** Write and run `tests/core/test_house_layout.gd` asserting all rooms, sockets, and collision elements are present and configured.

## 3. Prompts

### Prompt 1 (Step 1.1 & 1.2): Shared Types and Room Volume
```text
Create systems/shared/game_types.gd and systems/core/room_volume.gd.
Write GUT test tests/core/test_room_volume.gd checking room_id export and signal emissions.
Verify tests pass headless.
```

### Prompt 2 (Step 2.1 & 2.2): Main House Scene & Layout Test
```text
Create systems/core/main.tscn with CSG geometry, 6 RoomVolume instances, sockets, and lighting.
Write tests/core/test_house_layout.gd verifying all rooms and sockets exist.
Run GUT headless and verify.
```
