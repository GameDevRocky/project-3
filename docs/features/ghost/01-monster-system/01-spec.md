# 01-monster-system: Spec

| | |
|---|---|
| System / Owner | Ghost / Monster System / John |
| Branch | `ghost/01-monster-system` |
| Status | Approved (2026-10-07) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Playtest (M1) & Final (M2) |

## 1. Overview

This feature implements the official Ghost / Monster System (`systems/ghost/`) and its 3D procedural model. The monster is an ominous, shifting entity that roams unlit rooms in search of the player, but is instantly forced to dive into the nearest valid uncovered painting and freeze when room lights are turned ON. It triggers fatal instant-kill collisions on contact in darkness and attempts to escape through exterior doors only when carried inside the family portrait.

## 2. Player-Facing Behavior

1. **Startup Dormancy:** During Phase 0 (before the basement breaker is flipped), the monster remains dormant and passive.
2. **Darkness Stalking:** Once power is active and a room's lights are turned OFF, the monster roams freely using pathfinding, emitting quiet footstep sounds and hunting the player.
3. **Light Reaction & Freezing:** If the player flips the light switch ON in the monster's room, the monster immediately ceases pursuit, strains toward the nearest uncovered painting, dives into the canvas (`is_occupied = true`), and freezes completely as long as the lights remain lit.
4. **Fatal Contact:** If caught in unlit space where the monster closes distance, direct collision triggers an immediate fatal jump scare, ending the run and reloading the checkpoint.

## 3. Rules and Numbers

| Rule / Constant | Value | Source |
|---|---|---|
| Roaming Speed (`dark_roam_speed`) | 4.5 m/s | `GAME_SPEC.md` §10 |
| Chase Speed (`chase_speed`) | 5.8 m/s | `GAME_SPEC.md` §10 |
| Painting Transition Time | 0.8 s | `GAME_SPEC.md` §10 |
| Lethal Contact Radius | 1.0 m | `CONTRACTS.md` §2.3 |

## 4. Interfaces

**Uses:**
- `CONTRACTS.md` §2.1: Electrical system (`is_room_lit`, `get_room_light_state`)
- `CONTRACTS.md` §2.2: Portrait system (`get_valid_entry_paintings`, `set_monster_occupied`)
- `CONTRACTS.md` §2.3: Player system (`get_player_state`)

**Provides / Emits:**
- `ghost_moved(from_room: GameTypes.RoomId, to_room: GameTypes.RoomId, mode: GameTypes.GhostMode)`
- `ghost_entered_painting(painting_id: StringName)`
- `ghost_exited_painting(painting_id: StringName)`
- `ghost_chase_started()`
- `ghost_chase_ended()`
- `player_killed()`

## 5. Scenes and Files

| Path | Purpose |
|---|---|
| `systems/ghost/ghost_monster.gd` | Core monster AI FSM, navigation, model animation, and seam queries |
| `systems/ghost/ghost_monster.tscn` | 3D monster scene containing procedural shadow mesh, collision body, and NavigationAgent3D |
| `tests/ghost/test_ghost_system.gd` | Automated GUT unit tests for light reaction, painting entry/freezing, and lethal contact |

## 6. Edge Cases

- **Blackout Events:** When the 100W grid hits 0W and trips the breaker, all room lights cut out, instantly waking the monster from any painting-bound freeze and initiating free roam.
- **No Valid Paintings:** If all paintings in a lit room are covered or inactive, the monster becomes stunned in place until a painting is uncovered or lights are turned off.

## 7. Out of Scope

- Electrical switch logic (Rocky).
- Painting sheet draping (Haliyah).
- Player locomotion & HUD (Daniel).

## 8. Done When

- [ ] `systems/ghost/ghost_monster.gd` implements state machine (`DORMANT`, `FREE_ROAM`, `PAINTING_BOUND`, `CHASE`).
- [ ] Monster correctly reads Electrical light state and freezes in valid uncovered paintings when lights turn ON.
- [ ] Direct contact with player in darkness triggers `player_killed()`.
- [ ] Procedural 3D monster model displays correctly in both roaming and painting-bound states.
- [ ] GUT tests in `tests/ghost/test_ghost_system.gd` pass 100% headless.
