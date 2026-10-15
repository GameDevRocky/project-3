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

- [ ] Write failing core-loop tests.
- [ ] Implement coordinator, objectives, endings, and scene wiring.
- [ ] Core tests and full suite pass.

## Iteration 4: Presentation

- [ ] Add portrait production interaction tests.
- [ ] Add collision adapters, flicker, room dressing, labels, and generated audio.
- [ ] Full suite passes and Godot MCP visual inspection succeeds.

## Verify

- [ ] Complete GUT suite passes with every script executed and zero script errors.
- [ ] Godot MCP startup, box loop, ghost, death, climax, win, and loss scenarios pass.
- [ ] Run Project visual/playability check passes.
- [ ] Web export succeeds with threads disabled.
- [ ] Integration progress and handoff notes are current.
- [ ] Pulled `origin/main` immediately before any push and re-ran verification.
- [ ] PR opened only with user approval.
