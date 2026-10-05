# Game Design Specification: Project 3 (Working Title)

## 1. Overview

A 3D psychological horror and puzzle game built in Godot 4.7.2. The player explores an eerie residence haunted by an entity that lurks within darkness and inhabits oil paintings. To survive and uncover the house's dark history, the player must manipulate room lighting and portrait covers, decipher environmental clues, and navigate an inescapable truth: the entity can only leave the house if carried out inside the central family portrait.

### Core Concept & Selection Rationale
The team evaluated multiple concepts and decided not to discard the competing pitches, but rather to synthesize their strongest core mechanics into a unified vision. By collaborating and integrating the different proposals, all four team members aligned around a game where portraits, electrical networks, environmental clues, and monster AI operate in direct harmony.

### Milestones & Class Schedule
- **M0 GDD Submission (Wed 2026-10-07):** Finalize team Game Design Document, shared contracts sign-off, system ownership, and seam definitions.
- **M1 Playtest Slice (Fri 2026-10-09):** Working playable greybox house slice. All 4 systems functional and integrated: room lights toggleable with 100W wattage drain, paintings drapeable, ghost reacting to light and roaming in dark, and environmental sensory disturbances active.
- **M2 Final Game Delivery (Fri 2026-10-16):** Full narrative puzzle arc, complete 5-room layout, front door family portrait climax sequence, web export build, bug fixes. Code freeze **Thu 2026-10-15 night**.

---

## 2. Story and Premise

The player arrives at an abandoned estate tied to a family disappearance. The house holds a collection of distinct oil paintings, prominent among them an imposing family portrait. As electrical fixtures fail and anomalous disturbances escalate, the player pieces together clues: the entity bound to the estate was brought into the house long ago trapped inside that very portrait.

---

## 3. House Layout and Room Scope

The estate features a standard single-floor layout plus a basement utility area (5 primary zones), allowing rich circuit management and painting distribution without excessive level design overhead:

1. **Entry Hall:** The threshold of the house containing the heavy exterior exit doors, coat racks, and initial wall portrait hooks. Acts as the start point and the stage for the final escape climax.
2. **Parlor / Living Room:** Central gathering area featuring an extinguished fireplace, sofa, several decorative wall portraits, and lighting switch.
3. **Study / Library:** Intimate room filled with bookshelves and a desk holding key documentary evidence (such as the archival photograph of the family portrait arrival).
4. **Dining Room:** Long table with chandelier lighting and tableware prone to physical environmental disturbances (rattling cutlery, falling chairs).
5. **Basement (Breaker Room):** Pitch-dark utility cellar containing the master circuit breaker box. Navigating down here when the breaker trips requires moving through darkness.

---

## 4. Systems and Owners

Four distinct systems, each owned by one team member. Each system encapsulates specific internal state and exposes strictly typed interfaces across seams.

| System | Owner | Owned State | Key Responsibilities |
|---|---|---|---|
| **Portrait / Painting System** | Hali | Portrait locations, covered/uncovered status (draped cloth dust-sheets), turned/moved state, active/inactive state, family portrait tracking | Manages physical paintings on walls and portable portraits; provides status of painting frames and whether they can house or block the entity. Handles player draping and removing cloth dust-sheets on frames. |
| **Electrical & Lighting** | Rocky | Circuit networks, room light switch states (ON/OFF), breaker box state, bulb condition/flicker, power grid meter (100W capacity, 1W/s drain per lit room, 5W/s recharge when all dark) | Manages power distribution, wattage drain/recharge economy, room illumination levels, and breaker trip logic when power reaches 0W. |
| **Environmental Clues** | Daniel | Physical disturbances, audio cues, clue intensity, clue locations, triggered evidence | Orchestrates real-time sensory feedback: spatial 3D audio (footsteps in darkness, creaks, canvas straining), visual distortions (canvas warping), and physics disturbances (rattling cutlery, falling props). Completely diegetic with no journal/menu UI. |
| **Ghost / Monster System** | John | Ghost location (room / coordinates), behavioral state (IDLE, STALK, CHASE), movement mode, current target | Controls ghost AI, movement decisions based on room lighting, jumping into available paintings, chasing the player in darkness, and triggering fatal instant-kill jump scares on player contact. |

---

## 5. Seams Between Systems

A seam is a boundary where one system writes a value, another system reads it, and makes a critical gameplay decision based on that value.

### Seam 1: Electrical & Lighting $\rightarrow$ Ghost / Monster
- **Writer:** Electrical System (`systems/electrical/`) writes room light states (`LightState.ON`, `LightState.OFF`, `LightState.FLICKERING`).
- **Reader:** Ghost System (`systems/ghost/`) reads the light state of the current room and adjacent rooms.
- **Decision:** The monster can only move freely while room lights are OFF. When lights are turned ON in its current room, the ghost cannot traverse physical space and is forced to jump into a valid picture/painting. If lights in a target room are ON, the ghost's pathfinding treats that room as an impassable barrier.

### Seam 2: Ghost / Monster $\rightarrow$ Environmental Clues
- **Writer:** Ghost System (`systems/ghost/`) writes its location, movement mode, and transitions (e.g. moving through dark halls or jumping between paintings).
- **Reader:** Environmental Clues System (`systems/environment/`) reads the ghost's position and movement events.
- **Decision:** The environment system evaluates the ghost's proximity and action to trigger corresponding audio-visual disturbances (creaking floorboards, sudden temperature drops, rattling picture frames, or falling objects) in that specific room.

### Seam 3: Portrait / Painting $\rightarrow$ Ghost / Monster
- **Writer:** Portrait System (`systems/portraits/`) writes whether paintings are covered, turned, active, or inactive, as well as the position of the family portrait.
- **Reader:** Ghost System (`systems/ghost/`) reads painting state when seeking refuge from light or jumping between rooms.
- **Decision:** The ghost can only enter or move between paintings that are **uncovered** and **active**. If all paintings in an illuminated room are covered or inactive, the ghost is trapped or stunned. When near an exit, the ghost reads whether it is currently inside the family portrait before attempting to cross the threshold.

---

## 6. The Monster: Rules, Behaviors, and Discovery

The entity behaves strictly according to logical rules rather than arbitrary jump scares.

### Monster Rules
1. **Rule 1 (Darkness & Paintings):** Moves freely in the dark; forced into pictures/paintings when exposed to light.
2. **Rule 2 (The Threshold & The Family Portrait):** The monster cannot leave the house on its own. It can only cross the exterior threshold if carried outside while residing inside the family portrait.
3. **Rule 3 (Painting Eligibility):** The ghost can only enter and move between paintings that are currently **uncovered** and **active**.

### Player Discovery (Environmental Learning)
- **Discovering Rule 1:** The player observes through sight and sound that the ghost roams unimpeded in pitch-black rooms, but snapping a light switch on instantly halts physical pursuit and causes an immediate spectral shift into an adjacent wall painting.
- **Discovering Rule 2:** The player uncovers an archival photograph depicting the family portrait being moved into the manor decades earlier, revealing a faint shadowy figure trapped within the painted canvas. Later, during a chase toward an open exterior doorway, the player observes the ghost halt dead in its tracks at the doorway threshold, unable to step outside.
- **Discovering Rule 3:** During an active chase through a lit corridor, the player quickly covers a nearby painting with a sheet or cloth. The approaching ghost attempts to dive into the frame, rebounds violently with an auditory cue, and is forced to divert toward a remaining uncovered painting. Inactive or damaged paintings remain dormant as the ghost passes by, whereas active paintings exhibit visible disturbances (warping canvas, shivering frame).

### Player Failure: Instant Kill
If the ghost reaches the player while roaming or chasing in darkness, it triggers an immediate fatal jump scare, ending the run and displaying a death screen before reloading the latest room checkpoint. Exposure to physical darkness while the monster is active is lethal.

---

## 7. The Scariest Moment (The Climax)

**Location:** The main Entry Hallway facing the front exit doors.
**Context:** Believing they have solved the mystery and achieved salvation, the player carries the physical family portrait toward the front exit.
**The Escalation:**
- Just yards from the front door, the entire house's circuit breaker trips; the entry hallway plunges into pitch darkness.
- Rushing footsteps and violent spatial audio erupt behind the player, accelerating directly toward them (Rule 1).
- In a panic, the player resets a local emergency switch or restores light, instantly illuminating the entry hall.
- With the hall brightly lit, the ghost cannot exist in the open and seeks the nearest uncovered, active painting (Rule 3).
- Every wall painting in the entry hall has been covered or removed—leaving only **one single uncovered, active portrait nearby: the family portrait held directly in the player's trembling hands**.
- The entity slams violently into the canvas inches from the player's face. The player now realizes: stepping out that door with the portrait in hand will release the entity into the outside world (Rule 2).

---

## 8. Controls and Camera

- **Perspective:** First-person 3D (`Camera3D`).
- **Movement:** Standard WASD / directional controls, mouse look.
- **Interactions (`E` / Left Click):**
  - Toggle light switches and breakers.
  - Interact with portrait covers (sheet on/off, turn painting, examine).
  - Pick up / carry portable portraits (including the family portrait).
  - Inspect environmental clues and documents.

---

## 9. Audio and Atmosphere

- **Dynamic Audio:** Positional 3D audio for ghost footsteps, distant thumps, electrical buzzing, and canvas stretching.
- **Visual Palette:** Muted colors, stark contrast between harsh tungsten / fluorescent illumination and oppressive shadows.
- **Rendering:** Godot 4 Compatibility renderer; optimized dynamic lighting for web target compatibility.

---

## 10. Tuning Table

| Parameter | Baseline Value | Units | Notes |
|---|---|---|---|
| Player Move Speed | 3.5 | m/s | Standard exploration walking pace |
| Player Sprint Speed | 5.5 | m/s | Brief stamina-limited sprint |
| Ghost Dark Roam Speed | 4.5 | m/s | Fast enough to pressure player in dark rooms |
| Ghost Painting Transition Time | 0.8 | seconds | Time to enter/emerge from a painting |
| Breaker Reset Delay | 2.0 | seconds | Interaction time required at breaker panel |
| Light Flicker Frequency | 8 - 14 | Hz | Paranormal disturbance flicker rate |
| Max Power Grid Capacity | 100.0 | Watts | Total electrical reserve before blackout |
| Light Drain Rate Per Room | 1.0 | W/s | Drains 1 Watt per second per lit room |
| Grid Recharge Rate | 5.0 | W/s | Restores power when all house lights are OFF |
| Breaker Trip Threshold | 0.0 | Watts | All lights cut out and breaker trips at 0W |
