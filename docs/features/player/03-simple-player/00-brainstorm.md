# 03-simple-player: Brainstorm

| | |
|---|---|
| System | Player |
| Owner | Daniel (Assisted by Integration) |
| Branch | `integration/03-simple-player` |
| Agent | Gemini CLI |
| Date | 2026-10-07 |
| Milestone | Playtest (M1) |

## Goal

Implement a simple first-person player controller (`systems/player/player_controller.gd` & `.tscn`) to allow playtesting the house, moving around, looking with the mouse, toggling light switches, and inspecting rooms.

## Grounding

- `GAME_SPEC.md` §7, §8: First-person perspective (`Camera3D`), WASD movement (3.5 m/s walk, 5.8 m/s sprint), mouse-look, interaction action (`interact` / `E`).
- `CONTRACTS.md` §2.3: `PlayerState`, `try_interact`, `deposit_box_in_car`, `kill_player`.

## Q&A

1. **Q:** How should mouse look and capture be handled in the playtest controller?
   **A:** Click to Capture / ESC to Release. · *why:* Standard PC game behavior, allowing easy window focus and cursor release without trapping the user.

## Decisions

- The player controller (`PlayerController`) will use `CharacterBody3D` with gravity, WASD movement, mouse-look pitch/yaw clamping, click-to-capture, and ESC-to-release mouse mode.

## Contract changes needed

- None.

## Open questions

- Mouse sensitivity tuning.

## Out of scope

- Full inventory carrying simulation (to be refined in subsequent player polish features).
