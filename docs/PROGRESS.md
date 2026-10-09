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

- **Status:** 🟢 · **Branch:** `integration/01-greybox-house` · **Current feature:** `integration/01-greybox-house` · **Updated:** 2026-10-07
- **Done:** Project documentation, agent guidelines, templates, directory structure, `systems/shared/game_types.gd`, `systems/core/room_volume.gd`, `systems/core/main.tscn` (5-room Central Hub greybox + driveway + sockets), and layout tests in `tests/core/test_house_layout.gd`. Branch pushed to `origin/integration/01-greybox-house`.
- **In progress:** PR opened for review (`integration/01-greybox-house` -> `main`).
- **Next:** Merge PR into `main`, then proceed with first-person player controller and car deposit trigger integration.
- **Needs from others:** Review by review pairs (Haliyah, Rocky, Daniel) and sign-off on `CONTRACTS.md` v0.2.
- **Handoff notes:** `systems/core/main.tscn` has explicit socket nodes under `Sockets/`: `CarSocket` (with `TrunkSocket`), `BreakerPanelSocket`, `FamilyPortraitSocket`, `MovingBoxSockets` (4 boxes), `LightFixtureSockets` (5 room lights), `SwitchSockets` (5 wall switches), and `PaintingSockets` (4 wall paintings). Room occupancy is detected via `RoomVolumes` using `RoomVolume` Area3D triggers.

---

## Portrait / Painting System: Haliyah

- **Status:** ⚪ · **Branch:** None · **Current feature:** None · **Updated:** 2026-10-05
- **Done:** None yet.
- **In progress:** Reviewing `CONTRACTS.md` v0.1.
- **Next:** Feature `portraits/01-painting-state` (covering, turning, active state logic).
- **Needs from others:** Shared contract approval.
- **Handoff notes:** Initial stub will define `PaintingData` resource management and queries.

---

## Electrical & Lighting: Rocky

- **Status:** ⚪ · **Branch:** None · **Current feature:** None · **Updated:** 2026-10-05
- **Done:** None yet.
- **In progress:** Reviewing `CONTRACTS.md` v0.1.
- **Next:** Feature `electrical/01-light-circuits` (light switches, room illumination states, breaker toggles).
- **Needs from others:** Shared contract approval.
- **Handoff notes:** Room lighting state is a core dependency for ghost navigation.

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

- **Status:** ⚪ · **Branch:** None · **Current feature:** None · **Updated:** 2026-10-05
- **Done:** None yet.
- **In progress:** Reviewing `CONTRACTS.md` v0.1.
- **Next:** Feature `ghost/01-movement-state-machine` (free roaming in dark, jumping into paintings when lit).
- **Needs from others:** Electrical light state signal and Portrait valid painting query stubs.
- **Handoff notes:** Ghost state machine will initially test against mock light and portrait interfaces.
