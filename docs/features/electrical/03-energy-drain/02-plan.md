# 03-energy-drain: Plan

| | |
|---|---|
| System / Owner | Electrical & Lighting / Rocky |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. Implement `systems/electrical/power_meter_hud.gd` and `power_meter_hud.tscn` (ProgressBar, wattage text, rate label, warning banner).
2. Wire low-voltage dimming and HUD attachment into `systems/electrical/electrical_system.gd`.
3. Implement unit tests in `tests/electrical/test_power_meter_hud.gd`.
4. Run full headless GUT test suite and verify 100% pass.
5. Update `docs/PROGRESS.md` and commit changes.

## 2. Iterations and Steps

### Iteration 1: PowerMeterHUD Implementation & Signal Wiring
- **Step 1.1:** Build `power_meter_hud.gd` and `.tscn` with UI nodes and signal handlers.
- **Step 1.2:** Implement unit tests in `tests/electrical/test_power_meter_hud.gd` verifying progress bar updates, rate labels, and warning colors.

### Iteration 2: Environmental Feedback & System Integration
- **Step 2.1:** Update `systems/electrical/electrical_system.gd` to instance `PowerMeterHUD` and apply low-voltage fixture dimming when power < 15W.
- **Step 2.2:** Verify with full GUT suite headless and check in `main.tscn`.
