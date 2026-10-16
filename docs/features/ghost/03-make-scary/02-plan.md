# 03-make-scary: Plan

| | |
|---|---|
| System / Owner | Ghost / Monster System / John |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. **Iteration 1: Visuals & Eye Tracking Look-At:** Construct the emissive red eyes, head pivot, and soft red point light in `ghost_monster.tscn` and implement player eye tracking and chase flaring in `ghost_monster.gd`.
2. **Iteration 2: Dark Room Wandering AI:** Implement semi-random waypoint patrolling within and between unlit rooms in `ghost_monster.gd`, gating chase engagement on entering the same dark room or line-of-sight.
3. **Iteration 3: Positional Procedural Audio:** Synthesize periodic low guttural roaming breathing and high-intensity chase screech cues in `procedural_audio.gd`.
4. **Iteration 4: Full Suite Verification:** Ensure all GUT tests pass headless with zero errors and verify in `main.tscn`.

## 2. Iterations and steps

### Iteration 1: Visuals & Eye Tracking Look-At

- **Step 1.1:** Add `HeadPivot`, `EyeLeft`, `EyeRight` (emissive red spheres), and `EyeAura` (`OmniLight3D`) to `ghost_monster.tscn`.
- **Step 1.2:** Write GUT tests in `tests/ghost/test_ghost_behavior.gd` verifying eye existence, dormancy visibility sync, player look-at tracking, and chase emission flare. Implement in `systems/ghost/ghost_monster.gd`.

### Iteration 2: Dark Room Wandering AI

- **Step 2.1:** Write GUT tests in `tests/ghost/test_ghost_behavior.gd` asserting the ghost wanders waypoints in dark rooms when unengaged (`FREE_ROAM`), and triggers `CHASE` with locked eyes and higher speed upon encountering the player in darkness. Implement in `systems/ghost/ghost_monster.gd`.

### Iteration 3: Positional Procedural Audio

- **Step 3.1:** Add `ghost_roam_sound_requested` signal in `ghost_monster.gd` and connect in `procedural_audio.gd`. Synthesize guttural breathing and intense chase screech audio streams.

## 3. Prompts

### Prompt 1 (Step 1.1 & 1.2): Emissive Eyes and Player Tracking
Files: `systems/ghost/ghost_monster.tscn`, `systems/ghost/ghost_monster.gd`, `tests/ghost/test_ghost_behavior.gd`.
Test: `test_ghost_eyes_track_player_and_flare_on_chase`.
Implement: Mount eyes on head pivot, track player position, flare emission energy on chase, sync visibility with shadow mesh.

### Prompt 2 (Step 2.1): Dark Room Wandering AI
Files: `systems/ghost/ghost_monster.gd`, `tests/ghost/test_ghost_behavior.gd`.
Test: `test_ghost_wanders_in_darkness_and_chases_when_player_enters_room`.
Implement: Multi-room dark waypoint patrol, threshold navigation, and proximity/room-based chase engagement.

### Prompt 3 (Step 3.1): Procedural Horror Audio
Files: `systems/core/procedural_audio.gd`, `systems/ghost/ghost_monster.gd`.
Test: Full suite headless verification.
Implement: Guttural breathing wave synthesizer and screech wave on chase start.
