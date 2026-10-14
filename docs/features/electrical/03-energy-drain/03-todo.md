# 03-energy-drain: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `electrical/03-energy-drain`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved
- [x] `02-plan.md` written

## Iteration 1: PowerMeterHUD Implementation & Signal Wiring
- [x] Step 1.1: Build `power_meter_hud.gd` and `.tscn` with UI nodes and signal handlers
- [x] Step 1.2: Implement unit tests in `tests/electrical/test_power_meter_hud.gd`

## Iteration 2: Environmental Feedback & System Integration
- [x] Step 2.1: Update `systems/electrical/electrical_system.gd` to instance `PowerMeterHUD` and apply low-voltage fixture dimming when power < 15W
- [x] Step 2.2: Verify with full GUT suite headless and check in `main.tscn`

## Verify
- [x] Every "Done when" item in `01-spec.md` is met
- [x] All automated tests pass 100% headless
