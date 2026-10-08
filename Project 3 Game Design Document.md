**The Last Portrait** 

Team Game Design Document 

October 7, 2026 

Haliyah, Rocky, Daniel, and John 

**1. What is the core loop in one sentence?** 

Author: Haliyah 

Enter your old family home on the eve of new tenants moving in, restore power at the basement breaker to turn on all lights, use room switches within a 100-watt energy budget to contain a darkness-dwelling monster in wall paintings while carrying four room-labeled moving boxes out to your car, and finally retrieve the family portrait by the front door without letting the monster enter it or kill you. 

**2. What are the systems? Name one system per member, its owner, the state it owns, and what it does.** 

Authors: Haliyah, Rocky, Daniel, and John 

Portrait/Painting System - Haliyah 

State it owns: Each portrait's location, room ID, wall position, covered or uncovered state (via cloth dust-sheets), active or inactive state, whether it is the final family portrait, whether it is being carried, and whether the monster is currently inhabiting and visible within it (`is_occupied`). 

What it does: Manages all wall paintings and the portable family portrait; allows paintings to be covered or uncovered using cloth dust-sheets; visually renders the monster trapped inside the canvas when it jumps in; provides queries for valid uncovered paintings. 

Electrical and Lighting System - Rocky 

State it owns: 100-watt energy budget meter, power consumption rate (1 watt/sec per lit room), power recharge rate (5 watts/sec when all lights are off), breaker box state (operational or tripped at 0 watts), room light switch states (ON/OFF), bulb condition, and flicker timers. 

What it does: Regulates power flow across house circuits; tracks real-time wattage drain and replenishment; triggers a master breaker blackout if the energy budget drops to 0 watts; provides room illumination that drives the monster out of open 3D space and forces it into a painting. 

Player System - Daniel 

State it owns: Player position, first-person camera orientation, movement state, carried object (one of the four moving boxes, a cloth dust-sheet, or the family portrait), player dark-adaptation ambient glow in darkness, interaction raycast focus, and alive or dead state. 

What it does: Provides first-person locomotion and camera look; allows the player to carry items at standard speed while maintaining hand freedom to toggle wall switches; casts a faint ambient glow in unlit rooms for immediate obstacle and switch navigation; handles interactions with light switches, moving boxes, dust sheets, and portraits; executes the player's instant-kill death sequence upon colliding with the monster. 

Ghost/Monster System - John 

State it owns: Monster position (coordinates and room), movement mode (free roaming in darkness, painting-bound and frozen in lit rooms, or hunting), current target, occupied portrait ID, and lethal contact trigger. 

What it does: Stalks the player through darkened rooms; instantly leaps into the nearest available uncovered painting when lights in its room are turned ON, becoming completely frozen and unable to move while the room remains lit; kills the player on direct physical contact in darkness; attempts to slip into the family portrait by the front door if not properly contained in another room. 

**3. What are the seams? For each seam, which system writes the value, which system reads it, and what decision does the reader make?** 

Author: Rocky  

Seam 1: Lighting and monster movement (Electrical System -> Monster System) 

The Electrical and Lighting System writes each room's light state (ON/OFF) and the power budget. The Ghost/Monster System reads those values. If a room is dark (OFF), the monster can move freely through it to hunt the player. If the room is lit (ON), the monster is forced to jump into an uncovered painting in that room and becomes completely immobilized as long as the lights stay on. 

Seam 2: Switch toggling and energy management (Player System -> Electrical System) 

The Player System writes interaction triggers to toggle wall light switches. The Electrical and Lighting System reads switch inputs to turn room lights ON or OFF, adjusting the wattage drain rate (1 W/s per lit room) and calculating total budget. In return, the Player System reads the room light state to emit a faint dark-adaptation ambient glow when the room is dark. 

Seam 3: Monster occupancy and visual display (Monster System -> Portrait System) 

The Ghost/Monster System writes its occupied portrait ID and an `is_occupied` boolean flag to the target painting when leaping into it. The Portrait/Painting System reads this flag to visibly render the trapped monster within the canvas (displaying shadowy brushstrokes and distorted features) and marks that portrait as occupied so no other entry can occur. 

Seam 4: Painting eligibility and monster refuge (Portrait System -> Monster System) 

The Portrait/Painting System writes whether each painting is covered (draped sheet), active, and its room location. The Ghost/Monster System reads those values when lights turn ON to decide which paintings it can enter. If all paintings in an illuminated room are covered, the monster is trapped or stunned. 

Seam 5: Carrying and covering interactions (Player System -> Portrait System) 

The Player System writes item interactions (draping or removing dust-sheets, picking up or dropping the family portrait). The Portrait/Painting System reads these interactions to update `is_covered` and `is_being_carried` states, attaching the portrait mesh to the player's carry socket and updating whether the painting is eligible for monster entry. 

Seam 6: Lethal monster contact (Monster System -> Player System) 

The Ghost/Monster System writes its physical collider position and roaming state. The Player System reads physical contact/collision with the monster in darkness. When a collision occurs, the Player System halts movement, triggers a fatal jump-scare death screen, and initiates a checkpoint reload. 

**4. What is the familiar thing, what makes it turn, and how does that change what the player does?** 

Author: Haliyah 

The familiar thing is the ordinary chore of moving out of your old family home—hauling the last few packed boxes out to your car trunk before turning the house over to incoming rental tenants tomorrow. Staged furniture remains for the renters, but your family's personal belongings and heirloom family portrait must be cleared out tonight. 

The familiar thing turns when the player learns that the house is haunted by a monster that roams through the darkness and slips into wall portraits when exposed to light. Furthermore, the house has an aging electrical grid with an energy budget of only 100 watts; turning on every light will rapidly drain the power, trip the master breaker, and plunge the home into pitch blackness. 

The player must approach moving out as a tactical survival puzzle. The player cannot simply run back and forth; they must budget their 100 watts, turning on lights to safely navigate or trap the monster in paintings, and turning them off to let the power recharge at 5 watts per second. When all four boxes are loaded into the car, the player must strategically lure and trap the monster inside a remote room's painting under bright light before taking down the family portrait by the front door, ensuring the entity isn't carried away with them to freedom. 

**5. What are the monster's rules? For each rule, what state does it read and how does the player figure it out? What is the predicted scariest moment, where does it happen, and which rules are in play?** 

Author: John 

Rule 1: The monster moves freely in dark rooms. In lit rooms, it must jump into a painting and becomes unable to move. 

State it reads: The room's light state, circuit power, the monster's current room, and its movement mode. 

How the player learns it: The player catches silhouettes or footsteps moving through dark rooms. When a light switch is flipped, the monster violently dives into the nearest painting with a sound of straining canvas, appearing visibly frozen inside the frame. 

Rule 2: The monster can only enter paintings that are active and uncovered. 

State it reads: Each painting's active state, covered state (dust-sheet draped), and location. 

How the player learns it: The player drapes a cloth dust-sheet over a painting. When the lights turn on, the monster cannot enter the covered frame, rebounding and fleeing to an uncovered painting elsewhere in the room. 

Rule 3: The monster cannot leave the house unless it is carried outside inside the family portrait. 

State it reads: Whether a painting is the final family portrait, whether it is being carried, its distance from the exterior door, and whether the monster is currently inside it. 

How the player learns it: The player finds notes and old photographs explaining the entity is bound to the house. During dark encounters near exterior doorways, the monster chases the player but halts dead at the threshold, unable to step outside into the night air. 

Rule 4: Direct contact with the monster in darkness is lethal. 

State it reads: Player position and physical collision boundary. 

How the player learns it: If the player gets caught in an unlit room by the roaming monster, the monster launches a fatal jump-scare attack, resulting in an immediate game over and checkpoint reload. 

Predicted scariest moment: The moment happens in the entry hall after the player loads the fourth moving box into their car and returns to retrieve the final item: the family portrait hanging right next to the front door. The player has trapped the monster inside a lit room deeper in the house, but their power budget is running low. As the player unhooks the family portrait from the wall, the 100-watt budget hits zero—the circuit breaker trips with a loud metallic crash, plunging the entire house into pitch blackness. Footsteps rush through the dark straight toward the entry hall. The player must navigate by their faint ambient glow to reset the basement breaker or re-trap the monster before it reaches them or enters the portrait in their hands. 

Rules in play: Rule 1 frees the monster from its painting trap during the blackout, Rule 2 governs which paintings can hold it once light is restored, Rule 3 prevents escaping with an occupied portrait, and Rule 4 enforces lethal stakes during the dark pursuit. 

**6. What is the team's art direction?** 

Author: Daniel  

• Format and camera: Single-player, first-person 3D horror game (`Camera3D`) with standard mouse-look and a central interaction crosshair. 

• Setting: An aging suburban family home being cleared out before new rental tenants move in tomorrow. Furniture is staged or sparsely left behind, and four room-labeled moving boxes sit in designated rooms. The player's car sits in the driveway outside with its trunk open. 

• Style: Stylized realism with believable proportions and simplified details suitable for Godot 4 Compatibility renderer. 

• Mood: Intimate, nostalgic, dusty, lonely, watchful, and uncanny. 

• Color palette: Cream, brown, aged wood, faded wallpaper, cold shadow tones, and warm incandescent tungsten light from lamps and ceiling fixtures. 

• Lighting: Warm bulbs create illuminated safety zones where monsters are trapped in paintings. Unlit rooms use dark cool shadows where the player has a subtle, realistic dark-adaptation ambient glow to see nearby walls and switches. 

• Value and contrast: High contrast between bright lit zones and oppressive dark rooms. 

• Shape language: Grounded domestic shapes (cardboard moving boxes, rectangular doorframes, furniture) contrasted against the stretched, shadowy, fluid silhouette of the monster. 

• Materials and textures: Cardboard boxes with room labels, worn wood, peeling wallpaper, cloth dust-sheets, old canvas paintings, brass switches, and metallic breaker box. 

• Environment: A 5-room layout consisting of an Entry Hall (with exterior door and car outside), Parlor, Study, Dining Room, and Basement (housing the breaker box). 

• Monster design: A shadowy, shifting entity in 3D darkness that flattens into distorted painted oil strokes with visible eyes and silhouette when trapped inside a canvas frame. 

• Portrait design: Vintage oil paintings in ornate frames. When occupied, the canvas visibly warps and displays the trapped monster. 

• Props: Four room-labeled moving boxes, cloth dust-sheets, light switches, breaker box, car trunk, and the heirloom family portrait hanging by the front door. 

• UI and typography: Diegetic and minimal: an on-screen 100W power meter, clean central crosshair, simple interaction prompts ("E - Pick Up", "E - Pack Box", "E - Toggle Light", "E - Drape Sheet"), and a dynamic objective checklist in the top right of the screen:
  1. Initial phase: "Flip the breaker in the basement" (the monster is inactive and cannot attack during this opening phase; flipping the breaker powers on all house lights and starts the 100W grid).
  2. Packing phase: Switches to a checklist of the four boxes and their rooms (e.g. "[ ] Living Room Box", "[ ] Dining Room Box", "[ ] Study Box", "[ ] Basement Box") which cross off as they are stowed into the car trunk.
  3. Final climax phase: Once all four boxes are packed, switches to "Take the family portrait" (which hangs prominently by the front door). 

• Audio: Positional 3D audio for distant wooden creaks, electrical hums, heavy rushing footsteps in dark rooms, strained canvas flutter when a monster jumps into a painting, and breaker trip clanks. 

**7. What is in scope, and what are the three cuts?** 

Author: Rocky 

In scope: 

• One single-player first-person level inside a 5-room family home plus exterior driveway with player's car. 

• A three-phase objective checklist HUD (basement breaker reset -> pack 4 room-labeled boxes -> retrieve family portrait). 

• Safe onboarding intro phase where the monster cannot attack until the basement breaker is flipped and lights turn on. 

• Four room-labeled moving boxes located in separate rooms to find and carry to the car trunk one by one in player-selected order. 

• One heirloom family portrait hanging by the front door serving as the final escape objective. 

• A 100-watt electrical power grid with real-time drain (1 W/s per lit room), recharge (5 W/s when all lights are off), switch toggles, and a master breaker panel in the basement. 

• A portrait system supporting cloth dust-sheet covering and visual monster occupancy rendering. 

• A monster AI that roams freely in dark rooms, dives into paintings when lit, remains frozen while illuminated, and kills on contact. 

• First-person player locomotion, item carrying at standard speed with switch interaction capability, and subtle dark-adaptation ambient glow. 

• Clear win (all 4 boxes and unoccupied family portrait loaded into car) and loss (killed by monster or leaving with monster in portrait) states. 

Cut 1: Full moving simulation. There will be no physics-based packing, furniture disassembly, box taping, or inventory stacking. The player carries one item at a time in hand directly out to the car. 

Cut 2: Combat and player health systems. There will be no weapons, health items, flashlights, or ways to fight the monster. Survival depends strictly on managing room lights, power wattage, and painting containment. 

Cut 3: Additional houses or monster types. There will be no multiple house layouts, procedural rooms, multiple monsters, or branching narrative paths. The experience is a tight, focused, single-level vertical slice. 
