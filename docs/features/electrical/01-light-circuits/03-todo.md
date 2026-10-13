# 01-light-circuits: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `electrical/01-light-circuits`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved
- [x] Contract changes approved (none needed)
- [x] `02-plan.md` written
- [x] `PROGRESS.md`: branch and current feature set

## Iteration 1: Contract Methods & Circuit States
- [x] Step 1.1: Write unit tests in `tests/electrical/test_electrical_system.gd` for circuit states and queries
- [x] Step 1.2: Implement `systems/electrical/electrical_system.gd` and `systems/electrical/electrical_system.tscn`

## Iteration 2: Wattage Simulation & Breaker State Machine
- [x] Step 2.1: Write unit tests for wattage drain, recharge, automatic tripping, and breaker reset
- [x] Step 2.2: Implement `_process(delta)` power simulation, trip logic, and reset handling

## Iteration 3: Verification & Documentation
- [x] Step 3.1: Run headless GUT test suite and confirm 100% pass
- [x] Step 3.2: Update `docs/PROGRESS.md` with Rocky's status and handoff notes

## Verify
- [x] Every "Done when" item in `01-spec.md` is met
- [x] Electrical tests pass 100% headless in GUT

## PR
- [ ] Pulled `origin/main` right before pushing; re-ran suite
- [ ] PR opened into `main`
- [ ] Merged into `main`
