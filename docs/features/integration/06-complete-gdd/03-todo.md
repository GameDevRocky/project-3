# 06-complete-gdd: TODO

## Setup

- [x] Synced `main` and created `integration/06-complete-gdd`.
- [x] Read project progress, contracts, game specification, workflow, and existing feature implementations.
- [x] Wrote brainstorm, spec, plan, and TODO documents.
- [x] Human approved the spec and cross-owner integration scope.
- [x] Human approved editing `main.tscn` and installing/enabling the Godot MCP addon.

## Iteration 1: Player carry loop

- [x] Write failing player tests.
- [x] Implement carrying, interactables, prompts, stamina, and dark adaptation.
- [x] Player tests and full suite pass (11 scripts, 39 tests, 185 assertions).

## Iteration 2: Ghost behavior

- [x] Write failing ghost tests.
- [x] Complete pursuit, light/painting transitions, death, carried portrait, and threshold behavior.
- [x] Ghost tests and full suite pass (12 scripts, 43 tests, 198 assertions).

## Iteration 3: Core gameplay loop

- [x] Write failing core-loop tests.
- [x] Implement coordinator, objectives, endings, and scene wiring.
- [x] Core tests and full suite pass (13 scripts, 48 tests, 220 assertions).

## Iteration 4: Presentation

- [x] Add portrait production interaction tests.
- [x] Add collision adapters, flicker, room dressing, labels, and generated audio.
- [x] Full suite passes and initial Godot MCP visual/runtime inspection succeeds.

## Verify

- [x] Complete GUT suite passes with every script executed and zero script errors (14 scripts, 54 tests, 250 assertions).
- [x] Godot MCP startup, box loop, ghost, death, climax, win, and loss scenarios pass.
- [x] Initial Run Project visual/playability inspection passed through Godot MCP; further hands-on playtesting is reserved for the human.
- [x] GitHub Actions Web export and Pages deployment succeed with threads disabled (run `38813442772`).
- [x] Integration progress and handoff notes are current.
- [x] Pulled `origin/main` immediately before the requested push and re-ran verification.
- [x] User explicitly approved a direct merge to `main` and push.
