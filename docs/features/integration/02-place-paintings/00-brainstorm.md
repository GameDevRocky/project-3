# 02-place-paintings: Brainstorm

| | |
|---|---|
| System | Integration / Portraits / Ghost |
| Owner | John (Integration) |
| Branch | `integration/02-place-paintings` |
| Agent | Gemini CLI |
| Date | 2026-10-07 |
| Milestone | Playtest (M1) |

## Goal

Place concrete portrait painting instances (`systems/portraits/portrait_painting.tscn`) across all rooms in the house (`systems/core/main.tscn`), register them with Haliyah's `PortraitSystem`, and verify that the `GhostMonster` correctly queries and enters valid uncovered paintings when room lights turn ON.

## Grounding

- `GAME_SPEC.md` §3, §4, §5: 5-room layout, painting eligibility rules (uncovered and active), and Seam 3 / Seam 4 interactions.
- `CONTRACTS.md` §2.2, §2.3: `PortraitSystem` methods (`get_valid_entry_paintings`, `set_monster_occupied`) and `GhostMonster` light reaction.

## Q&A

1. **Q:** How should paintings be instantiated and registered in `main.tscn`?
   **A:** Instance Scene & Group Auto-Register. · *why:* Haliyah's `PortraitSystem` automatically registers any node in the `"portrait_paintings"` group during `_ready()`, allowing clean scene composition.

## Decisions

- Paintings will be instanced from `res://systems/portraits/portrait_painting.tscn`, assigned unique IDs and room IDs, added to the `"portrait_paintings"` group, and placed under a `PortraitSystem` node in `main.tscn`.

## Contract changes needed

- None.

## Open questions

- Painting placement density per room.
- Scene integration structure for `PortraitSystem` in `main.tscn`.

## Out of scope

- Cloth sheet draping gameplay UI (Haliyah's feature).
