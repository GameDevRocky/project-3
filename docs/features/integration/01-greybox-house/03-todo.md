# 01-greybox-house: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `integration/01-greybox-house`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved by the owner
- [x] Contract changes approved (none needed)
- [x] `02-plan.md` written
- [x] `PROGRESS.md`: branch and current feature set

## Iteration 1: Room Trigger Volumes & Shared Types
- [x] Step 1.1: Create `systems/shared/game_types.gd`
- [x] Step 1.2: Write `tests/core/test_room_volume.gd` and implement `systems/core/room_volume.gd`

## Iteration 2: Greybox House Geometry & Sockets
- [x] Step 2.1: Construct `systems/core/main.tscn` with 5 rooms, driveway, and socket placeholders
- [x] Step 2.2: Write `tests/core/test_house_layout.gd` verifying all rooms and sockets

## Verify
- [x] Every "Done when" item in `01-spec.md` is met
- [x] Verified geometry, room volumes, materials, and sockets in `systems/core/main.tscn`

## PR
- [ ] Pulled `origin/main` right before pushing; re-ran the suite
- [ ] PR opened with summary, interfaces touched, how to test, and test results
- [ ] Reviewed by a teammate (per review pairs)
- [ ] Merged into `main`

## Post-merge
- [ ] Pulled `main` and checked the feature on `main`
- [ ] `PROGRESS.md`: feature moved to Done, handoff notes written
- [ ] `TODO.md`: item ticked
- [ ] `DECISIONS.md`: any cross-system decisions logged
