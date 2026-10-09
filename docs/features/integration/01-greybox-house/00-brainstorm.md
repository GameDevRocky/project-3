# 01-greybox-house: Brainstorm

| | |
|---|---|
| System | Integration |
| Owner | John |
| Branch | `integration/01-greybox-house` |
| Agent | Gemini CLI |
| Date | 2026-10-07 |
| Milestone | Playtest (M1) |

## Goal

Construct the 3D greybox architecture of the 5-room family home (Entry Hall, Parlor, Study, Dining Room, Basement) and exterior driveway in `systems/core/main.tscn`, establishing clear room boundaries, doorway portals, collision geometry, and socket locations for switches, paintings, boxes, and the car.

## Grounding

What the spec already fixes (quote it; don't re-decide it here):
- `GAME_SPEC.md` §3: Five connected house zones (Entry Hall, Parlor, Study, Dining Room, Basement) plus exterior driveway with player's car.
- `GAME_SPEC.md` §8: First-person camera (`Camera3D`), 3.5 m/s walk speed, 2.5 m interaction reach.
- `CONTRACTS.md` §1.1: `GameTypes.RoomId` (`ENTRY_HALL`, `PARLOR`, `STUDY`, `DINING_ROOM`, `BASEMENT`, `EXTERIOR_DRIVEWAY`).
- `Project 3 Game Design Document.md` §7: Compact single-level house layout with basement stairwell.

## Q&A

1. **Q:** How should we model and assemble the 3D greybox house geometry in Godot?
   **A:** CSG Primitives (`CSGBox3D` with `use_collision = true`). · *why:* Built into Godot 4, zero external dependencies, allows fast level editing and doorway cutouts, ideal for rapid greybox iteration.
2. **Q:** How should the 5 house rooms be spatially arranged relative to the Entry Hall and exterior driveway?
   **A:** Central Hub Layout. · *why:* Entry Hall acts as the central hub connecting to Parlor (West), Study (East), Dining Room (North), and Basement stairs. Gives intuitive navigation to all box locations and direct egress to the front door and driveway.
3. **Q:** How should the game detect and track which room the player, items, and monster are currently inside?
   **A:** Area3D Room Trigger Volumes. · *why:* Each room has an `Area3D` with collision volume and exported `room_id: GameTypes.RoomId`. Emits `room_entered` / `room_exited` signals for player and monster detection, fitting Godot physics natively.
4. **Q:** How should interactive attachment points (paintings, lights, switches, boxes, breaker, car) be represented in the greybox house?
   **A:** Visual Placeholder Meshes. · *why:* Gives immediate visual cues to anyone opening and running the scene before teammate systems are wired in.
5. **Q:** Should the greybox house include a baked `NavigationRegion3D` for monster AI pathfinding?
   **A:** Include NavigationRegion3D. · *why:* Wraps playable floor geometry and stairs so John's monster navigation logic can immediately find paths through unlit rooms without retrofitting navigation later.

## Decisions

- Built-in Godot CSG primitives (`CSGBox3D`) with `use_collision = true` will be used to construct the house walls, floors, ceilings, and doorway openings.
- The house layout uses a Central Hub floorplan: Exterior Driveway (South) -> Entry Hall Hub -> Parlor (West), Study (East), Dining Room (North), Basement Stairs (Northwest).
- Each room contains an `Area3D` (`RoomVolume`) detecting body transitions to update room occupancy for both player and monster.
- Sockets and interactive props are represented using clear visual placeholder meshes with distinct colors and shapes (car, breaker box, switches, wall painting frames, moving boxes).
- A `NavigationRegion3D` wraps the floor geometries and stairs to provide baked pathfinding for monster movement.

## Contract changes needed

- None. Uses existing `GameTypes.RoomId` from `CONTRACTS.md`.

## Open questions

- None. All architectural parameters are grounded and decided.

## Out of scope

- Final art textures, high-polygon furniture meshes, complex lighting shaders. Focus is 100% on spatial layout, collision, room trigger volumes, navigation, and socket placeholders.
