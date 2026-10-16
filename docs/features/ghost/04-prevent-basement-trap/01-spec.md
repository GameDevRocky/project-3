# 04-prevent-basement-trap: Spec

| | |
|---|---|
| System / Owner | Ghost / Monster System / John |
| Branch | `ghost/prevent-basement-trap` |
| Status | Approved by user on 2026-10-15 |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Final Game Delivery |

## 1. Overview

This feature eliminates the passive exploit where the player indefinitely confines the ghost to the basement by keeping the Entry Hall light illuminated. It introduces a tripartite system:
1. **Entry Hall Heavy Draw (4.0 W/s):** The Entry Hall chandelier consumes 4.0 W/s on its own, exactly matching the 4.0 W/s generator capacity. Keeping it on prevents power accumulation, and turning on any other room causes net drain.
2. **Shadow Teleportation (15.0s):** When trapped in a room with no unlit exits for 15 seconds, the ghost phases through the house void and materializes at a waypoint inside an unlit room upstairs, accompanied by a reverberating audio cue.
3. **Paranormal Flicker Sabotage (10.0s):** When blocked by an illuminated doorway threshold for 10 seconds, the ghost surges the blocking circuit, triggering a 2.5s violent flicker that temporarily disables the light barrier.

## 2. Player-facing behavior

- **Hallway Power Management:** Lighting the Entry Hall alone shows `GRID EQUILIBRIUM: 0.0 W/s (1 room)`. If the player lights the Entry Hall plus any room they are packing (e.g. Parlor), the power meter drains at `-2.0 W/s`, discouraging players from leaving the foyer on continuously.
- **Flicker Sabotage:** If the player stands behind a lit doorway to block the ghost, after 10 seconds the lights will start buzzing and violently flickering for 2.5 seconds, forcing the player to run or react as the ghost steps through during the flicker.
- **Shadow Teleport:** If the ghost is walled off in the basement or another wing while the player works in dark rooms elsewhere, after 15 seconds an ominous phasing chime sounds through the house. The ghost's glowing red eyes appear in the shadows of an upstairs dark room.

## 3. Rules and numbers

| Parameter | Value | Source |
|---|---|---|
| Entry Hall Drain Rate | 4.0 W/s | Decision D-PBT-1 |
| Standard Room Drain Rate | 2.0 W/s | Decision D-ET-2 |
| Base Recharge Rate | 4.0 W/s | Decision D-ET-2 |
| Trapped Teleport Timer | 15.0 seconds | Decision D-PBT-2 / Q3 |
| Lit Threshold Flicker Timer | 10.0 seconds | Decision D-PBT-3 / Q3 |
| Sabotage Flicker Duration | 2.5 seconds | Decision D-PBT-3 |
| Teleport Destination Selection | Random unlit room with valid waypoints | Decision D-PBT-2 |

## 4. Interfaces

**Uses:**
- `CONTRACTS.md` §1.1: `GameTypes.RoomId`, `GameTypes.GhostMode`.
- `CONTRACTS.md` §2.1: `ElectricalSystem.is_room_lit(room_id) -> bool`, `ElectricalSystem.trigger_flicker(room_id, duration) -> bool`.

**Provides / Emits:**
- `ghost_teleported(to_room: GameTypes.RoomId)`: Emitted when the ghost phases between rooms.

**Contract changes:**
- None.

## 5. Scenes and files

| Path | New / Changed | Purpose |
|---|---|---|
| `systems/electrical/electrical_system.gd` | Changed | Support room-specific drain rates (Entry Hall = 4.0 W/s, other rooms = 2.0 W/s) in `get_net_power_rate()` and `_process()`. |
| `systems/ghost/ghost_monster.gd` | Changed | Implement 15s trapped teleportation logic and 10s lit threshold flicker sabotage. |
| `systems/core/procedural_audio.gd` | Changed | Synthesize reverberating void phase chime when `ghost_teleported` is received. |
| `docs/GAME_SPEC.md` | Changed | Update §9 Tuning Table with Entry Hall 4.0 W/s drain and teleport/flicker timers. |
| `tests/electrical/test_electrical_system.gd` | Changed | Add test for Entry Hall 4.0 W/s drain and net calculation. |
| `tests/ghost/test_ghost_behavior.gd` | Changed | Add test for trapped shadow teleportation and flicker sabotage trigger. |

## 6. Edge cases and failure modes

- **All house rooms lit:** If all rooms in the house are lit, the ghost cannot teleport to an unlit room; instead, it triggers flicker sabotage on the nearest room's light to create darkness, or enters a painting.
- **Ghost in CHASE mode:** Teleport timer only accumulates in `FREE_ROAM` when blocked; active chase pursues directly until blocked.
- **Phase 0 Onboarding:** Dormancy overrides all timers; no teleport or sabotage occurs before breaker flip.

## 7. Done when

- [x] Entry Hall drains at 4.0 W/s; other rooms drain at 2.0 W/s; net calculation matches in `electrical_system.gd`.
- [x] Ghost trapped with no unlit exits for 15s teleports to a dark room and emits `ghost_teleported`.
- [x] Ghost blocked at a lit room threshold for 10s calls `trigger_flicker(room, 2.5)`.
- [x] `ProceduralAudio` synthesizes a void phase chime on `ghost_teleported`.
- [x] `GAME_SPEC.md` Tuning Table updated.
- [x] Full GUT test suite passes with 0 errors.
