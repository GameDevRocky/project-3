# 06-complete-gdd: Spec

| | |
|---|---|
| System / Owner | Integration / all four gameplay systems |
| Branch | `integration/06-complete-gdd` |
| Status | Approved by user on 2026-10-15 |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | M2 Final Game Delivery |

## 1. Player-facing flow

1. The player starts outside with the objective **Flip the breaker in the basement**. The ghost is dormant.
2. Interacting with the breaker turns on all five house lights, wakes the ghost, and advances to the four-box checklist.
3. The player can pick up one labeled box at a time, continue operating light switches while carrying it, and pack it at the car trunk. Each unique box checks off once.
4. The 100W grid drains by lit-room count, recharges while every room is dark, dims at low voltage, and trips at zero.
5. In darkness the ghost hunts the player. In a lit room it enters the nearest active, uncovered, unoccupied painting and remains visibly trapped until darkness returns.
6. A carried dust-sheet can cover an eligible painting. Removing a sheet returns it to the player's hand.
7. Direct contact with a roaming ghost kills the player and presents a restart flow.
8. After all four boxes are packed, the objective becomes **Take the family portrait**. Picking it up trips the breaker and begins the final pursuit.
9. Packing an unoccupied family portrait at the trunk wins. If the ghost reaches and occupies the carried portrait, attempting to leave loses.

## 2. Controls and feedback

- WASD movement, mouse look, Shift sprint with limited stamina, E/left-click interaction, and Esc cursor release.
- Central crosshair, contextual interaction prompt, top-right objective checklist, power HUD, stamina feedback, and full-screen win/loss overlays.
- A faint near-field player light activates only in darkness.
- Lightweight generated cues cover breaker activation/trip, box deposit, ghost painting entry/exit, chase, death, and victory. Audio starts only after the first interaction.

## 3. Implementation boundaries

- `systems/core/`: coordinator, objective/end-state UI, procedural presentation support, and integrated scene composition.
- `systems/player/`: internal carrying, item/trunk adapters, interaction prompts, stamina, and dark adaptation.
- `systems/ghost/`: complete existing FSM behavior, painting occupancy synchronization, pursuit, threshold, and lethal contact.
- `systems/portraits/`: add raycast interaction adapter/collision while preserving the existing portrait API.
- `systems/electrical/`: retain the existing grid implementation; add only climax/flicker polish that does not alter contracts.
- `tests/`: test each rule first, then add an integrated core-loop test.

No changes are proposed to `docs/CONTRACTS.md` or `systems/shared/`.

## 4. Done when

- [ ] A fresh run can complete all three objective phases and reach victory.
- [ ] Every loss condition produces a visible loss state and a working restart.
- [ ] All four boxes are unique, carryable, and depositable exactly once.
- [ ] Dust-sheet cover/uncover behavior affects ghost painting eligibility.
- [ ] The ghost wakes after the first breaker flip, hunts in darkness, enters/exits paintings correctly, cannot leave the house physically, and can occupy the carried family portrait.
- [ ] The climax trips the breaker and supports both the safe-portrait win and occupied-portrait loss.
- [ ] The complete HUD, prompts, crosshair, dark adaptation, and required audio cues work in desktop and Web runs.
- [ ] The full GUT suite runs every test script with zero `SCRIPT ERROR` output.
- [ ] Run Project is playable in the Godot editor and the Web export completes with threads disabled.

