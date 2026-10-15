# 02-visible-paintings: Spec

| | |
|---|---|
| System / Owner | Portraits / Haliyah |
| Branch | portraits/02-visible-paintings |
| Status | Approved (2026-10-15, by the user's detailed feature request) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Final |

## 1. Overview

The Portrait System will add wall paintings to underrepresented rooms and keep a valid refuge near the basement spawn. Each added painting has a unique ID, correct room ID, faces into its assigned room, and starts active and uncovered. Existing initial paintings are also oriented toward their assigned room at registration. An occupied painting will composite a transparent render of the exact CapsuleMesh used by GhostMonster into the canvas shader, preserving the artwork and the existing entry/exit distortion while making the monster's physical silhouette visible within the image.

## 2. Player-facing behavior

The integrated house loads its added wall paintings only when the Portrait System is under the house geometry root. The house begins with uncovered and active paintings in the entry hall, parlor, study, dining room, and basement. Existing dust-sheet interactions continue to cover and uncover them without explanatory HUD copy. When the Ghost System marks a legal painting occupied, its capsule silhouette appears within the artwork with the current painted face detail and brush distortion. The silhouette fades and distorts into the canvas on entry, stays visible while occupied, and fades out on exit. Registry occupancy ensures only one canvas displays it at a time. The family portrait retains its current carry and ending behavior.

## 3. Rules and numbers

| Rule / constant | Value | Source |
|---|---|---|
| Initial paintings | 13 total, including the family portrait | Current six plus seven added paintings |
| Room counts | Entry Hall 2; Parlor 3; Study 3; Dining Room 2; Basement 3; Exterior 0 | House layout and this feature |
| Occupied body source | GhostMonster ShadowMesh CapsuleMesh | Existing ghost scene |
| Artwork render target | 192 x 256 pixels per painting, updated on occupancy | Portrait System implementation |
| Occupancy | At most one painting at a time | CONTRACTS.md §2.2 and registry invariant |

Every added painting is active, uncovered, unoccupied, and not carried at startup. The registry remains the only authority for eligibility: active, uncovered, unoccupied paintings are eligible. A covered painting stays ineligible until uncovered.

## 4. Interfaces

**Uses** (from other systems; link, don't redefine):
- CONTRACTS.md §2.2: PortraitSystem registration, get_valid_entry_paintings, set_monster_occupied, and occupancy signals.
- GAME_SPEC.md §5, Seam 3: Ghost occupancy sets the canvas state.

**Provides / emits:**
- No new public methods or signals. Existing state_changed and monster_occupancy_changed continue to track occupancy.

**Contract changes:** None.

## 5. Scenes and files

| Path | New / changed | Purpose |
|---|---|---|
| systems/portraits/house_paintings.tscn | New | Define seven reachable, room-assigned wall paintings in the Portrait System |
| systems/portraits/portrait_painting.gd | Changed | Render the existing monster mesh into the canvas texture when occupied |
| systems/portraits/canvas_paint.gdshader | Changed | Composite the physical silhouette into the painted image and preserve the entry/exit effect |
| tests/portraits/test_visible_paintings.gd | New | Verify house placement, registration, basement eligibility, visual source, transitions, covering, and family portrait invariants |
| docs/features/portraits/02-visible-paintings/ | New | Record scope, plan, and verification |
| docs/PROGRESS.md | Changed | Update the Portrait System handoff |

## 6. Edge cases and failure modes

- If GhostMonster requests entry into a covered, inactive, missing, or already occupied painting, registry eligibility continues to reject it.
- If the ghost exits or enters another painting, the old occupancy clears before the new one is set; only the new occupied painting retains the silhouette after its exit fade.
- If the monster enters the carried family portrait, its existing occupancy and safe-removal behavior remain unchanged.
- If the shared ghost scene or ShadowMesh cannot be loaded, report a Godot error and keep the ordinary canvas available.

## 7. Out of scope

- Ghost movement, chase, spawn, or timing changes.
- Main scene, room geometry, or other system edits.
- Tutorial or HUD text explaining the hidden cover rule.
- A separate 3D ghost actor in front of a painting.

## 8. Done when

- [x] Seven unique ordinary paintings are added and registered; the room counts match the table above.
- [x] Every painting starts uncovered and active; all existing dust-sheet behavior remains intact.
- [x] Occupied canvases display the existing GhostMonster capsule silhouette within the painted image.
- [x] Exiting or changing paintings removes the old canvas occupancy and leaves at most one physical silhouette visible.
- [x] A basement painting is registered, eligible, correctly assigned, and reachable from the monster's spawn room.
- [x] The family portrait still passes its pickup, carry, occupancy, and drop behavior.
- [x] Portrait tests and Godot validation run with no script or import errors.
- [x] Run Project in the actual main house confirms the in-canvas appearance and wall placement.
