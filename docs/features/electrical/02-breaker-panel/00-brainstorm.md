# 02-breaker-panel: Brainstorm

| | |
|---|---|
| System | Electrical & Lighting |
| Owner | Rocky |
| Branch | `electrical/02-breaker-panel` |
| Agent | Gemini CLI |
| Date | 2026-10-14 |
| Milestone | Playtest (M1) |

## Goal

Implement the interactable breaker box component (`BreakerPanel`) in `systems/electrical/` and wire it into `Sockets/BreakerPanelSocket` in `main.tscn` to enable Phase 0 startup onboarding (turning on all house lights) and blackout breaker resets (restoring 100W grid reserve).

## Grounding

- `GAME_SPEC.md` §7 (Phase 0 Startup): "Flip the breaker in the basement. The monster is dormant and cannot attack during this opening phase. Flipping the basement breaker turns on all house lights and activates the 100-watt power grid."
- `GAME_SPEC.md` §9 (Tuning Table): "Breaker Reset Value: 100.0 Watts. Flipping tripped breaker restores full 100W."
- `CONTRACTS.md` §2.1: `reset_breaker()`, `turn_on_all_lights()`, `breaker_state_changed`.

## Decisions

- Implement `BreakerPanel` as a `StaticBody3D` with collision layer 1 so `PlayerController`'s `InteractionRay` detects it.
- When interacted with:
  - If breaker is `TRIPPED`: calls `electrical.reset_breaker()`, restoring power to 100W and setting state to `OPERATIONAL`.
  - If breaker is `OPERATIONAL` and all lights are off (Phase 0): calls `electrical.turn_on_all_lights()`.
- Replace static `BreakerMesh` placeholder in `main.tscn` with `BreakerPanel` scene instance under `Sockets/BreakerPanelSocket`.

## Contract changes needed

- None.

## Out of scope

- Climax sequence breaker trip event (handled by Integration in Phase 2).
