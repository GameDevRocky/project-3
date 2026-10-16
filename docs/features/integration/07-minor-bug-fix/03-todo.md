# 07-minor-bug-fix: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `integration/minor-bug-fix`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved by the owner
- [x] Contract changes approved (none required)
- [x] `02-plan.md` written
- [x] `PROGRESS.md`: branch and current feature set

## Iteration 1: Monster Dormancy Visibility & Collision
- [x] Step 1.1: Implement dormant ghost hidden visibility and disabled collision in `ghost_monster.gd` with tests in `test_ghost_behavior.gd`

## Iteration 2: Carry & Trunk Phase Gating
- [x] Step 2.1: Enforce Phase 0 box pickup guard and trunk deposit gating in `carryable_item.gd`, `car_trunk.gd`, and `game_coordinator.gd` with tests in `test_carry_loop.gd`

## Iteration 3: Painting Orientations & Parlor Layout
- [ ] Step 3.1: Fix painting orientations in `main.tscn`, align Parlor depth to 6m, and center doorway labels in `house_presentation.gd` with tests in `test_house_layout.gd`

## Verify
- [ ] Full GUT suite passes headless
- [ ] Every "Done when" item in `01-spec.md` is met
- [ ] Pulled `origin/main` into the branch; feature wired into the game and verified

## PR
- [ ] Pulled `origin/main` right before pushing; re-ran the suite
- [ ] PR opened with summary, interfaces touched, how to test, and test results
