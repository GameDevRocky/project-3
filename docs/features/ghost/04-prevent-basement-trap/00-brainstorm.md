# 04-prevent-basement-trap: Brainstorm

| | |
|---|---|
| System | Ghost / Monster System |
| Owner | John |
| Branch | `ghost/prevent-basement-trap` |
| Agent | Gemini CLI |
| Date | 2026-10-15 |
| Milestone | Final Game Delivery |

## Goal

Prevent the ghost monster from being permanently neutralized in the basement painting / cellar room during the packing phase, transforming it into a dynamic, looming threat that actively prowls the house.

## Grounding

- `GAME_SPEC.md` §5 & §6: Monster rules, painting habitation, and paranormal flicker.
- `CONTRACTS.md` §2.3: `GhostMonster` modes (`PAINTING_BOUND`, `FREE_ROAM`, `CHASE`).
- `CONTRACTS.md` §2.1: `ElectricalSystem.trigger_flicker(room_id, duration)`.

## Problem Analysis

The player can effectively seal the ghost in the basement indefinitely by leaving the **Entry Hall light ON**. Because the basement stairs exit directly into the Entry Hall, and the ghost cannot enter a lit room, the illuminated Entry Hall functions as an impassable barrier at the top of the stairs. With the 250W grid and continuous recharge, leaving the Entry Hall on consumes only 2.0 W/s (actually gaining +2.0 W/s net power!), allowing players to leave the foyer illuminated the entire game and completely neutralize the ghost threat.

## Q&A

1. **Q:** What causes the basement containment, and how should we approach fixing it?
   **A:** The illuminated Entry Hall acts as an impassable barrier at the basement stairwell, with low energy cost. The user proposed integrating multiple complementary mechanics: higher energy consumption for the central hallway, paranormal light flickering, and ghost shadow teleportation / phasing into unlit rooms.

2. **Q:** How should we combine the Entry Hall energy draw, light flickering sabotage, and shadow teleportation?
   **A:** Option 1: All Three: Heavy Hallway + Dark Teleport + Flicker Sabotage.
     - **Heavy Hallway Draw:** Entry Hall chandelier draws **4.0 W/s** (against the 4.0 W/s base recharge, breaking even alone; leaving any second room on causes net drain).
     - **Shadow Teleport:** When trapped in a room with all adjacent exits illuminated for >15s, the ghost phases through the dark void and teleports into a random unlit room upstairs, playing a chilling audio tell and appearing with glowing red eyes.
     - **Paranormal Flicker Sabotage:** When pacing at a lit doorway or cornered by light, the ghost exerts paranormal pressure, triggering `trigger_flicker()` on the blocking room's light (2.5s flicker) to destabilize the barrier.
     · *why:* Completely removes the "passive hallway safe zone" strategy, forces active light management, and ensures the ghost constantly stalks the player across the house.

3. **Q:** What specific trigger timings and audio tells should accompany the shadow teleport and flicker sabotage?
   **A:** Option 1: 15s Teleport / 10s Flicker. Teleport triggers after 15.0s without dark exits, and flicker sabotage triggers after 10.0s blocked at a lit door (flickers for 2.5s). Plays a deep void phasing chime via `ProceduralAudio` so the player is audibly warned that the ghost has jumped rooms. · *why:* Gives players a reasonable tactical window while ensuring containment never lasts permanently.

## Decisions

- **D-PBT-1:** Entry Hall chandelier draws **4.0 W/s** (all other rooms draw **2.0 W/s**). With the base 4.0 W/s generator, Entry Hall breaks even alone (`net_rate = 0.0 W/s`); leaving any second room illuminated causes net drain.
- **D-PBT-2:** If the ghost is in `FREE_ROAM` in a room with no unlit exits (e.g. trapped in basement by a lit Entry Hall) for **15.0 seconds**, it shadow-teleports through the walls into a random unlit room in the house, emitting a new signal `ghost_teleported(to_room)`.
- **D-PBT-3:** If the ghost is held back by a lit adjacent room (e.g. at the basement stairs or doorway) for **10.0 seconds**, it triggers paranormal sabotage: calling `ElectricalSystem.trigger_flicker(room_id, 2.5)`. The 2.5s flicker creates temporary darkness, allowing the ghost to cross the threshold or unfreeze.
- **D-PBT-4:** `ProceduralAudio` adds a distinct synthesized void-phasing chime when `ghost_teleported` fires, giving clear auditory feedback across the house.
- **D-PBT-5:** Update `GAME_SPEC.md` §9 Tuning Table to document Entry Hall 4.0 W/s drain, 15.0s teleport timer, and 10.0s flicker sabotage timer.

## Contract changes needed

- None. Uses existing interfaces (`ElectricalSystem.trigger_flicker()`, `get_net_power_rate()`).

## Open questions

- None. All requirements established and approved.

## Out of scope

- Redesigning 3D geometry of the basement stairwell or house mesh.
