# 01-light-circuits: Spec

| | |
|---|---|
| System / Owner | Electrical & Lighting / Rocky |
| Branch | `electrical/01-light-circuits` |
| Status | Approved (2026-10-12) |
| Brainstorm | [00-brainstorm.md](00-brainstorm.md) |
| Milestone | Playtest (M1) |

## 1. Overview

This feature implements the foundational Electrical & Lighting System (`systems/electrical/electrical_system.gd` & `.tscn`) owned by Rocky. It manages the house circuit network across five rooms (Entry Hall, Parlor, Study, Dining Room, Basement), tracks the 100-watt power grid reserve with continuous drain and recharge dynamics, provides circuit breaker state transitions, and serves the public contract queries required by the Ghost AI (`is_room_lit`, `get_room_light_state`) and Player interactions (`set_room_light`, `reset_breaker`).

## 2. Player-Facing Behavior

1. **Room Illumination:** Flipping a room light ON illuminates that room, protecting the player from direct monster roaming and forcing the monster into nearby paintings.
2. **Wattage Drain:** Each room illuminated consumes 1.0 Watt per second from the house's 100W grid reserve.
3. **Power Recharge:** When all lights in the house are switched OFF, power recharges at 5.0 W/s back toward 100.0 Watts.
4. **Grid Blackout & Breaker Trip:** If the reserve reaches 0.0 W, the master breaker instantly trips with a metallic crash. All room lights cut out immediately, leaving the player in pitch darkness and unfreezing the monster.
5. **Breaker Panel Reset:** Resetting the breaker panel restores the circuit to `OPERATIONAL` and refills the power reserve to 100.0 Watts.
6. **Basement Startup (Phase 0):** Flipping the breaker for the first time turns on all house lights via `turn_on_all_lights()`.

## 3. Rules and Numbers

| Rule / Constant | Value | Source |
|---|---|---|
| Max Power Grid Capacity | 100.0 Watts | `GAME_SPEC.md` §9 |
| Light Drain Rate Per Room | 1.0 W/s per lit room | `GAME_SPEC.md` §9 |
| Grid Recharge Rate | 5.0 W/s (all dark) | `GAME_SPEC.md` §9 |
| Breaker Trip Threshold | 0.0 Watts | `GAME_SPEC.md` §9 |
| Breaker Reset Value | 100.0 Watts | `GAME_SPEC.md` §9 |
| Controlled Rooms | 5 (Entry Hall, Parlor, Study, Dining Room, Basement) | `CONTRACTS.md` §1.1 |

## 4. Interfaces

**Uses:**
- `CONTRACTS.md` §1.1: `GameTypes.LightState`, `GameTypes.BreakerState`, `GameTypes.RoomId`.

**Provides / Emits:**
- `signal light_state_changed(room_id: GameTypes.RoomId, new_state: GameTypes.LightState)`: Emitted whenever a room's illumination changes.
- `signal breaker_state_changed(new_state: GameTypes.BreakerState)`: Emitted on blackout trip or breaker panel reset.
- `signal power_meter_updated(current_watts: float, max_watts: float)`: Emitted as power drains or recharges.
- `signal bulb_blown(room_id: GameTypes.RoomId, fixture_id: StringName)`: Reserved for bulb blowout events.
- `func get_room_light_state(room_id: GameTypes.RoomId) -> GameTypes.LightState`
- `func is_room_lit(room_id: GameTypes.RoomId) -> bool`
- `func get_current_power() -> float`
- `func get_lit_room_count() -> int`
- `func set_room_light(room_id: GameTypes.RoomId, turn_on: bool) -> void`
- `func trip_breaker() -> void`
- `func reset_breaker() -> void`
- `func turn_on_all_lights() -> void`

**Contract changes:**
- None. Fully adheres to `CONTRACTS.md` v0.2 §2.1.

## 5. Scenes and Files

| Path | Purpose |
|---|---|
| `systems/electrical/electrical_system.gd` | Core electrical manager node, power simulation loop, and contract API |
| `systems/electrical/electrical_system.tscn` | Node3D scene instantiable into tests and `main.tscn` |
| `tests/electrical/test_electrical_system.gd` | Headless GUT unit tests verifying lighting states, breaker tripping/reset, and wattage simulation |

## 6. Edge Cases

- **Turning on lights while breaker is tripped:** Calls to `set_room_light(room_id, true)` are rejected while breaker is `TRIPPED`; state remains `OFF`.
- **Power drain reaching 0 exactly:** When `current_power <= 0.0`, breaker automatically trips, clamps power to `0.0`, and turns all lights `OFF`.
- **External rooms:** `RoomId.EXTERIOR_DRIVEWAY` is not part of the indoor lighting grid and always reports `LightState.OFF`.

## 7. Out of Scope

- Physical light switch meshes and raycast interaction prompts (handled by Player / Sockets).
- Ghost AI reaction logic (handled by Ghost Monster).

## 8. Done When

- [ ] `systems/electrical/electrical_system.gd` and `.tscn` implemented.
- [ ] Correctly tracks room light states and answers `is_room_lit()` and `get_room_light_state()`.
- [ ] Drains wattage proportionally to lit room count and recharges at 5.0 W/s when all rooms are dark.
- [ ] Automatically trips breaker at 0.0 W, plunging all rooms to `OFF`.
- [ ] Breaker reset restores 100.0 Watts and permits lighting.
- [ ] `tests/electrical/test_electrical_system.gd` passes 100% in headless GUT suite.
