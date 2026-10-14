# 03-energy-drain: Brainstorm

| | |
|---|---|
| System | Electrical & Lighting |
| Owner | Rocky |
| Branch | `electrical/03-energy-drain` |
| Agent | Gemini CLI |
| Date | 2026-10-14 |
| Milestone | Playtest (M1) |

## Goal

Provide visible, real-time energy drain feedback to the player via a dedicated Power Meter HUD (`systems/electrical/power_meter_hud.gd` & `.tscn`), live drain/recharge readouts, low-power visual alerts (<25W amber, <10W red flashing), and low-voltage light fixture dimming (<15W) so the 100W wattage economy creates active survival horror tension during gameplay.

## Grounding

- `GAME_SPEC.md` §4 & §9:
  - Max capacity: 100.0 Watts.
  - Drain rate: 1.0 W/s per lit room.
  - Recharge rate: 5.0 W/s when all rooms dark.
  - Breaker trip threshold: 0.0 Watts.
- `DECISIONS.md` D-009: "The electrical system operates on a 100 Watt resource meter. Each room with lights ON consumes 1 W/s. When all lights are turned OFF, power restores at 5 W/s. Reaching 0 W trips the master breaker, plunging the house into darkness and forcing a physical trek to the basement breaker panel."
- `CONTRACTS.md` §2.1: `power_meter_updated`, `light_state_changed`, `breaker_state_changed`.

## Decisions

1. **HUD Component:** Create `PowerMeterHUD` (`CanvasLayer`) under `systems/electrical/` with:
   - Progress bar depicting current reserve (0 to 100%).
   - Exact numerical readout (e.g. `84.2 W / 100 W`).
   - Rate readout: `-3.0 W/s (3 rooms on)` in red/amber or `+5.0 W/s [Recharging]` in green.
   - Breaker trip warning banner when blackout occurs.
2. **Low Power Warnings:**
   - When power is below 25W, the meter shifts to amber.
   - When power is below 10W, the meter pulses red with "CRITICAL POWER" text.
   - When power is below 15W, `ElectricalSystem` slightly dims active light fixtures to visually telegraph the impending blackout.
3. **Automatic Binding:** `PowerMeterHUD` is added to `ElectricalSystem` scene so it displays in game without requiring manual scene instancing.

## Contract changes needed

- None.

## Out of scope

- Complex pause menu or journal screens (in adherence with D-011).
