# Progress Tracker

**Every agent and developer reads this file at the start of every session.**
Each owner edits **only their own section**. The **Integration** section and the "On `main`" block belong to the Integration owner.

Status key: 🟢 on track · 🟡 at risk · 🔴 blocked · ⚪ not started · ✅ done

---

## On `main` right now

_Updated 2026-10-05_

- Project directory structure, configuration files, and documentation framework initialized.
- Agent instructions (`AGENTS.md`, `GEMINI.md`, `CLAUDE.md`) established.
- `CONTRACTS.md` v0.1 draft prepared with shared data types and system interfaces.
- Feature templates created in `docs/templates/`.
- No game scenes or logic implemented yet.

## Milestones

| Milestone | Target Date | Status | Notes |
|---|---|---|---|
| **M0 GDD Submission** | **Wed 2026-10-07** | 🟢 | Docs and contracts v0.1 ready; awaiting team review |
| **M1 Playtest Slice** | **Fri 2026-10-09** | ⚪ | Working 4-system greybox house loop in `main.tscn` |
| **M2 Final Game Delivery** | **Fri 2026-10-16** | ⚪ | Full 5-room layout, climax escape, web export. Code freeze Thu 10-15 |

---

## Integration: John

- **Status:** 🟢 · **Branch:** `integration/04-web-export` · **Current feature:** `integration/04-web-export` · **Updated:** 2026-10-09 (Codex)
- **Done:** Project documentation, agent guidelines, templates, directory structure, `systems/shared/game_types.gd`, `systems/core/room_volume.gd`, `systems/core/main.tscn` (5-room Central Hub greybox + driveway + sockets), and layout tests in `tests/core/test_house_layout.gd`. Branch pushed to `origin/integration/01-greybox-house`.
- **In progress:** Adding a single-threaded Godot Web export preset for deployment at `https://gamedevrocky.github.io/project-3/`.
- **Next:** Validate the release export and full GUT suite, then push the configuration to `main`.
- **Needs from others:** Review by review pairs (Haliyah, Rocky, Daniel) and sign-off on `CONTRACTS.md` v0.2.
- **Handoff notes:** `systems/core/main.tscn` has explicit socket nodes under `Sockets/`: `CarSocket` (with `TrunkSocket`), `BreakerPanelSocket`, `FamilyPortraitSocket`, `MovingBoxSockets` (4 boxes), `LightFixtureSockets` (5 room lights), `SwitchSockets` (5 wall switches), and `PaintingSockets` (4 wall paintings). Room occupancy is detected via `RoomVolumes` using `RoomVolume` Area3D triggers. The `Web` export preset writes `builds/web/index.html` with browser thread support disabled for GitHub Pages hosting.

---

## Portrait / Painting System: Haliyah

- **Status:** 🟡 · **Branch:** `portraits/01-painting-system` · **Current feature:** 01-painting-system · **Updated:** 2026-10-09 (Codex)
- **Done:** Reusable painting component, registry queries and occupancy guard, cloth cover, procedural paintings and trapped-ghost effect, family portrait carry hooks, standalone demo, GUT tests, integration guide.
- **In progress:** GUT suite is not available in the standalone portrait project; integration tests remain for the shared project.
- **Next:** Integrate with the shared `PaintingData`/`GameTypes` foundation and test the portrait component in the house scene.
- **Needs from others:** Shared foundation (`GameTypes`, `PaintingData`, root `project.godot`) and team approval on `CONTRACTS.md` v0.2.
- **Handoff notes:** Public signatures and signals follow `docs/CONTRACTS.md` §2.2. Room IDs are integer enum values until shared types land. The final family portrait remains eligible for ghost entry while carried to support D-005; occupied state persists through pickup/drop. Godot 4.7.2 headless demo load and 18 smoke checks pass. Open `systems/portraits/project.godot` for standalone visual checks. See `docs/features/portraits/README.md` for the Ghost, Electrical, Player, and ending seams.
---

## Electrical & Lighting: Rocky

- **Status:** 🟢 · **Branch:** `electrical/01-light-circuits` · **Current feature:** `electrical/01-light-circuits` · **Updated:** 2026-10-12 (Gemini CLI)
- **Done:** Implemented `systems/electrical/electrical_system.gd` (room lighting states, breaker state machine, 100W wattage drain and recharge simulation, public queries `is_room_lit`, `get_room_light_state`, `set_room_light`, `trip_breaker`, `reset_breaker`, `turn_on_all_lights`), `systems/electrical/electrical_system.tscn`, and GUT unit tests in `tests/electrical/test_electrical_system.gd` (8/8 passing).
- **In progress:** Verification and preparing branch PR for integration.
- **Next:** Integration into `systems/core/main.tscn` and bulb blowout mechanics (`electrical/02-bulb-flicker`).
- **Needs from others:** None (fully conforms to `CONTRACTS.md` v0.2 §2.1).
- **Handoff notes:** The sample electrical system is ready for Ghost / Monster testing! Ghost Monster can query `electrical.is_room_lit(room_id)` and `electrical.get_room_light_state(room_id)` directly, or connect to `electrical.light_state_changed` and `electrical.breaker_state_changed`. When `ElectricalSystem` is present under a common parent or scene root, `_check_light_reaction()` in `GhostMonster` works seamlessly.

---

## Player System: Daniel

- **Status:** ⚪ · **Branch:** None · **Current feature:** None · **Updated:** 2026-10-07
- **Done:** None yet.
- **In progress:** Reviewing `CONTRACTS.md` v0.2.
- **Next:** Feature `player/01-controller-and-carry` (first-person controller, dark-adaptation glow, item carrying, switch toggling).
- **Needs from others:** Shared contract approval.
- **Handoff notes:** Player handles raycast interactions (`E`), carrying boxes to the car trunk, and collision death when the monster attacks.

---

## Ghost / Monster System: John

- **Status:** 🟢 · **Branch:** `ghost/01-monster-system` · **Current feature:** `ghost/01-monster-system` · **Updated:** 2026-10-07
- **Done:** Implemented `systems/ghost/ghost_monster.gd` (FSM with DORMANT, FREE_ROAM, CHASE, PAINTING_BOUND modes, light reaction query, and lethal contact), `systems/ghost/ghost_monster.tscn` (procedural 3D shadow mesh and NavigationAgent3D), and GUT tests in `tests/ghost/test_ghost_system.gd`.
- **In progress:** Preparing PR into `main`.
- **Next:** Merge ghost system into `main` and wire into integration scene.
- **Needs from others:** Electrical system and portrait system method stubs.
- **Handoff notes:** The monster starts dormant (`DORMANT`) until power is activated. It queries parent nodes for `ElectricalSystem` and `PortraitSystem` to handle light freezing and painting occupancy.
