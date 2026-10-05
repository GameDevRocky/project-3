# TODO: Project Backlog

The coarse backlog by milestone and owner. Each owner ticks **only their own items**. Detailed task checklists live in each feature's `03-todo.md` (or `FEATURE-lite.md`).

Scope and mechanics: [`GAME_SPEC.md`](GAME_SPEC.md). Typed seams: [`CONTRACTS.md`](CONTRACTS.md). Ownership: [`TEAM.md`](TEAM.md).

---

## M0: GDD & Foundation (Due Wed 2026-10-07)

- [ ] **All:** Read `CONTRACTS.md` v0.1 and sign P-001 in `DECISIONS.md`
- [ ] **Integration (John):** Foundation scaffolding
  - [x] Documentation structure, agent instructions, feature templates
  - [ ] Shared contract scripts in `systems/shared/`: `game_types.gd`, `painting_data.gd`, `ghost_state.gd`, `clue_event.gd`
  - [ ] Stub classes for each system (`ElectricalSystem`, `PortraitSystem`, `GhostSystem`, `EnvironmentSystem`)
  - [ ] GUT unit test framework setup in `addons/gut/` with smoke test in `tests/shared/test_contracts.gd`
  - [ ] `project.godot`: standard input map (`move_forward`, `move_back`, `move_left`, `move_right`, `interact`, `sprint`)

---

## M1: Playtest Slice (Due Fri 2026-10-09)

### Electrical & Lighting (Rocky)
- [ ] `electrical/01-circuits-and-switches`: Room light toggle logic, circuit breaker state machine, 100W wattage drain/recharge meter, `light_state_changed` and `breaker_state_changed` signals.
- [ ] `electrical/02-bulb-flicker`: Bulb condition, paranormal flickering triggers, blown bulb mechanics.

### Portrait / Painting System (Hali)
- [ ] `portraits/01-painting-data`: Painting registry, tracking `is_covered`, `is_active`, `is_family_portrait`.
- [ ] `portraits/02-cover-interaction`: Interaction logic to drape or remove cloth dust-sheets; queries for valid ghost entry paintings.

### Ghost / Monster System (John)
- [ ] `ghost/01-light-dark-fsm`: Ghost state machine (`FREE_ROAM`, `PAINTING_BOUND`, `CHASE`, `STUNNED`).
- [ ] `ghost/02-seam-light-reaction`: Reads Electrical `is_room_lit`; retreats to uncovered, active painting when lights turn ON.
- [ ] `ghost/03-chase-and-kill`: Line of sight player detection in dark rooms, chase movement, instant-kill jumpscare on contact.

### Environmental Clues (Daniel)
- [ ] `environment/01-clue-listener`: Event receiver for ghost movements and electrical events.
- [ ] `environment/02-spatial-audio-disturbances`: Positional audio cues (creaks, footsteps, whispers) and physical prop disturbance triggers.

### Integration (John)
- [ ] `integration/01-playtest-house`: House greybox scene in `systems/core/main.tscn` connecting Entry Hall, Parlor, Study, Dining Room, and Basement.
- [ ] First-person player controller with interaction raycast.
- [ ] Wire all 4 systems into `main.tscn` for the playtest session.

---

## M2: Final Game Delivery (Due Fri 2026-10-16 · Code Freeze Thu 10-15)

- [ ] `portraits/03-portable-family-portrait`: Player pickup, carry, and drop mechanics for the family portrait.
- [ ] `ghost/04-exit-threshold-check`: Enforce Rule 2 (ghost blocked at doors unless inside the carried family portrait).
- [ ] `integration/02-entryway-climax`: Trigger sequence at front door (breaker trips, footsteps rush, lights restored, entity forced into held portrait).
- [ ] **All:** Web build export verification and playtesting.
