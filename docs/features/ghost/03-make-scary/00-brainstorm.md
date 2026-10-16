# 03-make-scary: Brainstorm

| | |
|---|---|
| System | Ghost / Monster System |
| Owner | John |
| Branch | `ghost/03-make-scary` |
| Agent | Gemini CLI |
| Date | 2026-10-15 |
| Milestone | Final Game Delivery |

## Goal

Elevate the horror, tension, and visual presence of the ghost monster:
1. Enable semi-random wandering through dark rooms and visibility moving across doorways/corridors.
2. Add glowing red emissive eyes and a subtle dark-room silhouette glow that can be spotted from outside dark rooms.
3. Lock red eyes onto the player when they enter the same room or line of sight.
4. Intensify the chase behavior with distinct audio-visual tells.
5. Add positional scary procedural audio cues (guttural presence drone and terrifying chase screech).

## Grounding

- `GAME_SPEC.md` §5: Monster AI & Behavior (`FREE_ROAM`, `CHASE`, `PAINTING_BOUND`).
- `GAME_SPEC.md` §3: Room layout (Entry Hall, Parlor, Study, Dining Room, Basement).
- `CONTRACTS.md` §2.3: `GhostMonster` states, signals (`ghost_moved`, `ghost_chase_started`, `ghost_chase_ended`).
- `CONTRACTS.md` §2.1: `ElectricalSystem.is_room_lit(room_id)`.

## Q&A

1. **Q:** How should the ghost wander in darkness and navigate between rooms?
   **A:** Option 1: Multi-room dark patrol. The ghost picks semi-random waypoints within dark rooms and periodically traverses doorways into adjacent dark rooms, allowing the player to spot it moving through corridors and across thresholds from outside. · *why:* Creates dynamic, unpredictable tension and lets the player spot the ghost prowling the house from a safe vantage point.

2. **Q:** How should the glowing red eyes and dark-room visibility be implemented?
   **A:** Option 1: Emissive Eyes + Soft Red Halo. Two intense emissive red eye spheres (`emission_energy = 4.0`) that rotate on an eye pivot to track the player, combined with a subtle red point light (`range = 3.5m`, `energy = 0.6`) illuminating the ghost silhouette from inside the dark room. · *why:* Gives an iconic, terrifying visual signature that cuts through darkness and is clearly visible from outside doorframes.

3. **Q:** When should the ghost transition into an obvious chase, and what audio cues should accompany it?
   **A:** Option 1: Sight lock-on screech + roaming guttural audio. When the player enters the same dark room as the monster (or steps into darkness within line-of-sight), the ghost's eyes flare, a sharp dissonant screech plays via `ProceduralAudio`, and it charges in `CHASE` mode at 3.2 m/s. While wandering, a low-frequency guttural breathing/rattling drone plays periodically so the player can audibly locate the prowling entity. · *why:* Maximizes horror feedback, gives fair warning via audio before entering a dark room, and makes the chase sudden and intense.

## Decisions

- **D-MS-1:** While not in active pursuit, the ghost wanders semi-randomly among dark rooms (`FREE_ROAM`), selecting waypoints inside dark rooms and periodically passing through doorways into adjacent dark rooms.
- **D-MS-2:** The ghost entity features two glowing red emissive eyes (`emission_energy = 4.0`, flare to `8.0` during chase) mounted on a tracking head/pivot that rotates to face the player when in the same room. A subtle red point light (`OmniLight3D`, range 3.5m, energy 0.6) casts a dim red halo, making the dark silhouette clearly visible from outside dark doorways.
- **D-MS-3:** If the player enters the same dark room as the ghost, or enters line of sight within darkness, the ghost locks eyes, emits a scary chase screech, and accelerates to chase speed (3.2 m/s). If the player flees into a lit room, the ghost halts at the threshold (or enters a painting if the room is lit) and falls back to dark wandering.
- **D-MS-4:** `ProceduralAudio` adds two new synthesized cues: a periodic 3D positional guttural breathing/drone while wandering, and an aggressive rising screech when `ghost_chase_started` fires.

## Contract changes needed

- None. Uses existing signals (`ghost_chase_started`, `ghost_moved`) and properties.

## Open questions

- None. All requirements clarified and grounded in `GAME_SPEC.md` and `CONTRACTS.md`.

## Out of scope

- Custom 3D rigged humanoid character models (retains procedural/shadow capsule aesthetic with stylized emissive facial elements).
