# 04-energy-tuning: Spec

| | |
|---|---|
| System / Owner | Electrical & Lighting / Rocky |
| Branch | `electrical/04-energy-tuning` |
| Status | Approved by user on 2026-10-15 |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Final Game Delivery |

## 1. Overview

This feature tunes the electrical system's wattage economy, expanding capacity from 100W to **250W** and introducing continuous generator recharge. Rather than only recharging in total pitch darkness, the generator provides a constant `+4.0 W/s` charge. Each illuminated room consumes `2.0 W/s`. Consequently:
- With **1 room lit**, the grid actively recharges (`+2.0 W/s`).
- With **2 rooms lit**, the grid achieves break-even equilibrium (`0.0 W/s`).
- With **3, 4, or 5 rooms lit**, the grid drains (`-2.0`, `-4.0`, `-6.0 W/s`), punishing unmanaged lighting.
Thresholds are retuned to **100W** (low voltage), **50W** (environmental dimming & flicker), and **25W** (critical flashing).

## 2. Player-facing behavior

- **HUD Display:** The HUD wattage bar scales to `250 W`. The status label clearly indicates net rate:
  - When net rate is positive: `RECHARGING: +X.X W/s (Y rooms)` in green.
  - When net rate is zero (2 rooms lit): `GRID EQUILIBRIUM: 0.0 W/s (2 rooms)` in soft white.
  - When net rate is negative: `DRAINING: -X.X W/s (Y rooms)` in white/amber.
- **Threshold Warnings:**
  - Above 100W: Green / normal operation.
  - Below 100W: Amber bar and `⚡ LOW VOLTAGE WARNING` banner.
  - Below 50W: Light fixtures noticeably dim and paranormal flickers destabilize bulbs.
  - Below 25W: Red bar, red flashing status text, and `⚡ CRITICAL VOLTAGE — LIGHTS DESTABILIZING` banner.
  - At 0W: Master breaker trips into blackout.
- **Breaker Reset:** Resetting the breaker panel in the basement restores the full 250W capacity.

## 3. Rules and numbers

| Parameter | Value | Source |
|---|---|---|
| Max Power Grid Capacity | 250.0 Watts | Decision D-ET-1 |
| Base Continuous Recharge Rate | 4.0 W/s | Decision D-ET-2 |
| Drain Rate Per Lit Room | 2.0 W/s | Decision D-ET-2 |
| Break-even Lit Rooms | 2 rooms (`net_rate = 0.0`) | Decision D-ET-2 |
| Maximum Drain Rate (5 rooms) | -6.0 W/s (~42s to blackout) | Decision D-ET-2 |
| Low Voltage Warning Threshold | 100.0 Watts | Decision D-ET-3 |
| Light Fixture Dimming Threshold | 50.0 Watts | Decision D-ET-3 |
| Dimming Rearm Threshold | 60.0 Watts | Decision D-ET-3 |
| Critical Flashing Voltage Threshold | 25.0 Watts | Decision D-ET-3 |
| Breaker Trip Threshold | 0.0 Watts | `CONTRACTS.md` §2.1 |
| Breaker Reset Power | 250.0 Watts | Decision D-ET-1 |

## 4. Interfaces

**Uses:**
- `CONTRACTS.md` §1.1: `GameTypes.RoomId`, `GameTypes.BreakerState`, `GameTypes.LightState`.

**Provides / Emits:**
- `power_meter_updated(current_watts: float, max_watts: float)`
- `breaker_state_changed(new_state: GameTypes.BreakerState)`
- `light_state_changed(room_id: GameTypes.RoomId, new_state: GameTypes.LightState)`

**Contract changes:**
- None.

## 5. Scenes and files

| Path | New / Changed | Purpose |
|---|---|---|
| `systems/electrical/electrical_system.gd` | Changed | Update `max_power = 250.0`, `recharge_rate = 4.0`, `drain_rate_per_room = 2.0`, continuous net calculation, and dimming thresholds (50W/60W). |
| `systems/electrical/power_meter_hud.gd` | Changed | Update HUD warning thresholds (100W / 25W) and equilibrium display text. |
| `docs/GAME_SPEC.md` | Changed | Update §9 Tuning Table with new 250W numbers per Rule 6. |
| `tests/electrical/test_electrical_system.gd` | Changed | Update test assertions to reflect 250W baseline, net recharge, and 2.0 W/s drain. |
| `tests/electrical/test_power_meter_hud.gd` | Changed | Update test assertions for 250W thresholds (100W, 50W, 25W). |

## 6. Edge cases and failure modes

- **Grid at 250W with 1 room lit:** Power does not exceed 250W (clamped to `max_power`).
- **Blackout state (TRIPPED):** Generator does not recharge while breaker is tripped; requires manual reset in basement.
- **Rapid room toggling:** Net rate immediately recalculates on every `_process` frame and `light_state_changed`.

## 7. Done when

- [x] `max_power` and `reset_breaker()` restore to 250.0 Watts.
- [x] Base recharge is 4.0 W/s and per-room drain is 2.0 W/s.
- [x] 1 lit room net recharges at +2.0 W/s; 2 lit rooms break even at 0.0 W/s.
- [x] 3, 4, 5 lit rooms net drain at -2.0, -4.0, -6.0 W/s.
- [x] Low Voltage warning triggers below 100W (amber).
- [x] Light fixture dimming and flicker trigger below 50W (rearming above 60W).
- [x] Critical voltage flashing triggers below 25W (red).
- [x] Master breaker trips at 0W and resets to 250W.
- [x] `GAME_SPEC.md` Tuning Table updated.
- [x] Full GUT test suite passes with 0 errors.
