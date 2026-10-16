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
- **Done:** Implemented all playtest minor bug fixes: hidden/non-colliding ghost monster while dormant during Phase 0; light switch operation disabled during Phase 0 ("Restore power at breaker first"); moving box pickup and trunk deposit phase gating; family portrait phase gating; correct inward orientations for all house paintings; and flush 6m Parlor alignment with centered doorway labels. Full GUT suite passes 14 scripts, 60 tests, and 305 assertions with zero errors.
- **In progress:** PR #12 opened and updated on `main`.
- **Next:** Teammate review and merge.
- **Needs from others:** Review per review pairs (`TEAM.md`).
- **Handoff notes:** The ghost remains hidden and collision-free during Phase 0 until the basement breaker is flipped; light switches and boxes cannot be interacted with before Phase 1; all paintings face outward into rooms; Parlor CSG geometry aligns with exterior walls Z: 0 to -6.

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

- **Status:** 🟢 · **Branch:** `ghost/03-make-scary` · **Current feature:** `03-make-scary` · **Updated:** 2026-10-15 (Gemini CLI)
- **Done:** Completed horror enhancements: emissive red eyes on head pivot with player tracking, dark-room silhouette red halo visible across doorways, semi-random dark room waypoint wandering (`roam_speed = 1.8 m/s`), immediate lock-on chase screech with eye flare (`chase_speed = 3.2 m/s`), and procedural 3D positional audio cues (guttural breathing while roaming and jarring screech on chase). Headless GUT test suite passes 14 scripts, 62 tests, and 318 assertions with zero errors.
- **In progress:** Ready for PR into `main`.
- **Next:** Push branch and open PR.
- **Needs from others:** None.
- **Handoff notes:** Glowing red eyes rotate to track the player up to 15m; wandering passes through doorways connecting unlit rooms; entering the ghost's dark room triggers immediate chase screech and pursuit. Lighted rooms remain impassable barriers.
