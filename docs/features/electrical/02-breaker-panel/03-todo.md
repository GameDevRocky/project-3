# 02-breaker-panel: TODO

Mirrors [02-plan.md](02-plan.md). Tick each box in the same commit as the work.

## Setup
- [x] Synced `main` and created branch `electrical/02-breaker-panel`
- [x] `00-brainstorm.md` written
- [x] `01-spec.md` written and approved
- [x] `02-plan.md` written

## Iteration 1: BreakerPanel Logic & Unit Tests
- [x] Step 1.1: Implement `systems/electrical/breaker_panel.gd` and `.tscn` with `interact()` method and collision shape
- [x] Step 1.2: Implement `tests/electrical/test_breaker_panel.gd` testing Phase 0 startup, blackout reset, and player interaction raycast

## Iteration 2: Scene Integration & Verification
- [x] Step 2.1: Wire `BreakerPanel` into `systems/core/main.tscn` under `Sockets/BreakerPanelSocket`
- [x] Step 2.2: Verify headless GUT test suite across core, electrical, player, and portraits suites

## Verify
- [x] Every "Done when" item in `01-spec.md` is met
- [x] All 27 automated tests pass 100% headless
