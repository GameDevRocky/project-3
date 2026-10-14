# 02-breaker-panel: Spec

| | |
|---|---|
| System / Owner | Electrical & Lighting / Rocky |
| Branch | `electrical/02-breaker-panel` |
| Status | Approved (2026-10-14) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Playtest (M1) |

## 1. Overview

This feature provides the interactable `BreakerPanel` component in `systems/electrical/` mounted in the basement. It serves two core functions in the game loop: activating the house lights and starting the 100W power grid during the Phase 0 onboarding phase, and allowing the player to reset the circuit breaker after a blackout.

## 2. Player-Facing Behavior

1. **Phase 0 Startup:** The player walks through the unlit house to the basement and presses `E` on the breaker box. All house lights instantly turn ON, illuminating the house and concluding Phase 0.
2. **Blackout Recovery:** If the power meter reaches 0.0 W and trips the breaker, plunging the house into darkness, the player can trek back down to the basement and press `E` on the panel to restore power to full 100.0 Watts.

## 3. Scenes and Files

| Path | Purpose |
|---|---|
| `systems/electrical/breaker_panel.gd` | StaticBody3D interactable breaker panel logic |
| `systems/electrical/breaker_panel.tscn` | 3D scene with BoxShape3D collider and mesh |
| `systems/core/main.tscn` | Instanced under `Sockets/BreakerPanelSocket` |
| `tests/electrical/test_breaker_panel.gd` | Unit tests for panel interactions and player raycast |

## 4. Done When

- [ ] `BreakerPanel` script and scene implemented on collision layer 1.
- [ ] Interacting flips breaker and turns on all lights when all lights are off.
- [ ] Interacting resets tripped breaker and restores 100W grid reserve.
- [ ] Replaces static placeholder in `main.tscn` under `Sockets/BreakerPanelSocket`.
- [ ] All unit tests pass 100% headless.
