# Progress Tracker

**Every agent and developer reads this file at the start of every session.**
Each owner edits **only their own section**. The **Integration** section and the "On `main`" block belong to the Integration owner.

Status key: 🟢 on track · 🟡 at risk · 🔴 blocked · ⚪ not started · ✅ done

---

## On `main` right now

_Updated 2026-10-15_

- The five-room house now contains the complete GDD loop: restore power, pack four room-specific boxes, retrieve the family portrait, survive the blackout chase, and reach the car.
- The player can move, sprint with stamina, look with the mouse, interact by raycast, carry items and dust sheets, and receive objective/interaction feedback.
- The ghost wakes with the breaker, pursues through dark rooms, respects lit-room barriers, enters eligible paintings, can hide in the carried family portrait, and produces the safe/occupied ending split.
- The full GUT suite executes 14 scripts and passes 54/54 tests with 250 assertions and no script errors.
- GitHub Actions imports, tests, and exports the Godot 4.7.2 Web build on every PR and deploys `main` to GitHub Pages.
- The live build is available at `https://gamedevrocky.github.io/project-3/`.

## Milestones

| Milestone | Target Date | Status | Notes |
|---|---|---|---|
| **M0 GDD Submission** | **Wed 2026-10-07** | 🟢 | Docs and contracts v0.1 ready; awaiting team review |
| **M1 Playtest Slice** | **Fri 2026-10-09** | ⚪ | Working 4-system greybox house loop in `main.tscn` |
| **M2 Final Game Delivery** | **Fri 2026-10-16** | ⚪ | Full 5-room layout, climax escape, web export. Code freeze Thu 10-15 |

---

## Integration: John

- **Status:** 🟢 · **Branch:** `integration/minor-bug-fix` · **Current feature:** `07-minor-bug-fix` · **Updated:** 2026-10-15 (Gemini CLI)
- **Done:** Completed spec, plan, and setup for minor playtest bug fixes (dormant ghost visibility, carry/deposit gating, painting orientations, parlor alignment).
- **In progress:** Step 1.1: Monster dormancy visibility and collision.
- **Next:** Step 2.1: Carry & trunk gating, Step 3.1: Painting orientations & Parlor layout.
- **Needs from others:** None.
- **Handoff notes:** Gated box pickup and trunk deposit by game phase; ghost remains hidden and collision-free until breaker activation.

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

- **Status:** 🟢 · **Branch:** `electrical/03-energy-drain` · **Current feature:** `electrical/03-energy-drain` · **Updated:** 2026-10-14 (Gemini CLI)
- **Done:** Implemented `PowerMeterHUD` in `systems/electrical/power_meter_hud.gd` and `.tscn` displaying live wattage bar, drain rate per lit room (`-X.0 W/s`), recharge status (`+5.0 W/s`), low voltage warning (<25W amber, <10W red flashing), and blackout trip banner. Added low-voltage light fixture dimming in `electrical_system.gd` (<15W). Automated unit tests in `tests/electrical/test_power_meter_hud.gd` (6/6 passing, 20/20 electrical tests passing total).
- **In progress:** Ready for review and merge into `main`.
- **Next:** Climax breaker cutoff and paranormal bulb flickering mechanics (`electrical/04-bulb-flicker`).
- **Needs from others:** None.
- **Handoff notes:** The `PowerMeterHUD` automatically instantiates and binds to `ElectricalSystem` at runtime, providing real-time visual feedback for the 100W wattage economy, drain/recharge dynamics, and blackout alerts. Fixtures dim dynamically when power drops below 15W.

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
