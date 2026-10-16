# 03-make-scary: Spec

| | |
|---|---|
| System / Owner | Ghost / Monster System / John |
| Branch | `ghost/03-make-scary` |
| Status | Approved by user on 2026-10-15 |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Final Game Delivery |

## 1. Overview

This feature significantly elevates the horror atmosphere, visibility, and AI behavior of the ghost monster:
1. Gives the ghost prominent, glowing red emissive eyes and a soft red proximity halo so its menacing silhouette can be spotted peering out of unlit rooms from across doorways and corridors.
2. Implements dark-room semi-random wandering (`FREE_ROAM`) between unlit rooms and waypoints, allowing the player to observe the entity prowling the house when not being actively chased.
3. Automatically locks eyes onto the player and flares eye brightness when the player enters the monster's dark room or line of sight, triggering a high-intensity chase with an aggressive procedural screech and increased speed (3.2 m/s).
4. Adds periodic 3D positional guttural audio while wandering so players can hear the ghost's whereabouts in the dark before stepping into danger.

## 2. Player-facing behavior

- **Viewing from Outside a Dark Room:** Looking into an unlit room from a hallway or doorway reveals two glowing red eyes and a faint crimson silhouette moving through the shadows.
- **Lock-On & Stalking:** When the player steps into the same dark room as the ghost (or crosses into darkness within line-of-sight), the ghost's eyes immediately rotate and lock onto the player. The eyes flare brighter (`emission_energy = 8.0`), an alarming dissonant screech echoes through the room, and the monster rushes directly at the player.
- **Dark Wandering:** If the player is in another room or lit area, the ghost patrols semi-random waypoints within dark rooms and periodically slips through doorways connecting adjacent dark rooms.
- **Escape into Light:** Stepping into a lit room stops the pursuit; the ghost cannot cross into the illuminated room (it freezes, retreats into a painting, or redirects along dark corridors).
- **Procedural Horror Audio:** While roaming unlit rooms, the ghost emits periodic low guttural rattling/breathing every 3–6 seconds via positional 3D audio. Starting a chase emits an immediate sharp screech.

## 3. Rules and numbers

| Rule / Constant | Value | Source |
|---|---|---|
| Roam Speed | 1.8 m/s | Decision D-MS-1 |
| Chase Speed | 3.2 m/s | Decision D-MS-3 (`GAME_SPEC.md` §7) |
| Eye Idle Emission Energy | 4.0 | Decision D-MS-2 |
| Eye Chase Emission Energy | 8.0 | Decision D-MS-2 |
| Red Silhouette Point Light Range | 3.5 m | Decision D-MS-2 |
| Red Silhouette Point Light Energy | 0.6 | Decision D-MS-2 |
| Eye Tracking Distance | 15.0 m | Decision D-MS-2 |
| Roam Waypoint Reach Threshold | 0.8 m | Decision D-MS-1 |
| Roam Audio Interval | 3.5 to 5.5 s | Decision D-MS-4 |

## 4. Interfaces

**Uses:**
- `CONTRACTS.md` §1.1: `GameTypes.RoomId`, `GameTypes.GhostMode`.
- `CONTRACTS.md` §2.1: `ElectricalSystem.is_room_lit(room_id: GameTypes.RoomId) -> bool`.
- `CONTRACTS.md` §2.2: `PortraitSystem.get_valid_entry_paintings(room_id: GameTypes.RoomId) -> Array[PaintingData]`.

**Provides / Emits:**
- `ghost_chase_started`: Emitted when the ghost locks onto the player and begins high-speed chase.
- `ghost_chase_ended`: Emitted when pursuit drops back to wandering.
- `ghost_roam_sound_requested`: Emitted periodically during `FREE_ROAM` for 3D positional audio.

**Contract changes:**
- None.

## 5. Scenes and files

| Path | New / Changed | Purpose |
|---|---|---|
| `systems/ghost/ghost_monster.tscn` | Changed | Add head pivot, glowing red eye mesh instances with emissive materials, and subtle red OmniLight3D halo. |
| `systems/ghost/ghost_monster.gd` | Changed | Implement semi-random dark room waypoint navigation, eye tracking rotation, eye flare state, and roam sound emission. |
| `systems/core/procedural_audio.gd` | Changed | Add synthesized guttural roaming drone and enhanced chase screech synthesizer. |
| `tests/ghost/test_ghost_behavior.gd` | Changed | Add unit tests for dark wandering, eye tracking look-at, and eye brightness states. |

## 6. Edge cases and failure modes

- **All rooms lit:** Monster is trapped in paintings or stunned; eyes and halo extinguish when bound in painting (`shadow_mesh.visible = false`).
- **Player in lit room, monster in dark room:** Monster sees player but cannot enter lit threshold; stares at player from across doorway with locked eyes.
- **Initial Phase 0:** Monster remains dormant (`shadow_mesh.visible = false`, eyes hidden, audio muted) until breaker is flipped.

## 7. Done when

- [ ] Ghost monster features two glowing red emissive eyes and a subtle red point light halo in `ghost_monster.tscn`.
- [ ] Eyes rotate/track the player when in line-of-sight and flare brighter during `CHASE` mode.
- [ ] Ghost wanders semi-randomly through dark rooms and passes through doorways between unlit rooms.
- [ ] Ghost can be spotted from outside dark doorways moving through shadows.
- [ ] Entering the ghost's dark room immediately triggers player lock-on, chase screech, and high-speed pursuit.
- [ ] Procedural audio plays periodic 3D positional guttural breathing while roaming and sharp screech on chase start.
- [ ] Full GUT test suite passes with 0 errors.
