# 03-make-scary: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `ghost/03-make-scary`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved by the owner
- [x] Contract changes approved (none required)
- [x] `02-plan.md` written
- [x] `PROGRESS.md`: branch and current feature set

## Iteration 1: Visuals & Eye Tracking Look-At
- [x] Step 1.1 & 1.2: Add emissive eyes, head pivot, and red halo to `ghost_monster.tscn`, implement player eye tracking look-at and chase emission flare with tests in `test_ghost_behavior.gd`

## Iteration 2: Dark Room Wandering AI
- [ ] Step 2.1: Implement multi-room dark waypoint wandering and proximity/room chase engagement in `ghost_monster.gd` with tests in `test_ghost_behavior.gd`

## Iteration 3: Positional Procedural Audio
- [ ] Step 3.1: Implement periodic 3D guttural roaming breathing and intense chase screech in `procedural_audio.gd` and `ghost_monster.gd`

## Verify
- [ ] Full GUT suite passes headless
- [ ] Every "Done when" item in `01-spec.md` is met
- [ ] Pulled `origin/main` into the branch; feature wired and verified

## PR
- [ ] Pulled `origin/main` right before pushing; re-ran the suite
- [ ] PR opened with summary, interfaces touched, how to test, and test results
