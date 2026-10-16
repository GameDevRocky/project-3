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

- **Status:** ✅ · **Branch:** None · **Current feature:** None · **Updated:** 2026-10-15 (Codex)
- **Done:** Completed and wired the GDD gameplay loop across player carry/interactions, ghost pursuit and painting occupancy, electrical flicker, objectives/endings, HUD, procedural presentation, and generated audio. Added and enabled Godot MCP for development inspection. The synced full suite passes 14 scripts, 54 tests, and 250 assertions with no script errors. GitHub Actions run `38813442772` successfully imported, tested, exported Web, uploaded the artifact, and deployed GitHub Pages.
- **In progress:** None; the complete GDD branch is merged and deployed.
- **Next:** Perform the human-controlled desktop-browser playtest.
- **Needs from others:** Human verification of mouse feel, lighting balance, audio mix, chase difficulty, and overall browser playability. Codex will not launch editor play mode unless explicitly requested.
- **Handoff notes:** The complete loop is breaker → four unique boxes → family portrait → forced blackout → car. An occupied family portrait produces the loss ending; an empty one produces the escape ending. Depositing the portrait reparents it into the trunk instead of freeing the registered node. Mouse look uses `_input` so the HUD cannot consume movement. `.github/workflows/deploy-pages.yml` performs the authoritative single-threaded Web export and deploys only from `main`.

---

## Portrait / Painting System: Haliyah

- **Status:** 🟡 · **Branch:** `portraits/02-visible-paintings` · **Current feature:** 02-visible-paintings · **Updated:** 2026-10-15 (Codex)
- **Done:** Reusable painting component and registry, dust-sheet covers, family portrait carry hooks, plus 7 new registered house paintings (13 total). Initial frames face into their rooms. Occupied canvases render the existing GhostMonster capsule mesh in a portrait-local transparent SubViewport and composite it into the artwork with the existing entry/exit distortion.
- **In progress:** Follow-up playtest fixes are verified and ready for review on the feature branch.
- **Next:** Human review, especially of the G drop control in PlayerController; then merge the feature branch.
- **Needs from others:** Review by John and Daniel; no Ghost System integration changes are required.
- **Handoff notes:** Counts: Entry Hall 2, Parlor 3, Study 3, Dining 2, Basement 3, Exterior 0. All paintings start uncovered/active. GhostMonster's existing `set_monster_occupied` entry/exit calls correctly synchronize the canvas. The basement side-wall painting now hangs below the utility pipe. Follow-up feedback added a visible G drop prompt/key for carried sheets so players can resume picking up boxes; a removed sheet rests on the floor when dropped. Full GUT suite passes: 15 scripts, 58 tests, 378 assertions. Live-house verification showed the existing monster mesh and eyes visibly rendered inside basement paintings, including a transfer where the old canvas cleared and the new canvas became occupied. No changes were made to GhostMonster movement or chase logic.
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
