# Portrait System — Specification

## Behavior
- Every `PortraitPainting` has a stable ID, integer room ID, family flag, active/covered/occupied/carried flags, and world transform; it exposes `get_interaction_prompt()` and `interact(has_dust_sheet, all_boxes_loaded, carry_socket)` for a Player System adapter.
- The registry tracks paintings by unique ID and exposes contract-compatible room/eligibility queries. Eligible means active, uncovered, and unoccupied. The final portrait remains eligible while carried to support the climax in D-005; ordinary carried paintings are ineligible.
- Occupancy entry is atomic at registry level: reject invalid or already occupied paintings and reject a second occupied painting. Exit clears the current occupant. State signals follow successful transitions only.
- Cover/uncover switches a visible draped cloth and immediately changes eligibility.
- Family portrait pickup requires all four boxes loaded. Drop detaches to a supplied world transform. Pickup preserves occupancy; `is_safe_to_remove_from_house()` returns false while occupied.
- Procedural canvas artwork, ornate layered wood/brass frame, dust-sheet, and low-cost canvas shader draw the trapped figure, face, warped brushwork, and entry/exit transition.

## Interfaces
Signals and methods listed in `docs/CONTRACTS.md` §2.2 are preserved. Extensions: `find_nearest_valid_entry_painting`, `can_enter_painting`, `get_occupied_painting_id`, `remove_family_portrait`, `drop_family_portrait`, and `is_family_portrait_safe_to_remove`.

## Scenes
- `systems/portraits/portrait_painting.tscn`: reusable interactive component.
- `systems/portraits/portrait_system.tscn`: registry manager.
- `systems/portraits/demo/demo.tscn`: independent test room and lightweight test-only interaction controller.

## Done when
- Unit tests cover unique registration, eligibility filters, nearest lookup, cover/uncover, invalid entry, single occupancy, exit, and carried portrait safety.
- Demo offers controls for every requested state transition and visual inspection.
- Godot headless parsing/tests run if an engine is available; limitations are reported accurately.
- No integration-owned or teammate-owned files are changed.
