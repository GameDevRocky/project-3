# 07-minor-bug-fix: Brainstorm

| | |
|---|---|
| System | Integration |
| Owner | John |
| Branch | `integration/minor-bug-fix` |
| Agent | Gemini CLI |
| Date | 2026-10-15 |
| Milestone | Final Game Delivery |

## Goal

Resolve four post-playtest oversights in the integrated house loop:
1. Prevent the monster from being visible standing dormant in the basement before power is restored.
2. Prevent moving boxes from being carried out/packed before flipping the breaker, and prevent taking the family portrait before the endgame.
3. Correct the orientation of `Painting_Basement_1` and verify orientation of all house paintings.
4. Correct the placement and dimensions of the Parlor room and its entrance label so it aligns with the rest of the house architecture.

## Grounding

- `GAME_SPEC.md` §3: Architectural layout (Entry Hall, Parlor, Study, Dining Room, Basement).
- `GAME_SPEC.md` §7: Objective flow: Phase 0 (Breaker), Phase 1 (Pack 4 boxes), Phase 2 (Family Portrait climax).
- `CONTRACTS.md` §2.3: `GhostMonster` state machine (`DORMANT`, `FREE_ROAM`, etc.).
- `CONTRACTS.md` §2.2: `PortraitSystem` and `PaintingData` properties (`is_family_portrait`, `is_being_carried`).

## Q&A

1. **Q:** What is the preferred alternative for the monster during Phase 0?
   **A:** Option 1: Keep the monster hidden (`shadow_mesh.visible = false` and collision disabled) while dormant. When the basement breaker is flipped for the first time, reveal/spawn the monster and play an awakening audio cue before it begins free roaming. · *why:* Preserves the suspenseful onboarding walk to the basement without exposing a static monster model in front of the breaker box.

2. **Q:** How should we enforce preventing boxes from being carried out before flipping the breaker, and family portrait before the endgame?
   **A:** Option 1: Block pickup at source & gate trunk. In Phase 0, moving boxes reject pickup with "Restore power at breaker first"; CarTrunk rejects box deposits before Phase 1. The family portrait cannot be removed until all 4 boxes are loaded (Phase 2), and CarTrunk rejects it earlier. · *why:* Gives immediate, clear player guidance without confusing door barriers or inconsistent carry states.

3. **Q:** Which paintings require re-orientation to face correctly into their respective rooms?
   **A:** Option 1: Fix all 4 misoriented paintings. Re-orient `Painting_Basement_1` to face East (+X) toward the stairs, `FamilyPortrait` to face North (-Z) into the foyer, `Painting_Parlor_1` to face East (+X), and `Painting_Study_1` to face West (-X). `Painting_Dining_1` and `Painting_Parlor_2` are already facing South into their rooms. · *why:* Eliminates backward and edge-on paintings throughout the entire house.

4. **Q:** How should the Parlor geometry and its entrance text be aligned with the rest of the house?
   **A:** Option 1: Flush 6m depth & centered doorway label. Align Parlor south wall to Z=0 and north wall to Z=-6 (depth 6m, matching Entry and Study facades). Center PARLOR label directly above the doorway at Z=-3.0, Y=2.5 facing East into Entry Hall (+X, yaw=PI/2). Move Parlor_2 north wall painting to Z=-5.85. · *why:* Makes the house exterior walls flush and aligns room signage properly over the threshold archway.

## Decisions

- **D-MBF-1:** Ghost monster remains invisible (`shadow_mesh.visible = false`) and non-colliding while dormant in Phase 0. Upon the first breaker flip, the monster becomes visible and active with an awakening audio sound.
- **D-MBF-2:** Moving boxes reject pickup during Phase 0 with prompt "Restore power at breaker first". `CarTrunk` rejects box deposit during Phase 0, and rejects family portrait deposit before Phase 2. The family portrait cannot be removed from the wall until all 4 boxes are loaded.
- **D-MBF-3:** Correct painting orientations across the house so all local +Z (canvas face) vectors point outward into the room:
  - `Painting_Basement_1` on west wall: Rotated to face East (+X) toward the stairs.
  - `FamilyPortrait` on south wall: Rotated to face North (-Z) into the entry foyer.
  - `Painting_Parlor_1` on west wall: Rotated to face East (+X) into the parlor.
  - `Painting_Study_1` on east wall: Rotated to face West (-X) into the study.
- **D-MBF-4:** Align Parlor room depth to 6.0m (Z: 0.0 to -6.0) matching Entry Hall and Study facade planes. Position PARLOR room label centered over doorway at `(-2.95, 2.45, -3.0)` with yaw `PI * 0.5` facing into the Entry Hall. Also align Study room label centered over doorway at `(2.95, 2.45, -3.0)` with yaw `-PI * 0.5` facing into Entry Hall. Move `Painting_Parlor_2` to Z=-5.85 against the new north wall.

## Contract changes needed

- None. All changes respect existing signatures and data contracts.

## Open questions

- None. All four playtest items decided.

## Out of scope

- New room geometry or changing puzzle core rules.
- Redesigning 2D/3D art assets.
