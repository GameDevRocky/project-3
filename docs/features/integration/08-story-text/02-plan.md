# 08-story-text: Plan

| | |
|---|---|
| System / Owner | Integration / John |
| Spec | [01-spec.md](01-spec.md) |
| TODO | [03-todo.md](03-todo.md) |

## 1. Blueprint

1. **Iteration 1: Intro Overlay & Narrative Tooltips:** Add intro story modal to `game_hud.gd` (dismissible via E/Space), transient tooltip banner for `"It has awoken"`, low-voltage warnings, and shadow movement notifications.
2. **Iteration 2: Horror Audio Cues & Jumpscare:** Enhance painting audio, add chase lock-on sting, chase rumbling drone, and jumpscare flash overlay upon player capture in `procedural_audio.gd` and `player_controller.gd`.
3. **Iteration 3: Narrative Endings & Verification:** Implement rich text for Win, Loss, and Death endings in `game_coordinator.gd` and `game_hud.gd`, and run full GUT test suite.

## 2. Iterations and steps

### Iteration 1: Intro Overlay & Narrative Tooltips
- **Step 1.1:** Add intro story overlay and transient notification system in `game_hud.gd`.
- **Step 1.2:** Wire breaker flip event to show `"It has awoken"`, low-voltage dimming warning, and ghost room movement notifications.

### Iteration 2: Horror Audio & Jumpscare
- **Step 2.1:** Synthesize chase rumbling drone and jumpscare shriek in `procedural_audio.gd`.
- **Step 2.2:** Add jumpscare strobe flash and audio trigger on player death in `player_controller.gd` / `game_hud.gd`.

### Iteration 3: Narrative Endings & Verification
- **Step 3.1:** Set rich narrative strings in `game_coordinator.gd`.
- **Step 3.2:** Execute full headless GUT test suite.
