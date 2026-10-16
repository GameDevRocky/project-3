# 04-energy-tuning: Plan

| | |
|---|---|
| System / Owner | Electrical & Lighting / Rocky |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. **Iteration 1: Electrical System Wattage Economy:** Update `electrical_system.gd` with 250W max capacity, 4.0 W/s base recharge, 2.0 W/s per-room drain, continuous net power formula, and 50W dimming threshold. Verify with unit tests in `test_electrical_system.gd`.
2. **Iteration 2: HUD Warning Thresholds & Equilibrium Display:** Update `power_meter_hud.gd` with 100W low-voltage warning, 25W critical flashing, and clean equilibrium/net-rate HUD text. Verify with unit tests in `test_power_meter_hud.gd`.
3. **Iteration 3: Tuning Documentation & Full Verification:** Update `GAME_SPEC.md` §9 Tuning Table per Rule 6 and run the full headless GUT suite.

## 2. Iterations and steps

### Iteration 1: Electrical System Wattage Economy

- **Step 1.1:** Update unit tests in `tests/electrical/test_electrical_system.gd` to assert 250W capacity, net recharge with 1 room (+2.0 W/s), equilibrium with 2 rooms (0.0 W/s), net drain with 3–5 rooms (-2.0, -4.0, -6.0 W/s), and breaker reset to 250W.
- **Step 1.2:** Implement in `systems/electrical/electrical_system.gd`.

### Iteration 2: HUD Warning Thresholds & Equilibrium Display

- **Step 2.1:** Update unit tests in `tests/electrical/test_power_meter_hud.gd` asserting 100W amber warning, 25W red flashing, and equilibrium text.
- **Step 2.2:** Implement in `systems/electrical/power_meter_hud.gd`.

### Iteration 3: Tuning Documentation & Full Verification

- **Step 3.1:** Update `docs/GAME_SPEC.md` §9 Tuning Table.
- **Step 3.2:** Execute full headless GUT test suite across all 14 test scripts.

## 3. Prompts

### Prompt 1 (Step 1.1 & 1.2): Electrical System Economy
Files: `tests/electrical/test_electrical_system.gd`, `systems/electrical/electrical_system.gd`.
Test: Update existing tests and assert continuous net generation and 250W baseline.
Implement: `max_power = 250.0`, `recharge_rate = 4.0`, `drain_rate_per_room = 2.0`, continuous net calculation, 50W fixture dimming.

### Prompt 2 (Step 2.1 & 2.2): HUD Thresholds & Status Text
Files: `tests/electrical/test_power_meter_hud.gd`, `systems/electrical/power_meter_hud.gd`.
Test: Assert 100W low voltage, 25W critical, and equilibrium label.
Implement: Retune thresholds in `power_meter_hud.gd`.

### Prompt 3 (Step 3.1 & 3.2): Tuning Table and Verification
Files: `docs/GAME_SPEC.md`.
Implement: Update Tuning Table in `GAME_SPEC.md`.
Verify: Run full GUT test suite.
