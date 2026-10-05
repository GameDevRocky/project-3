# Decisions Log

Why architectural and design decisions are the way they are.
**Append new entries at the bottom of the right section.** Never rewrite old entries; if a decision changes, add a new entry that states "Supersedes D-xxx".

- **D-** = Decided
- **P-** = Proposed (awaiting team sign-off)
- **Q-** = Open question

---

## Decided

**D-001 · 2026-10-05 · Team · Four Systems Architecture & State Ownership**
The codebase is divided into four distinct systems and owners per class design requirements:
1. Portrait / Painting System: Hali (`systems/portraits/`)
2. Electrical & Lighting: Rocky (`systems/electrical/`)
3. Environmental Clues: Daniel (`systems/environment/`)
4. Ghost / Monster System: John (`systems/ghost/`)
*Why:* Strict ownership avoids merge conflicts and allows parallel development. *Affects:* `TEAM.md`, `CONTRACTS.md`.

**D-002 · 2026-10-05 · Team · Engine and Renderer Selection**
Godot 4.7.2 stable standard build (GDScript), Compatibility renderer (`gl_compatibility`), Web export with threading disabled.
*Why:* Ensures zero shader compilation issues across various platforms and smooth browser play. *Affects:* `TECH_STACK.md`, `project.godot`.

**D-003 · 2026-10-05 · Team · Spec-Driven Development Workflow**
Adopting the spec-driven workflow: 0 Sync → 1 Branch → 2 Brainstorm → 3 Spec → 4 Plan → 5 TODO → 6 Build (Test first) → 7 Verify → 8 PR.
*Why:* Proven to keep AI agent sessions and human collaboration structured, prevent scope creep, and ensure tests before implementation. *Affects:* `WORKFLOW.md`, `AGENTS.md`.

**D-004 · 2026-10-05 · Team · The Three Monster Rules & Seams**
1. Rule 1: Moves freely in the dark; jumps into pictures/paintings in the light. (Reads Electrical room light state).
2. Rule 2: Cannot leave the house unless taken out in the family portrait. (Reads Portrait state / threshold location).
3. Rule 3: Can only move between paintings that are uncovered and active. (Reads Portrait covered/active states).
*Why:* Creates deterministic, player-learnable stealth/puzzle mechanics rather than random jump scares. *Affects:* `GAME_SPEC.md`, `CONTRACTS.md`.

**D-005 · 2026-10-05 · Team · Scariest Moment Climax**
The climax takes place in the entry hallway while holding the family portrait; lights cut out, footsteps charge, lights return, forcing the entity into the portrait in the player's hands.
*Why:* Pulls all three mechanics together for the emotional and mechanical peak of the game. *Affects:* `GAME_SPEC.md`, Integration.

**D-006 · 2026-10-05 · Team · Idea Selection via System Integration**
Rather than discarding competing proposals, the team merged and integrated the core ideas into this unified 4-system horror puzzle design through team collaboration so all members are on the same page.
*Why:* Leverages all members' creative strengths across portrait mechanics, electrical management, environmental storytelling, and ghost AI. *Affects:* `GAME_SPEC.md`.

**D-007 · 2026-10-05 · Team · First-Person 3D Perspective & Raycast Interaction**
The game uses a first-person 3D camera (`Camera3D`) with standard mouse-look and a central raycast crosshair (interaction range 2.5 m).
*Why:* Maximizes tension, up-close inspection of painting details and clues, and intimacy during darkness and light manipulation. *Affects:* `GAME_SPEC.md`, `systems/core/`, player controls.

**D-008 · 2026-10-05 · Team · Five-Room House Layout Scope**
House layout is scoped to 5 connected zones: Entry Hall, Parlor, Study, Dining Room, and Basement (Breaker Room).
*Why:* Provides diverse circuit routing and painting options while maintaining a manageable level scope for prototype and alpha delivery. *Affects:* `GAME_SPEC.md`, `CONTRACTS.md`, all systems.

**D-009 · 2026-10-05 · Team · Power Grid Wattage Resource Mechanic**
The electrical system operates on a 100 Watt resource meter. Each room with lights ON consumes 1 W/s. When all lights are turned OFF, power restores at 5 W/s. Reaching 0 W trips the master breaker, plunging the house into darkness and forcing a physical trek to the basement breaker panel.
*Why:* Prevents players from simply turning on every light to eliminate the monster threat; creates risk/reward trade-offs between visibility and power conservation. *Affects:* `GAME_SPEC.md`, `CONTRACTS.md`, Rocky (Electrical), John (Ghost).

**D-010 · 2026-10-05 · Team · Cloth Dust-Sheet Covering Mechanic**
The player blocks the ghost from entering wall paintings by collecting and draping cloth dust-sheets over painting frames (and removing them when needed).
*Why:* Provides a tangible physical interaction item, clear visual feedback, and reusable strategic resources for sealing off rooms or corridors. *Affects:* `GAME_SPEC.md`, `CONTRACTS.md`, Hali (Portraits), John (Ghost).

**D-011 · 2026-10-05 · Team · Real-Time Sensory Feedback Only (No Menus / Journals)**
Environmental clues and monster evidence rely strictly on real-time spatial sensory feedback (3D positional audio, falling physics props, flickering shadows, canvas warping). No UI journals or inventory menus.
*Why:* Maintains maximum first-person tension, immersion, and unbroken game flow. *Affects:* `GAME_SPEC.md`, `CONTRACTS.md`, Daniel (Environment).

**D-012 · 2026-10-05 · Team · Instant Kill Failure Mechanic**
Physical contact with the ghost while roaming/chasing in darkness results in an immediate fatal jump scare, ending the run and reloading the latest checkpoint.
*Why:* Heightens stakes and enforces strict respect for room lighting, electrical power management, and painting positions. *Affects:* `GAME_SPEC.md`, `CONTRACTS.md`, John (Ghost).

**D-013 · 2026-10-05 · Team · Docs-Only Foundation Phasing**
Initial repository scaffolding remains strictly docs-driven until team contract sign-off (P-001). Shared GDScript types (`systems/shared/`) and `project.godot` will be introduced in feature branch `integration/00-foundation`.
*Why:* Ensures team members fully review and sign off on typed interfaces and rules before generating code artifacts. *Affects:* `PROGRESS.md`, `TODO.md`.

**D-014 · 2026-10-05 · Team · Official Milestones and Delivery Dates**
- GDD Submission: Wed 2026-10-07
- Playtest Working Slice: Fri 2026-10-09
- Final Game Delivery: Fri 2026-10-16 (Code freeze Thu 2026-10-15 night)
*Why:* Anchors sprint targets for all 4 system owners. *Affects:* `AGENTS.md`, `README.md`, `GAME_SPEC.md`, `PROGRESS.md`, `TODO.md`, `TEAM.md`.

---

## Proposed (Waiting for sign-off)

**P-001 · 2026-10-05 · John · Sign-off on CONTRACTS.md v0.1**
Approval of shared enums, `PaintingData`, `GhostState`, `ClueEvent`, and cross-system method signatures.
*Status:* Pending sign-off from Hali, Rocky, Daniel, and John.

---

## Open Questions

**Q-001 · 2026-10-05 · Team · Final Game Title**
Official game title pending final team brainstorming (Working Title: *Project 3*).
