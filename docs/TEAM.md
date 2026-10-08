# Team, ownership, and shared rules

| Area | Owner | Owned files | Interface crossing the boundary |
| --- | --- | --- | --- |
| **Portrait / Painting system** | Haliyah | `systems/portraits/`, `tests/portraits/`, `docs/features/portraits/` | Owns portrait location, room ID, covered/uncovered, active/inactive, family portrait tracking, and monster visual occupancy (`is_occupied`). Provides queries for valid entry paintings and emits `painting_state_changed`, `monster_occupancy_changed`. |
| **Electrical & Lighting** | Rocky | `systems/electrical/`, `tests/electrical/`, `docs/features/electrical/` | Owns circuits, room light states, breaker state, bulb condition, power grid budget (100W). Provides `get_room_light_state`, `is_room_lit`, `reset_breaker`, `turn_on_all_lights`; emits `light_state_changed`, `power_meter_updated`, `breaker_state_changed`. |
| **Player System** | Daniel | `systems/player/`, `tests/player/`, `docs/features/player/` | Owns player position, first-person camera, movement, carried items (boxes, sheet, portrait), dark-adaptation ambient glow, interaction raycast, alive/dead state. Provides `try_interact`, `deposit_box_in_car`, `kill_player`; emits `player_died`, `item_packed`. |
| **Ghost / Monster System** | John | `systems/ghost/`, `tests/ghost/`, `docs/features/ghost/` | Owns ghost location, state, chase state, movement mode, target, occupied portrait ID. Reads room light states (Electrical) and active/uncovered paintings (Portraits); emits `ghost_moved`, `ghost_entered_painting`, `player_killed`. |
| **Integration & Core** | John | `systems/core/` (`main.tscn`), `project.godot`, `export_presets.cfg`, `docs/features/integration/` | Wires systems together in `main.tscn`; input map, collision layers, autoloads, export presets. |
| **Assets** | Shared | `assets/`, `docs/ASSETS.md` | 3D models, textures, 2D portrait paintings, audio sound effects, ambient tracks. |
| **Shared contracts** | Joint (All) | `systems/shared/`, `tests/shared/`, `docs/CONTRACTS.md` | Jointly owned frozen data structures and interfaces. |

Exact signatures: [`CONTRACTS.md`](CONTRACTS.md). Game rules & mechanics: [`GAME_SPEC.md`](GAME_SPEC.md). Development process: [`WORKFLOW.md`](WORKFLOW.md).

---

## How we work separately but build one game

1. **Nobody waits on someone else's real implementation.** Contracts exist as typed GDScript files from the foundation feature in `systems/shared/`, with stub classes and mock interfaces. Each owner builds and tests their system against these stubs.
2. **Everyone tests alone with fakes.** Each area has its own test scenes in `systems/<system>/test/` and automated headless GUT tests in `tests/<system>/`.
3. **Merge small and often.** A small PR merged today beats a massive merge conflict tomorrow. Everyone pulls `main` before starting anything new.
4. **Integration checkpoints:**
   - **Checkpoint 0 (Wed 10-07):** GDD complete, `CONTRACTS.md` v0.2 signed off, repository architecture set up.
   - **Checkpoint 1 (Thu 10-08):** Foundation code merged (`systems/shared/`, `project.godot`), system stubs in place.
   - **Checkpoint 2 (Fri 10-09, Playtest):** Playable 4-system greybox slice working together in `main.tscn`.
   - **Checkpoint 3 (Tue 10-13):** Full 5-room layout connected, family portrait escape climax assembled.
   - **Checkpoint 4 (Thu 10-15 night, Code Freeze):** Bug fixes, tuning, web export verified.
   - **Checkpoint 5 (Fri 10-16):** Final game delivery.
5. **Communicate through the repo.** Keep `PROGRESS.md` updated with handoff notes and needs from others. Document cross-cutting decisions in `DECISIONS.md`.

---

## Review pairs (who reviews whose PRs)

Pairs follow the architectural seams so the reviewer is the person whose system directly interfaces with the code:

| Author | Area | Reviewer | Why |
|---|---|---|---|
| Rocky | Electrical & Lighting | John (Ghost) | Ghost movement and freezing are gated by room lighting state |
| John | Ghost / Monster System | Haliyah (Portraits) & Daniel (Player) | Monster jumps into uncovered paintings and kills player on contact |
| Haliyah | Portraits / Paintings | John (Ghost) & Daniel (Player) | Monster uses paintings as refuge; Player carries portraits and drapes sheets |
| Daniel | Player System | Rocky (Electrical) & John (Ghost) | Player toggles switches and triggers lethal collision with monster |
| John | Integration / Core | Haliyah / Rocky / Daniel | Integration touches shared project settings and `main.tscn` |

---

## Shared rules

- **Pull before starting anything new** (`git checkout main && git pull --ff-only`), then branch from `main`.
- **`main` is the only shared branch:** One branch per feature from `main`, PR into `main`, delete branch after merge.
- **Done = playable on `main`:** A feature is done when merged into `main`, wired into the game, and working alongside everyone else's code.
- **One owner edits a `.tscn` scene at a time:** Instance another owner's scene rather than copying it or modifying its internals.
- **Signals and public methods only:** Do not reach into another owner's node hierarchy using brittle paths like `get_node("../../OtherSystem/...")`.
- **Contracts change only through the change protocol:** Propose in `CONTRACTS.md`, log in `DECISIONS.md`, get teammate sign-off.
- **Never commit:** `.godot/`, `builds/`, credentials, or personal IDE settings.
