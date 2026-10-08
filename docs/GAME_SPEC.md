# Game Design Specification: The Last Portrait

## 1. Overview

A 3D psychological horror and puzzle game built in Godot 4.7.2 (Compatibility renderer). The player visits their old family home on the eve of new rental tenants moving in to pack and carry the last four family belongings out to their car. Unbeknownst to them, the house is haunted by an entity that moves freely through darkened rooms and slips into uncovered oil paintings when exposed to light. To survive, the player must manage the house's 100-watt electrical grid, contain the monster inside paintings, retrieve the four room-labeled moving boxes, and ultimately take down the heirloom family portrait by the front door without letting the monster enter it or kill them.

### Core Concept & Selection Rationale
The team evaluated multiple concepts and decided not to discard competing pitches, but rather to synthesize their strongest core mechanics into a unified vision. By collaborating and integrating the different proposals, all four team members aligned around a game where portraits, electrical networks, player interaction, and monster AI operate in direct harmony.

### Milestones & Class Schedule
- **M0 GDD Submission (Wed 2026-10-07):** Finalize team Game Design Document, shared contracts sign-off, system ownership, and seam definitions.
- **M1 Playtest Slice (Fri 2026-10-09):** Working playable greybox house slice. All 4 systems functional and integrated: breaker startup, 100W power grid, box transport to car trunk, painting containment, monster AI, and player death loop.
- **M2 Final Game Delivery (Fri 2026-10-16):** Full 5-room layout, complete audio-visual presentation, family portrait escape climax, web export build, and bug fixes. Code freeze **Thu 2026-10-15 night**.

---

## 2. Story and Premise

The player's family has relocated, and the childhood home has been leased to incoming tenants who move in tomorrow. The main furniture remains staged, but four room-labeled boxes of sentimental belongings and the central family portrait by the front door still need to be cleared out. Arriving alone after dusk, the player discovers the power is off at the breaker and a malevolent entity now haunts the dark corridors.

---

## 3. House Layout and Room Scope

The estate features a standard single-floor layout plus a basement utility area (5 primary zones) and the exterior driveway:

1. **Exterior Driveway:** Player's car parked with its trunk open, serving as the deposit point for the four moving boxes and the final exit threshold.
2. **Entry Hall:** The house foyer containing the exterior door and coat racks. The heirloom family portrait hangs prominently on the wall right beside the front door.
3. **Parlor / Living Room:** Central living area with staged sofa, coffee table, wall switches, decorative wall portraits, and the `Living Room Box`.
4. **Study / Library:** Room filled with bookshelves, a desk, wall portraits, and the `Study Box`.
5. **Dining Room:** Room with a long dining table, chandelier lighting, wall paintings, and the `Dining Room Box`.
6. **Basement (Breaker Room):** Utility cellar containing the master 100-watt breaker panel and the `Basement Box`.

---

## 4. Systems and Owners

Four distinct systems, each owned by one team member. Each system encapsulates specific internal state and exposes strictly typed interfaces across seams.

| System | Owner | Owned State | Key Responsibilities |
|---|---|---|---|
| **Portrait / Painting System** | Hali | Portrait locations, room ID, covered/uncovered status (draped cloth dust-sheets), active/inactive state, family portrait tracking, and monster visual occupancy (`is_occupied`) | Manages all wall paintings and the portable family portrait; allows paintings to be covered/uncovered using cloth dust-sheets; visually renders the monster trapped inside the canvas when it jumps in; provides queries for valid uncovered paintings. |
| **Electrical & Lighting** | Rocky | Circuit networks, room light switch states (ON/OFF), breaker box state, power grid meter (100W capacity, 1W/s drain per lit room, 5W/s recharge when all dark), bulb condition/flicker | Manages power distribution, wattage drain/recharge economy, room illumination levels, and breaker trip logic when power reaches 0W. Provides full 100W restore on basement breaker reset. |
| **Player System** | Daniel | Player position/rotation, movement state, carried item (moving box, dust-sheet, or family portrait), dark-adaptation ambient glow in darkness, interaction raycast focus, alive/dead state | Provides first-person locomotion and camera look; allows player to carry items at standard speed while maintaining hand freedom to toggle wall switches; casts a faint ambient glow in unlit rooms for immediate obstacle and switch navigation; handles interactions with switches, boxes, sheets, and portraits; handles fatal death sequence. |
| **Ghost / Monster System** | John | Monster position (room and coordinates), behavioral state (FREE_ROAM, PAINTING_BOUND, CHASE), current target, occupied portrait ID, lethal contact trigger | Controls monster AI: stalks the player through darkened rooms; instantly leaps into the nearest available uncovered painting when lights in its room are turned ON, becoming completely frozen and unable to move while the room remains lit; kills player on direct physical contact in darkness; attempts to enter family portrait during escape. |

---

## 5. Seams Between Systems

A seam is a boundary where one system writes a value, another system reads it, and makes a critical gameplay decision based on that value.

### Seam 1: Electrical System $\rightarrow$ Monster System (Lighting & Monster Movement)
- **Writer:** Electrical System (`systems/electrical/`) writes room light states (`ON`, `OFF`) and power budget.
- **Reader:** Monster System (`systems/ghost/`) reads light states of its room and adjacent rooms.
- **Decision:** If a room is dark (OFF), the monster roams freely and hunts the player in physical 3D space. If the room is lit (ON), the monster is forced to jump into an uncovered painting in that room and becomes completely immobilized as long as the lights stay on.

### Seam 2: Player System $\rightarrow$ Electrical System (Switch Toggling & Energy Management)
- **Writer:** Player System (`systems/player/`) writes interaction triggers to toggle wall light switches.
- **Reader:** Electrical System (`systems/electrical/`) reads switch inputs to turn room lights ON or OFF, adjusting the wattage drain rate (1 W/s per lit room) and calculating total budget.
- **Decision:** Electrical updates room illumination and cuts power/trips breaker if consumption exceeds 100 watts; Player system also emits a faint dark-adaptation ambient glow when the Electrical system reports a room is dark.

### Seam 3: Monster System $\rightarrow$ Portrait System (Monster Habitation & Visual Display)
- **Writer:** Monster System (`systems/ghost/`) writes its occupied portrait ID and an `is_occupied` boolean flag to the target painting when leaping into it.
- **Reader:** Portrait System (`systems/portraits/`) reads `is_occupied`.
- **Decision:** The Portrait System visually renders the trapped monster within the canvas (displaying shadowy brushstrokes and distorted features) and marks that portrait as occupied so no other entry can occur.

### Seam 4: Portrait System $\rightarrow$ Monster System (Valid Painting Entry)
- **Writer:** Portrait System (`systems/portraits/`) writes whether each painting is covered (draped sheet), active, and its room location.
- **Reader:** Monster System (`systems/ghost/`) reads portrait state when light is turned ON.
- **Decision:** Monster pathfinds and dives into only valid, uncovered, active paintings. If all paintings in an illuminated room are covered, the monster is trapped or stunned.

### Seam 5: Player System $\rightarrow$ Portrait System (Carrying & Covering)
- **Writer:** Player System (`systems/player/`) writes item interactions (draping/removing dust-sheets, picking up or dropping the family portrait).
- **Reader:** Portrait System (`systems/portraits/`) reads player interaction to update `is_covered` and `is_being_carried` states.
- **Decision:** Portrait System attaches the portrait mesh to the player's carry socket and updates whether the painting is eligible for monster entry.

### Seam 6: Monster System $\rightarrow$ Player System (Lethal Contact / Death)
- **Writer:** Monster System (`systems/ghost/`) writes its physical collider position and roaming/chasing state.
- **Reader:** Player System (`systems/player/`) reads physical contact/collision with the monster in darkness.
- **Decision:** When a collision occurs, the Player System immediately halts movement, triggers a fatal jump-scare death screen, and initiates a checkpoint reload.

---

## 6. The Monster: Rules, Behaviors, and Discovery

The entity behaves strictly according to logical rules rather than arbitrary jump scares.

### Monster Rules
1. **Rule 1 (Darkness & Paintings):** Moves freely in dark rooms. In lit rooms, it must jump into a painting and becomes unable to move.
2. **Rule 2 (Painting Eligibility):** Can only enter paintings that are active and uncovered.
3. **Rule 3 (The Threshold & The Family Portrait):** The monster cannot leave the house on its own. It can only cross the exterior threshold if carried outside while residing inside the family portrait.
4. **Rule 4 (Lethal Contact):** Direct contact with the monster in darkness is lethal.

### Player Discovery (Environmental Learning)
- **Discovering Rule 1:** The player catches silhouettes or footsteps moving through dark rooms. When a light switch is flipped, the monster violently dives into the nearest painting with a sound of straining canvas, appearing visibly frozen inside the frame.
- **Discovering Rule 2:** The player drapes a cloth dust-sheet over a painting. When the lights turn on, the monster cannot enter the covered frame, rebounding and fleeing to an uncovered painting elsewhere in the room.
- **Discovering Rule 3:** The player observes the monster chase them toward open exterior doorways during darkness but halt dead at the threshold, unable to step outside into the night air.
- **Discovering Rule 4:** If caught in an unlit room by the roaming monster, the player suffers an immediate fatal jump scare attack, restarting at the checkpoint.

---

## 7. The Objective Progression & Climax

### Dynamic Objective Checklist (Top-Right HUD)
1. **Phase 0 (Startup Onboarding):** `Flip the breaker in the basement`. The monster is dormant and cannot attack during this opening phase. Flipping the basement breaker turns on all house lights and activates the 100-watt power grid.
2. **Phase 1 (Packing Boxes):** Checklist switches to the four room-labeled boxes:
   - `[ ] Living Room Box`
   - `[ ] Dining Room Box`
   - `[ ] Study Box`
   - `[ ] Basement Box`
   The player may retrieve and carry them out to the car trunk in any order. At the car trunk, pressing `E - Pack Box` deposits the box with a thud and ticks the checklist item.
3. **Phase 2 (The Family Portrait Climax):** Once all 4 boxes are packed, the objective switches to `Take the family portrait` (hanging by the front door).

### The Scariest Moment (The Climax)
- The player must prepare by trapping the monster inside a remote room's painting under bright light before unhooking the family portrait by the front door.
- As the player unhooks the portrait, the house's 100W budget hits zero or fluctuates; the circuit breaker trips with a loud metallic crash, plunging the entire house into pitch darkness.
- Rushing footsteps rush through the dark straight toward the entry hall.
- The player must navigate by their faint dark-adaptation glow to restore power at the basement breaker panel or re-trap the monster before it reaches them or enters the portrait in their hands.

---

## 8. Controls and Camera

- **Perspective:** First-person 3D (`Camera3D`) with standard mouse-look.
- **Movement:** Standard WASD walking pace (3.5 m/s), sprint (5.5 m/s). Carrying an item does not reduce walk speed and leaves hands free to toggle switches.
- **Dark Navigation:** Faint dark-adaptation ambient glow automatically enables in unlit rooms to allow near-field visibility of doorframes and switches.
- **Interactions (`E` / Left Click):**
  - Toggle light switches and breaker panel.
  - Pick up and carry moving boxes, dust-sheets, and the family portrait.
  - Pack boxes into the car trunk.
  - Drape and remove dust-sheets on paintings.

---

## 9. Tuning Table

| Parameter | Baseline Value | Units | Notes |
|---|---|---|---|
| Player Move Speed | 3.5 | m/s | Standard exploration walking pace |
| Player Sprint Speed | 5.5 | m/s | Brief stamina-limited sprint |
| Ghost Dark Roam Speed | 4.5 | m/s | Fast enough to pressure player in dark rooms |
| Ghost Painting Transition Time | 0.8 | seconds | Time to enter/emerge from a painting |
| Breaker Reset Delay | 2.0 | seconds | Interaction time required at breaker panel |
| Max Power Grid Capacity | 100.0 | Watts | Total electrical reserve before blackout |
| Light Drain Rate Per Room | 1.0 | W/s | Drains 1 Watt per second per lit room |
| Grid Recharge Rate | 5.0 | W/s | Restores power when all house lights are OFF |
| Breaker Reset Value | 100.0 | Watts | Flipping tripped breaker restores full 100W |
| Breaker Trip Threshold | 0.0 | Watts | All lights cut out and breaker trips at 0W |
| Interaction Range | 2.5 | meters | First-person raycast interact reach |
