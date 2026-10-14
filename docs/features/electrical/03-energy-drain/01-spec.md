# 03-energy-drain: Spec

| | |
|---|---|
| System / Owner | Electrical & Lighting / Rocky |
| Branch | `electrical/03-energy-drain` |
| Status | Approved (2026-10-14) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Playtest (M1) |

## 1. Overview

This feature delivers visual and environmental representation of the power grid's real-time energy drain and recharge economy. It provides a non-intrusive on-screen Power Meter HUD (`PowerMeterHUD`), live drain rate calculations based on active house circuits, low-voltage visual warnings, and automatic blackout alerts.

## 2. Player-Facing Behavior

1. **Power Meter HUD:** A sleek, semi-transparent meter in the top-left corner displays:
   - Green/Cyan energy bar showing remaining capacity from 0 to 100W.
   - Text readout: `100.0 W / 100 W`.
   - Rate readout: e.g. `-2.0 W/s (2 rooms)` when lights are on, or `+5.0 W/s [Recharging]` in bright green when all rooms are dark.
2. **Low Power Escalation:**
   - `< 25.0 W`: Meter bar turns amber/yellow.
   - `< 10.0 W`: Meter flashes red with "LOW VOLTAGE WARNING".
   - `< 15.0 W`: House light fixtures noticeably dim, giving physical environmental feedback that a blackout is imminent.
3. **Blackout Alert:**
   - At `0.0 W`: Meter flashes "⚠️ BREAKER TRIPPED - RESET IN BASEMENT", guiding the player to the subterranean breaker panel.

## 3. Scenes and Files

| Path | Purpose |
|---|---|
| `systems/electrical/power_meter_hud.gd` | CanvasLayer script connecting to ElectricalSystem signals and updating UI |
| `systems/electrical/power_meter_hud.tscn` | CanvasLayer scene with ProgressBar, Labels, and styled panel |
| `systems/electrical/electrical_system.gd` | Updates to dim lights when power < 15W and bind HUD child |
| `tests/electrical/test_power_meter_hud.gd` | Automated unit tests for HUD states, rate calculations, and alerts |

## 4. Done When

- [ ] `PowerMeterHUD` implemented and displays power bar and text readouts.
- [ ] Connects cleanly to `power_meter_updated`, `light_state_changed`, and `breaker_state_changed`.
- [ ] Displays live drain rate (`-X W/s`) and recharge status (`+5 W/s`).
- [ ] Displays low power warning (< 25W, < 10W) and tripped blackout banner.
- [ ] Low-voltage dimming reflects in fixture energy when power < 15W.
- [ ] 100% of headless GUT tests pass.
