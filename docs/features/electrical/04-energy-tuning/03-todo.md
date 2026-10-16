# 04-energy-tuning: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `electrical/04-energy-tuning`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved by the owner
- [x] Contract changes approved (none required)
- [x] `02-plan.md` written
- [x] `PROGRESS.md`: branch and current feature set

## Iteration 1: Electrical System Wattage Economy
- [x] Step 1.1 & 1.2: Implement 250W capacity, 4.0 W/s base recharge, 2.0 W/s per-room drain, continuous net formula, and 50W dimming in `electrical_system.gd` with tests in `test_electrical_system.gd`

## Iteration 2: HUD Warning Thresholds & Equilibrium Display
- [x] Step 2.1 & 2.2: Implement 100W low-voltage warning, 25W critical flashing, and equilibrium status text in `power_meter_hud.gd` with tests in `test_power_meter_hud.gd`

## Iteration 3: Tuning Documentation & Full Verification
- [x] Step 3.1: Update `docs/GAME_SPEC.md` §9 Tuning Table per Rule 6
- [x] Step 3.2: Full GUT suite passes headless
- [x] Every "Done when" item in `01-spec.md` is met
- [x] Pulled `origin/main` into the branch; feature wired and verified

## PR
- [x] Pulled `origin/main` right before pushing; re-ran the suite
- [ ] PR opened with summary, interfaces touched, how to test, and test results
