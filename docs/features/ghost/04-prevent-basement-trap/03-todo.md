# 04-prevent-basement-trap: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `ghost/prevent-basement-trap`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved by the owner
- [x] Contract changes approved (none required)
- [x] `02-plan.md` written
- [x] `PROGRESS.md`: branch and current feature set

## Iteration 1: Entry Hall Heavy Draw
- [x] Step 1.1 & 1.2: Implement Entry Hall 4.0 W/s drain rate in `electrical_system.gd` with tests in `test_electrical_system.gd`

## Iteration 2: Shadow Teleportation & Flicker Sabotage
- [ ] Step 2.1 & 2.2: Implement 15s trapped dark teleportation and 10s lit threshold flicker sabotage in `ghost_monster.gd` with tests in `test_ghost_behavior.gd`

## Iteration 3: Void Phase Audio & Tuning Documentation
- [ ] Step 3.1: Connect `ghost_teleported` in `procedural_audio.gd` and synthesize void phase chime
- [ ] Step 3.2: Update `docs/GAME_SPEC.md` §9 Tuning Table per Rule 6
- [ ] Step 3.3: Full GUT suite passes headless
- [ ] Every "Done when" item in `01-spec.md` is met
- [ ] Pulled `origin/main` into the branch; feature wired and verified

## PR
- [ ] Pulled `origin/main` right before pushing; re-ran the suite
- [ ] PR opened with summary, interfaces touched, how to test, and test results
