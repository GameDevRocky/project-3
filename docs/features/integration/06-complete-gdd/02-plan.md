# 06-complete-gdd: Plan

| | |
|---|---|
| System / Owner | Integration / all four gameplay systems |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## Iteration 1: Player carry loop

1. Add failing player tests for unique item pickup, one-item capacity, dust-sheet state, box deposit, and family portrait carry.
2. Implement the carry socket, typed carry helpers, carryable box/dust-sheet components, trunk interaction, prompts, stamina, and dark adaptation.
3. Run the player tests and then the full suite.

## Iteration 2: Complete ghost behavior

1. Add failing ghost tests for wake-up, pursuit, painting manager synchronization, exit on darkness, collision death, carried-family entry, and exterior threshold behavior.
2. Complete the existing FSM without changing its frozen public contract.
3. Run the ghost tests and then the full suite.

## Iteration 3: Core coordination and objectives

1. Add failing core tests for phase transitions, room tracking, unique checklist progress, death/restart, climax blackout, win, and occupied-portrait loss.
2. Implement `GameCoordinator` and the HUD, connect existing signals, and compose all interactables in `main.tscn`.
3. Run the core tests and then the full suite.

## Iteration 4: Portrait, lighting, and presentation

1. Add tests for production portrait raycast interaction and sheet transfer.
2. Add portrait colliders/adapters, low-cost flicker/climax feedback, procedural room dressing, labels, and generated audio cues.
3. Run the full suite and inspect the integrated scene through Godot MCP.

## Iteration 5: Integrated verification

1. Run the complete GUT suite and reject any skipped script or `SCRIPT ERROR`.
2. Use Godot MCP to run deterministic scenarios for startup, four deposits, ghost capture/release, death, safe win, and occupied-portrait loss.
3. Run an interactive visual check, inspect editor/runtime errors, and export the Web preset.
4. Update the Integration progress/handoff notes. Do not push or open a PR without separate user approval.

