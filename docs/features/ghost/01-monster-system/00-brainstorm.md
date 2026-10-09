# 01-monster-system: Brainstorm

| | |
|---|---|
| System | Ghost / Monster |
| Owner | John |
| Branch | `ghost/01-monster-system` |
| Agent | Gemini CLI |
| Date | 2026-10-07 |
| Milestone | Playtest (M1) & Final (M2) |

## Goal

Implement the fully functional Ghost / Monster System (`systems/ghost/`), including its state machine (`FREE_ROAM`, `PAINTING_BOUND`, `CHASE`, `DORMANT`), lighting reaction (free movement in darkness, immobilization/freezing in lit paintings), visual occupancy sync with Haliyah's Portrait System (`is_occupied`), navigation via `NavigationRegion3D`, lethal contact detection with Daniel's Player System, and a procedural 3D monster model/mesh representing its shifting entity and canvas form.

## Grounding

What the spec already fixes:
- `GAME_SPEC.md` §4, §5: Rules 1-4 (darkness roaming, painting freezing in lit rooms, valid uncovered painting entry, family portrait restriction, lethal contact).
- `CONTRACTS.md` §1.3, §2.3: `GhostState`, `GhostMode`, signals (`ghost_moved`, `ghost_entered_painting`, `player_killed`), and public methods (`get_ghost_state`, `set_monster_dormant`, `force_enter_nearest_painting`, `can_exit_house`).

## Q&A

1. **Q:** How should the monster's 3D visual appearance and model be constructed?
   **A:** Procedural 3D composite mesh (Shadowy Silhouette & Canvas Form). · *why:* Fits the game's psychological horror tone perfectly: a tall, elongated dark humanoid figure roaming unlit rooms that collapses and binds into flat oil brushstrokes whenever it enters a wall portrait.
2. **Q:** How should the monster navigate rooms and react to light switches?
   **A:** NavigationAgent3D + Light Snapping. · *why:* Uses Godot's built-in `NavigationAgent3D` over the house's baked `NavigationRegion3D` to stalk and chase the player in unlit rooms, and instantly snaps into the nearest valid uncovered painting when room lights turn ON.

## Decisions

- The monster will be modeled as a procedural 3D node (`GhostMonster`) combining a shadowy translucent humanoid mesh for dark roaming and a painted canvas projection when `PAINTING_BOUND`.
- Navigation uses `NavigationAgent3D` over the house `NavigationRegion3D` during `FREE_ROAM` and `CHASE` modes in darkness.
- When room lights turn ON (`ElectricalSystem.is_room_lit()`), the monster immediately triggers `force_enter_nearest_painting()`, querying Haliyah's Portrait System for a valid uncovered painting, snapping into it, setting `is_occupied = true`, and freezing in `PAINTING_BOUND` mode.
- Direct physical contact with the player in darkness fires `player_killed()` and triggers checkpoint reload.

## Contract changes needed

- None. Fully adheres to `CONTRACTS.md` v0.2.

## Open questions

- None. All requirements grounded in spec and GDD.

## Out of scope

- Electrical switch simulation (Rocky), Player locomotion (Daniel), Portrait covering (Haliyah).


## Contract changes needed

- None. Fully adheres to `CONTRACTS.md` v0.2.

## Open questions

- Monster 3D model geometry and procedural/shaded appearance.
- Chase speed and AI state transition tuning.

## Out of scope

- Electrical switch simulation (owned by Rocky).
- Painting sheet draping (owned by Haliyah).
- Player locomotion (owned by Daniel).
