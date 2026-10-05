# Contracts: The Seams Between Systems

**Version:** v0.1 **DRAFT** · **Date:** 2026-10-05

These are the typed interfaces crossing system boundaries. Four teammates and AI agents build against them in parallel.
**Nobody changes them casually.** Follow the Change Protocol at the bottom.

- Gameplay rules and values live in [`GAME_SPEC.md`](GAME_SPEC.md).
- This file holds **types, signatures, signals, and invariants**.
- Shared scripts live in `systems/shared/`.

---

## 1. Shared Types (`systems/shared/`, jointly owned)

### 1.1 `GameTypes`: Shared Enums (`systems/shared/game_types.gd`)

```gdscript
class_name GameTypes
extends RefCounted

enum LightState {
	OFF,
	ON,
	FLICKERING
}

enum BreakerState {
	OPERATIONAL,
	TRIPPED
}

enum PaintingState {
	INACTIVE,
	ACTIVE
}

enum GhostMode {
	FREE_ROAM,      # Roaming physical rooms in darkness
	PAINTING_BOUND, # Hiding or moving within portrait canvas
	CHASE,          # Actively pursuing player in darkness
	STUNNED         # Trapped/blinded when caught in light with no exit
}

enum DisturbanceType {
	AUDIO_FOOTSTEPS,
	AUDIO_WHISPER,
	AUDIO_CREAK,
	OBJECT_FALL,
	TEMPERATURE_DROP,
	CANVAS_DISTORTION
}

enum RoomId {
	ENTRY_HALL,
	PARLOR,
	STUDY,
	DINING_ROOM,
	BASEMENT
}
```

### 1.2 `PaintingData`: Portrait State Resource (`systems/shared/painting_data.gd`)

```gdscript
class_name PaintingData
extends Resource

@export var id: StringName = &""
@export var room_id: StringName = &""
@export var is_family_portrait: bool = false
@export var is_covered: bool = false
@export var is_turned: bool = false
@export var is_active: bool = true
@export var is_occupied_by_ghost: bool = false
@export var global_position: Vector3 = Vector3.ZERO
```

### 1.3 `GhostState`: Read-Only Snapshot (`systems/shared/ghost_state.gd`)

```gdscript
class_name GhostState
extends RefCounted

var room_id: StringName = &""
var position: Vector3 = Vector3.ZERO
var mode: GameTypes.GhostMode = GameTypes.GhostMode.FREE_ROAM
var current_painting_id: StringName = &""
var target_painting_id: StringName = &""
var is_chasing: bool = false
```

### 1.4 `ClueEvent`: Environmental Disturbance (`systems/shared/clue_event.gd`)

```gdscript
class_name ClueEvent
extends Resource

@export var type: GameTypes.DisturbanceType = GameTypes.DisturbanceType.AUDIO_CREAK
@export var room_id: StringName = &""
@export var origin: Vector3 = Vector3.ZERO
@export var intensity: float = 1.0  # 0.0 to 1.0
```

---

## 2. System Interfaces and Seams

### 2.1 Electrical & Lighting System (Owner: Rocky)
**Location:** `systems/electrical/`

**State Owned:** Circuits, room light states, breaker state, bulb condition, power grid meter (current wattage / max wattage).

**Public Signals:**
- `signal light_state_changed(room_id: StringName, new_state: GameTypes.LightState)`
- `signal breaker_state_changed(new_state: GameTypes.BreakerState)`
- `signal power_meter_updated(current_watts: float, max_watts: float)`
- `signal bulb_blown(room_id: StringName, fixture_id: StringName)`

**Public Methods:**
- `func get_room_light_state(room_id: StringName) -> GameTypes.LightState`
- `func is_room_lit(room_id: StringName) -> bool`
- `func get_current_power() -> float`
- `func get_lit_room_count() -> int`
- `func set_room_light(room_id: StringName, turn_on: bool) -> void`
- `func trip_breaker() -> void`
- `func reset_breaker() -> void`

---

### 2.2 Portrait / Painting System (Owner: Hali)
**Location:** `systems/portraits/`

**State Owned:** Portrait location, covered/uncovered, turned/moved, active/inactive, family portrait tracking.

**Public Signals:**
- `signal painting_state_changed(painting_id: StringName, data: PaintingData)`
- `signal family_portrait_picked_up()`
- `signal family_portrait_dropped(room_id: StringName, position: Vector3)`

**Public Methods:**
- `func get_painting_data(painting_id: StringName) -> PaintingData`
- `func get_paintings_in_room(room_id: StringName) -> Array[PaintingData]`
- `func get_valid_entry_paintings(room_id: StringName) -> Array[PaintingData]`
  *(Returns all paintings in the room where `is_covered == false` and `is_active == true`)*
- `func is_family_portrait_held() -> bool`
- `func get_family_portrait_data() -> PaintingData`
- `func set_painting_covered(painting_id: StringName, covered: bool) -> void`
- `func drape_sheet(painting_id: StringName) -> bool`
- `func remove_sheet(painting_id: StringName) -> bool`

---

### 2.3 Ghost / Monster System (Owner: John)
**Location:** `systems/ghost/`

**State Owned:** Ghost location, state, chase state, movement mode, target.

**Public Signals:**
- `signal ghost_moved(from_room: StringName, to_room: StringName, mode: GameTypes.GhostMode)`
- `signal ghost_entered_painting(painting_id: StringName)`
- `signal ghost_exited_painting(painting_id: StringName)`
- `signal ghost_chase_started(target: Node3D)`
- `signal ghost_chase_ended()`
- `signal player_killed()`

**Public Methods:**
- `func get_ghost_state() -> GhostState`
- `func force_enter_nearest_painting() -> bool`
  *(Invoked when room lights flip ON; queries Portrait system for valid uncovered, active paintings)*
- `func can_exit_house() -> bool`
  *(Returns true ONLY if current mode == PAINTING_BOUND and current_painting_id matches the family portrait)*

---

### 2.4 Environmental Clues System (Owner: Daniel)
**Location:** `systems/environment/`

**State Owned:** Physical disturbances, audio cues, clue intensity/location, triggered evidence.

**Public Signals:**
- `signal clue_triggered(event: ClueEvent)`

**Public Methods:**
- `func trigger_disturbance(event: ClueEvent) -> void`
- `func play_spatial_cue(sound_name: StringName, position: Vector3, volume_db: float) -> void`
- `func set_ambient_tension(tension_level: float) -> void` # 0.0 to 1.0

---

## 3. Invariants Across Seams

1. **Light Barrier Invariant:** The ghost cannot navigate through or occupy 3D physical room space when `ElectricalSystem.is_room_lit(room_id) == true`. Exposure to light forces immediate transition to `PAINTING_BOUND` or `STUNNED`.
2. **Painting Eligibility Invariant:** The ghost can never occupy a painting where `is_covered == true` or `is_active == false`. Covering a painting immediately bars ghost entry.
3. **Threshold Invariant:** The ghost cannot cross exterior door exit thresholds in `FREE_ROAM` or `CHASE` mode. It can only cross an exterior threshold while occupying the family portrait when carried by the player.
4. **Disturbance Causality Invariant:** Ghost spatial movements and room transitions trigger corresponding clue events via the Environmental Clues system.

---

## 4. Change Protocol

1. **Propose:** The author writes the proposed change and rationale in their feature's `00-brainstorm.md` / `01-spec.md`.
2. **Review:** All owners whose systems interface with the seam (see `TEAM.md` review pairs) review the change.
3. **Log:** Once agreed, log the decision as a `P-xxx` (then `D-xxx` upon sign-off) in `DECISIONS.md`.
4. **Apply:** Update this `CONTRACTS.md` file and update shared code in `systems/shared/` in a dedicated PR before building dependent feature code.
