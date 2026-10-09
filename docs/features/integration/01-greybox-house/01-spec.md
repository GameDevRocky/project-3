# 01-greybox-house: Spec

| | |
|---|---|
| System / Owner | Integration / John |
| Branch | `integration/01-greybox-house` |
| Status | Approved (2026-10-07) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Playtest (M1) |

## 1. Overview

This feature constructs the 3D greybox house architecture in `systems/core/main.tscn` as the foundation for Project 3. It establishes the 5 primary interior rooms (Entry Hall, Parlor, Study, Dining Room, Basement), the exterior driveway with the player's car, `Area3D` room trigger volumes for tracking spatial occupancy, baked `NavigationRegion3D` geometry for AI pathfinding, and clear visual placeholder meshes for interactive sockets (moving boxes, switches, breaker panel, portraits, and car trunk).

## 2. Player-Facing Behavior

1. **Driveway & Car:** The player spawns outdoors on the driveway facing north toward the house porch. Behind/beside them is the car with an open trunk demarcated with a deposit zone.
2. **Entry Hall Hub:** Entering through the front doorway reveals the central Entry Hall. To the immediate right of the door on the wall hangs the distinct, large gilded placeholder for the heirloom Family Portrait.
3. **Room Exploration:**
   - **West Doorway:** Leads into the spacious Parlor / Living Room containing the `Living Room Box` placeholder, wall switch, and painting mounts.
   - **East Doorway:** Leads into the Study / Library containing the `Study Box` placeholder, wall switch, and painting mounts.
   - **North Doorway:** Leads into the Dining Room containing the `Dining Room Box` placeholder, wall switch, and painting mounts.
   - **Northwest Stairwell:** A descending wooden staircase leading down into the pitch-dark Basement cellar.
4. **Basement Utility:** Reaching the bottom of the basement stairs reveals the subterranean room containing the master 100W Breaker Panel mounted on the north wall and the `Basement Box` placeholder.
5. **Room Detection:** Walking across any room threshold fires an internal `room_entered` signal reporting the active `GameTypes.RoomId`.

## 3. Dimensions and Rules

| Architectural Element | Dimension (X, Y, Z) | Notes |
|---|---|---|
| Wall Height | 3.0 m | Standard residential ceiling height |
| Doorway Openings | 1.4 m width x 2.4 m height | Clear clearance for player walk and carrying items |
| Entry Hall | 6.0 m x 3.0 m x 6.0 m | Central hub connecting all ground-floor routes |
| Parlor (Living Room) | 8.0 m x 3.0 m x 8.0 m | West room; wide space for monster luring/containment |
| Study (Library) | 6.0 m x 3.0 m x 6.0 m | East room; intimate room with desk area |
| Dining Room | 8.0 m x 3.0 m x 6.0 m | North room; long table footprint |
| Basement Staircase | 1.6 m width x 3.5 m drop x 5.0 m run | Descending stairs from Y=0.0 down to Y=-3.5 |
| Basement Cellar | 8.0 m x 3.0 m x 8.0 m | Y=-3.5 floor level; housing breaker panel |
| Exterior Driveway | 12.0 m x 0.2 m x 10.0 m | Porch and driveway paving south of front door (Z > 0) |

## 4. Interfaces and Sockets

**Uses:**
- `CONTRACTS.md` §1.1: `GameTypes.RoomId` (`ENTRY_HALL`, `PARLOR`, `STUDY`, `DINING_ROOM`, `BASEMENT`, `EXTERIOR_DRIVEWAY`).

**Provides / Emits:**
- `RoomVolume.room_entered(body: Node3D, room_id: GameTypes.RoomId)`: Emitted when an entity steps into a room.
- `RoomVolume.room_exited(body: Node3D, room_id: GameTypes.RoomId)`: Emitted when an entity departs a room.

**Visual Placeholder Sockets:**
- `CarTrunkSocket`: `Area3D` at the rear of the car on the driveway.
- `BreakerPanelSocket`: Wall-mounted box on the north basement wall.
- `LightFixtureSockets`: Ceiling markers with placeholder `OmniLight3D` in each room.
- `SwitchSockets`: Wall boxes mounted next to entry doors in each room.
- `PaintingSockets`: Wall-mounted framed planes in each room.
- `FamilyPortraitSocket`: Prominent frame mount right beside the front door.
- `MovingBoxSockets`: Floor spawn markers for the 4 room-labeled boxes.

## 5. Scenes and Files

| Path | Purpose |
|---|---|
| `systems/shared/game_types.gd` | Shared enums including `GameTypes.RoomId` |
| `systems/core/room_volume.gd` | `Area3D` trigger detecting player and monster room presence |
| `systems/core/main.tscn` | Integrated root scene containing the greybox house, rooms, sockets, lighting, and navigation |
| `tests/core/test_house_layout.gd` | GUT test verifying room trigger volumes, room IDs, and socket presence |

## 6. Edge Cases

- **Doorway Thresholds:** Trigger volumes for rooms meet seamlessly at doorway portals so entities are always inside exactly one valid room zone.
- **Basement Stair Navigation:** Navigation mesh must continuous bake from the Entry Hall landing down the stairs to the basement floor without breaks.
- **Ceiling Collision:** Ceilings have collision enabled to prevent camera clipping or jumping over walls.

## 7. Out of Scope

- Player character controller implementation (owned by Daniel in `systems/player/`).
- Electrical simulation logic (owned by Rocky in `systems/electrical/`).
- Monster AI pathfinding logic (owned by John in `systems/ghost/`).
- Portrait interaction logic (owned by Haliyah in `systems/portraits/`).

## 8. Done When

- [ ] `systems/shared/game_types.gd` contains `RoomId` enum.
- [ ] `systems/core/room_volume.gd` exists, exports `room_id`, and emits body entered/exited signals.
- [ ] `systems/core/main.tscn` contains the complete 5-room house + driveway CSG geometry with collision.
- [ ] Visual placeholder meshes exist for the car trunk, breaker box, switches, 4 moving boxes, and paintings (including the family portrait).
- [ ] `NavigationRegion3D` covers interior floors and stairwell.
- [ ] Headless GUT test suite in `tests/core/test_house_layout.gd` passes with 100% assertions green.
