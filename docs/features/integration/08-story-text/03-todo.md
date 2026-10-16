# 08-story-text: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `integration/story-text`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved by the owner
- [x] Contract changes approved (none required)
- [x] `02-plan.md` written
- [x] `PROGRESS.md`: branch and current feature set

## Iteration 1: Intro Overlay & Narrative Tooltips
- [x] Step 1.1 & 1.2: Implement intro story overlay, dismissible via E/Space, and event tooltips for breaker wakeup, low voltage, and ghost shadow movement in `game_hud.gd` / `game_coordinator.gd`

## Iteration 2: Horror Audio & Jumpscare
- [x] Step 2.1 & 2.2: Implement chase rumbling drone, painting audio cues, and jumpscare flash/audio upon player capture in `procedural_audio.gd` and `game_hud.gd`

## Iteration 3: Narrative Endings & Verification
- [x] Step 3.1 & 3.2: Implement rich narrative ending texts in `game_coordinator.gd` and run full headless GUT test suite

## Verify
- [x] Full GUT suite passes headless
- [x] Every "Done when" item in `01-spec.md` is met
- [x] Pulled `origin/main` into the branch; feature wired and verified

## PR
- [x] Pulled `origin/main` right before pushing; re-ran the suite
- [ ] PR opened with summary, interfaces touched, how to test, and test results
