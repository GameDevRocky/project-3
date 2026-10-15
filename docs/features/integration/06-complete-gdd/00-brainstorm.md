# 06-complete-gdd: Brainstorm

| | |
|---|---|
| System / Owner | Integration / all four gameplay systems |
| Branch | `integration/06-complete-gdd` |
| Agent / Date | Codex / 2026-10-15 |
| Milestone | M2 Final Game Delivery |
| Status | Approved by user on 2026-10-15 |

## Goal

Turn the hosted greybox and isolated system prototypes into the complete, playable GDD loop: restore power, manage the 100W grid, carry four labeled boxes to the car, manipulate dust-sheets and paintings, survive the light-sensitive ghost, take the family portrait, and reach an explicit win or loss state.

## Decisions proposed

1. **Integration shape:** Add a `GameCoordinator` under `systems/core/` that connects the existing public signals and methods. Keep ownership of state inside the existing systems and do not change frozen contract signatures.
2. **Carry interaction:** Extend the Player implementation internally with a carry socket and typed interaction helpers while preserving all public methods in `CONTRACTS.md`.
3. **Ghost movement:** Use direct supernatural pursuit constrained by room/light rules and the exterior threshold. This avoids depending on an unbaked navigation mesh while retaining the GDD behavior of a ghost that moves unnaturally through the house.
4. **Climax:** Picking up the family portrait after all boxes are packed trips the breaker, releases the ghost, and begins the final pursuit. Reaching the trunk with an unoccupied portrait wins; reaching it with the ghost inside loses.
5. **Presentation:** Use lightweight procedural meshes, labels, shaders, UI, and generated audio cues so the Web build remains self-contained and Compatibility-renderer safe.
6. **Testing:** Add end-to-end integration tests for the objective phases, carry/deposit loop, breaker activation, ghost light/painting transitions, death, climax, and both endings.

## Constraints

- Godot 4.7.2, GDScript, static typing, Compatibility renderer, Web export, and no threads.
- Preserve every frozen contract signature and cross-system invariant.
- No third-party asset pack.
- Audio must begin only after a user input gesture in Web builds.
- `main` must remain untouched; all work stays on `integration/06-complete-gdd` until a reviewed PR is approved.

