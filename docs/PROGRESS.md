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

- **Status:** 🟢 · **Branch:** `integration/bug-fixes` · **Current feature:** `09-bug-fixes` · **Updated:** 2026-10-15 (Gemini CLI)
- **Done:** Implemented 7 major bug fixes and polish items: dropping carried items with `G`; fixed ghost collision mask (Layer 2) ensuring lethal contact while carrying boxes; fixed ghost floor clamping and slope navigation via `move_and_slide()`; added raycast wall line-of-sight occlusion (`_has_line_of_sight_to_player()`) preventing seeing through walls; ensured ghost stays locked inside carried family portrait; and added 1.5s game-over input cooldown preventing immediate restart so endings can be read. Full headless GUT test suite passes 14 scripts, 65 tests, and 331 assertions with zero errors.
- **In progress:** Ready for PR into `main`.
- **Next:** Push branch and open PR.
- **Needs from others:** None.
- **Handoff notes:** Press G to drop carried items. Ghost navigates slopes and respects solid walls for line of sight. Endings feature a 1.5s read delay before restart.

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

- **Status:** 🟢 · **Branch:** `electrical/04-energy-tuning` · **Current feature:** `04-energy-tuning` · **Updated:** 2026-10-15 (Gemini CLI)
- **Done:** Completed 250W energy retuning: 250W grid capacity, continuous generator recharge (+4.0 W/s base), 2.0 W/s drain per lit room, break-even at 2 rooms (0.0 W/s equilibrium), scaled warning thresholds (100W low voltage, 50W dimming, 25W critical flashing), and §9 Tuning Table update. Full headless GUT suite passes 14 scripts, 62 tests, and 324 assertions with zero errors.
- **In progress:** Ready for PR into `main`.
- **Next:** Push branch and open PR.
- **Needs from others:** None.
- **Handoff notes:** The grid continuously generates +4.0 W/s; 1 lit room recharges at +2.0 W/s, 2 lit rooms break even at 0.0 W/s, and 3-5 lit rooms net drain (-2.0 to -6.0 W/s). Low voltage warning banner displays below 100W, fixtures dim below 50W, and critical flashing triggers below 25W. Breaker reset restores 250W.

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

- **Status:** 🟢 · **Branch:** `ghost/prevent-basement-trap` · **Current feature:** `04-prevent-basement-trap` · **Updated:** 2026-10-15 (Gemini CLI)
- **Done:** Completed anti-containment system: Entry Hall 4.0 W/s heavy draw (breaks even alone with generator), 15s trapped shadow teleportation to unlit rooms upstairs, 10s lit threshold flicker sabotage on blocking circuits, synthesized 3D void phase chime in `procedural_audio.gd`, and §9 Tuning Table update. Full headless GUT suite passes 14 scripts, 65 tests, and 331 assertions with zero errors.
- **In progress:** Ready for PR into `main`.
- **Next:** Push branch and open PR.
- **Needs from others:** None.
- **Handoff notes:** The Entry Hall draws 4.0 W/s, making it break-even alone and draining if any other room is lit. Trapped ghost teleports to an unlit room after 15s with a distinct void chime and flickers blocking lights after 10s. Illuminated rooms remain barriers until flickered.
