# Portrait System integration guide

The implementation lives in `systems/portraits/`. Open that directory as a Godot project to run its test room; it uses the Compatibility renderer and has no plugin or external asset requirements.

## Public seam

`PortraitSystem` emits the contract signals `painting_state_changed(painting_id, data)`, `monster_occupancy_changed(painting_id, has_monster)`, `family_portrait_picked_up()`, and `family_portrait_dropped(room_id, position)`. The contract methods are implemented on the registry: room and eligibility queries, occupancy mutation, cover/uncover, held state, and family data. Additional helpers include nearest valid painting, `enter_painting` / `exit_painting`, active-state mutation, status query, family pickup/drop, and safe-removal query.

| Teammate | Connects to |
|---|---|
| John / Ghost | Query `get_valid_entry_paintings(room_id)` or `find_nearest_valid_entry_painting(room_id, position)`. Call `set_monster_occupied(id, true)` when entry is decided and `set_monster_occupied(id, false)` on exit. A `false` return means the request was invalid or there is no eligible slot. Read `get_occupied_painting_id()` as needed. The registry never moves the ghost or reads room lighting. |
| Rocky / Electrical | No direct dependency. Electrical reports room lights to John's Ghost System; when occupancy changes, this system displays the ghost trapped in the canvas. |
| Daniel / Player | Raycast focus can target `PortraitPainting`. Use `get_interaction_prompt()`, `interact(has_dust_sheet, all_boxes_loaded, carry_socket)`, or call the specific manager helpers. Supply the carry socket and four-box condition from Player/objective state. Drop uses the target room, transform, and world parent. No Daniel script is referenced. |
| Objective / ending | Read `get_family_portrait_data()`, `is_family_portrait_held()`, and `is_family_portrait_safe_to_remove()`. The family portrait is unsafe to take outside when occupied; this subsystem does not decide the ending. |

## State and transition notes

- Painting IDs must be non-empty and unique. Duplicate registration is rejected with a warning.
- Eligibility means active, uncovered, and unoccupied. The final family portrait may be entered while carried for the climax in D-005; ordinary carried paintings are ineligible.
- Registry occupancy is single-owner. Covering blocks future entry immediately. Occupancy and visuals remain when the family portrait is carried or dropped.
- Family pickup enforces the caller-provided four-box gate, rejects a missing carry socket, and preserves occupancy so ending logic can detect the failure condition.
- `room_id` is an integer carrying the `GameTypes.RoomId` enum value until `systems/shared/` is added. `PaintingData` is currently defined in this subsystem and mirrors the shared contract fields; migrate it to the jointly owned shared location during integration rather than maintaining two resource classes.

## Demo controls

WASD moves; click captures the mouse; mouse moves the view; Esc releases the mouse. Aim at a frame and press E to interact with an ordinary frame or take/drop the family portrait; C drapes/removes a sheet on any frame. X toggles the targeted frame active/inactive. G makes the test ghost enter the nearest eligible frame; T attempts entry into the focused frame (including rejection feedback); H exits it. B simulates all four boxes loaded. Q drops the family portrait. The test room is intentionally not the production player controller.

## Validation

GUT tests are in `tests/portraits/test_portrait_system.gd`. The standalone subproject also includes a dependency-free smoke test that runs with `godot --headless --path systems/portraits --script res://demo/smoke_test.gd`. Visual checks are through `systems/portraits/project.godot` and `demo/demo.tscn`.
