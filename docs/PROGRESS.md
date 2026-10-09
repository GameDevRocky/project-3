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

- **Status:** 🟡 · **Branch:** `main` · **Current feature:** Foundation & Scaffolding · **Updated:** 2026-10-05
- **Done:** Project documentation, agent guidelines, templates, and directory structure.
- **In progress:** Foundation setup (shared types in `systems/shared/`, test runner setup).
- **Next:** `project.godot` input map and basic scene setup.
- **Needs from others:** Sign-off on `CONTRACTS.md` v0.1.
- **Handoff notes:** When adding new systems, keep each owner's scenes and scripts inside their dedicated `systems/<system>/` folder.

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
