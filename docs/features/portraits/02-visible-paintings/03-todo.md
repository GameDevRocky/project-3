# 02-visible-paintings: TODO

Mirrors [02-plan.md](02-plan.md).

## Setup
- [x] Synced main and created branch portraits/02-visible-paintings
- [x] 00-brainstorm.md written
- [x] 01-spec.md written and approved by the user's detailed request
- [x] Contract changes approved (none needed)
- [x] 02-plan.md written
- [x] PROGRESS.md: branch and current feature set

## Iteration 1: Coverage and registration
- [x] Step 1.1: Add house layout and startup-state tests
- [x] Step 1.2: Add seven wall paintings in a PortraitSystem-owned house scene

## Iteration 2: Occupied canvas representation
- [x] Step 2.1: Test that occupied canvas uses the current ghost mesh
- [x] Step 2.2: Render the ghost capsule into the canvas artwork
- [x] Step 2.3: Test transitions, cover/uncover, one occupied canvas, and family portrait behavior

## Iteration 3: Integrated verification
- [x] Step 3.1: Run portrait tests and complete GUT suite
- [x] Step 3.2: Validate and visually inspect the actual house and basement encounter setup

## Verify
- [x] Full GUT suite passes headless with no script errors (15 scripts, 58 tests, 378 assertions)
- [x] Every Done when item in 01-spec.md is met
- [x] Run Project visual check confirms canvas rendering and reachable placements
- [x] Pull origin/main before push and re-run tests and Run Project

## PR
- [x] Push feature branch (`f118217`)
- [ ] Open PR into main (not requested)
- [ ] Review by John and Daniel

## Follow-up feedback
- [x] Add a visible G drop action for carried dust sheets; release the carry slot and allow box pickup.
- [x] Improve the physical ghost silhouette's in-canvas contrast and eye visibility while reusing the existing mesh.
- [x] Hang the basement side-wall painting below the utility pipe and test its clearance.
- [x] Re-run all GUT tests and verify the basement painting transfer in the live house.
- [ ] Sync with origin/main, rerun tests and Run Project, then push these follow-up fixes.
