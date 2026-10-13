# 01-light-circuits: Brainstorm

| | |
|---|---|
| System | Electrical & Lighting |
| Owner | Rocky |
| Branch | `electrical/01-light-circuits` |
| Agent | Gemini CLI |
| Date | 2026-10-12 |
| Milestone | Playtest (M1) |

## Goal

Implement the baseline Electrical & Lighting System (`systems/electrical/electrical_system.gd` & `.tscn`) providing room lighting circuits, breaker state machine (`OPERATIONAL` / `TRIPPED`), 100W wattage drain and recharge economy, and public contract queries (`is_room_lit`, `get_room_light_state`, `set_room_light`, `trip_breaker`, `reset_breaker`, `turn_on_all_lights`) to unblock the Ghost / Monster System light-reaction AI and player interaction.

## Grounding

What the spec already fixes:
- `GAME_SPEC.md` §4, §5 (Seam 1 & 2): Electrical system writes room light states (`ON`, `OFF`) and power budget. Monster reads light state to decide between free roaming and forced painting freezing. Player interacts with switches to toggle lights.
- `GAME_SPEC.md` §9 (Tuning Table):
  - Max Power Grid Capacity: 100.0 Watts.
  - Light Drain Rate Per Room: 1.0 W/s per lit room.
  - Grid Recharge Rate: 5.0 W/s when all rooms are dark.
  - Breaker Trip Threshold: 0.0 Watts (plunges house into darkness).
  - Breaker Reset Value: 100.0 Watts (full restore upon resetting).
- `CONTRACTS.md` §1.1: `GameTypes.LightState` (`OFF`, `ON`, `FLICKERING`), `GameTypes.BreakerState` (`OPERATIONAL`, `TRIPPED`), `GameTypes.RoomId`.
- `CONTRACTS.md` §2.1:
  - Signals: `light_state_changed`, `breaker_state_changed`, `power_meter_updated`, `bulb_blown`.
  - Methods: `get_room_light_state`, `is_room_lit`, `get_current_power`, `get_lit_room_count`, `set_room_light`, `trip_breaker`, `reset_breaker`, `turn_on_all_lights`.

## Q&A

1. **Q:** What should the initial power and light state be when the ElectricalSystem initializes?
   **A:** Breaker operational, all rooms start OFF (darkness), and power initialized to 100.0 Watts (or turned ON via `turn_on_all_lights()` during Phase 0 startup). · *why:* Matches `GAME_SPEC.md` §7 Phase 0 startup sequence, where the house starts dark until breaker interaction restores lighting.
2. **Q:** What happens when the power meter drops to 0.0 W?
   **A:** The breaker trips automatically (`BreakerState.TRIPPED`), cutting all room lights to `LightState.OFF` and emitting `breaker_state_changed` and `light_state_changed`. · *why:* Directly mandated by `GAME_SPEC.md` Seam 2 and Decision D-003.
3. **Q:** Can lights be turned ON while the breaker is TRIPPED?
   **A:** No. `set_room_light` will reject turning lights ON when breaker is TRIPPED, and `is_room_lit` returns `false`. · *why:* Enforces blackout realism and forces the player to reset the breaker panel in the basement.
4. **Q:** How does `ElectricalSystem` integrate with 3D scene lights if placed in `main.tscn`?
   **A:** It maintains room state dictionaries and can automatically find and toggle child or scene-linked light fixtures in `LightFixtureSockets` matching room names. · *why:* Allows clean headless unit testing without requiring scene nodes, but controls visual `OmniLight3D` fixtures when placed in the house.

## Decisions

- Implement `systems/electrical/electrical_system.gd` inheriting `Node3D`.
- Track room states using `Dictionary[int, int]` (mapping `GameTypes.RoomId` to `GameTypes.LightState`).
- Maintain power reserve with 100.0W max, 1.0 W/s drain per lit room, and 5.0 W/s recharge when 0 rooms are lit.
- Automatic trip when power reaches 0.0W; manual trip via `trip_breaker()`; reset via `reset_breaker()`.
- Provide `systems/electrical/electrical_system.tscn` scene.

## Contract changes needed

- None. Fully adheres to `CONTRACTS.md` v0.2 §2.1.

## Open questions

- None.

## Out of scope

- Paranormal bulb flickering / bulb blowout sequencing (reserved for feature `electrical/02-bulb-flicker`).
- Player interaction raycast logic (owned by Daniel in Player System).
