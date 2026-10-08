# Contracts: The Seams Between Systems

**Version:** v0.2 · **Date:** 2026-10-07

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
	PAINTING_BOUND, # Frozen inside an active painting in a lit room
	CHASE,          # Actively pursuing player in darkness
	DORMANT         # Opening startup phase before breaker is flipped
}

enum RoomId {
	ENTRY_HALL,
	PARLOR,
	STUDY,
	DINING_ROOM,
	BASEMENT,
	EXTERIOR_DRIVEWAY
}

enum CarriedItemType {
	NONE,
	BOX_LIVING_ROOM,
	BOX_DINING_ROOM,
	BOX_STUDY,
	BOX_BASEMENT,
	DUST_SHEET,
	FAMILY_PORTRAIT
}
```

### 1.2 `PaintingData`: Portrait State Resource (`systems/shared/painting_data.gd`)

```gdscript
class_name PaintingData
extends Resource

@export var id: StringName = &""
@export var room_id: GameTypes.RoomId = GameTypes.RoomId.ENTRY_HALL
@export var is_family_portrait: bool = false
@export var is_covered: bool = false
@export var is_active: bool = true
@export var is_occupied: bool = false # Seam: Monster presence rendered on canvas
@export var global_position: Vector3 = Vector3.ZERO
```

### 1.3 `GhostState`: Read-Only Snapshot (`systems/shared/ghost_state.gd`)

```gdscript
class_name GhostState
extends RefCounted

var room_id: GameTypes.RoomId = GameTypes.RoomId.BASEMENT
var position: Vector3 = Vector3.ZERO
var mode: GameTypes.GhostMode = GameTypes.GhostMode.DORMANT
var current_painting_id: StringName = &""
var target_painting_id: StringName = &""
var is_chasing: bool = false
```

### 1.4 `PlayerState`: Read-Only Snapshot (`systems/shared/player_state.gd`)

```gdscript
class_name PlayerState
extends RefCounted

var room_id: GameTypes.RoomId = GameTypes.RoomId.ENTRY_HALL
var position: Vector3 = Vector3.ZERO
var carried_item: GameTypes.CarriedItemType = GameTypes.CarriedItemType.NONE
var is_alive: bool = true
var boxes_packed_count: int = 0
```

---

## 2. System Interfaces and Seams

### 2.1 Electrical & Lighting System (Owner: Rocky)
**Location:** `systems/electrical/`

**State Owned:** Circuits, room light states, breaker state, bulb condition, power grid meter (100W capacity, drain/recharge rates).

**Public Signals:**
- `signal light_state_changed(room_id: GameTypes.RoomId, new_state: GameTypes.LightState)`
- `signal breaker_state_changed(new_state: GameTypes.BreakerState)`
- `signal power_meter_updated(current_watts: float, max_watts: float)`
- `signal bulb_blown(room_id: GameTypes.RoomId, fixture_id: StringName)`

**Public Methods:**
- `func get_room_light_state(room_id: GameTypes.RoomId) -> GameTypes.LightState`
- `func is_room_lit(room_id: GameTypes.RoomId) -> bool`
- `func get_current_power() -> float`
- `func get_lit_room_count() -> int`
- `func set_room_light(room_id: GameTypes.RoomId, turn_on: bool) -> void`
- `func trip_breaker() -> void`
- `func reset_breaker() -> void`
- `func turn_on_all_lights() -> void` # Called on initial basement breaker flip

---

### 2.2 Portrait / Painting System (Owner: Haliyah)
**Location:** `systems/portraits/`

**State Owned:** Portrait locations, covered/uncovered status, active/inactive state, family portrait tracking, and monster occupancy visual flag.

**Public Signals:**
- `signal painting_state_changed(painting_id: StringName, data: PaintingData)`
- `signal monster_occupancy_changed(painting_id: StringName, has_monster: bool)`
- `signal family_portrait_picked_up()`
- `signal family_portrait_dropped(room_id: GameTypes.RoomId, position: Vector3)`

**Public Methods:**
- `func get_painting_data(painting_id: StringName) -> PaintingData`
- `func get_paintings_in_room(room_id: GameTypes.RoomId) -> Array[PaintingData]`
- `func get_valid_entry_paintings(room_id: GameTypes.RoomId) -> Array[PaintingData]`
  *(Returns all paintings in the room where `is_covered == false` and `is_active == true` and `is_occupied == false`)*
- `func set_monster_occupied(painting_id: StringName, occupied: bool) -> void`
- `func is_family_portrait_held() -> bool`
- `func get_family_portrait_data() -> PaintingData`
- `func drape_sheet(painting_id: StringName) -> bool`
- `func remove_sheet(painting_id: StringName) -> bool`

---

### 2.3 Player System (Owner: Daniel)
**Location:** `systems/player/`

**State Owned:** Player position/rotation, movement state, carried item (boxes, sheet, portrait), dark-adaptation ambient glow, interaction raycast focus, alive/dead state.

**Public Signals:**
- `signal player_died()`
- `signal item_packed(item_type: GameTypes.CarriedItemType)`
- `signal carried_item_changed(item_type: GameTypes.CarriedItemType)`

**Public Methods:**
- `func get_player_state() -> PlayerState`
- `func try_interact() -> void`
- `func kill_player() -> void`
- `func deposit_box_in_car() -> bool`
- `func is_carrying_box() -> bool`
- `func get_carried_item() -> GameTypes.CarriedItemType`

---

### 2.4 Ghost / Monster System (Owner: John)
**Location:** `systems/ghost/`

**State Owned:** Ghost location, state, chase state, movement mode, target, occupied portrait ID, lethal contact trigger.

**Public Signals:**
- `signal ghost_moved(from_room: GameTypes.RoomId, to_room: GameTypes.RoomId, mode: GameTypes.GhostMode)`
- `signal ghost_entered_painting(painting_id: StringName)`
- `signal ghost_exited_painting(painting_id: StringName)`
- `signal ghost_chase_started()`
- `signal ghost_chase_ended()`
- `signal player_killed()`

**Public Methods:**
- `func get_ghost_state() -> GhostState`
- `func set_monster_dormant(dormant: bool) -> void` # True during Phase 0 until breaker is flipped
- `func force_enter_nearest_painting() -> bool`
  *(Invoked when room lights flip ON; queries Portrait system for valid uncovered, active paintings and freezes)*
- `func can_exit_house() -> bool`
  *(Returns true ONLY if current mode == PAINTING_BOUND and current_painting_id matches the family portrait)*

---

## 3. Invariants Across Seams

1. **Light Barrier & Freezing Invariant:** The monster cannot navigate through or occupy 3D room space when `ElectricalSystem.is_room_lit(room_id) == true`. Exposure to light forces immediate transition to `PAINTING_BOUND` inside an uncovered painting where it is immobilized.
2. **Painting Eligibility Invariant:** The monster can never occupy a painting where `is_covered == true` or `is_active == false` or `is_occupied == true`. Covering a painting immediately bars monster entry.
3. **Threshold Invariant:** The monster cannot cross exterior door exit thresholds in `FREE_ROAM` or `CHASE` mode. It can only cross an exterior threshold while occupying the family portrait when carried by the player.
4. **Startup Onboarding Invariant:** During Phase 0, the monster remains `DORMANT` and cannot attack or harm the player until the basement breaker is flipped for the first time.
5. **Lethal Contact Invariant:** Physical contact between the roaming monster and the player in darkness immediately triggers the player's death sequence.

---

## 4. Change Protocol

1. **Propose:** The author writes the proposed change and rationale in their feature's `00-brainstorm.md` / `01-spec.md`.
2. **Review:** All owners whose systems interface with the seam (see `TEAM.md` review pairs) review the change.
3. **Log:** Once agreed, log the decision as a `P-xxx` (then `D-xxx` upon sign-off) in `DECISIONS.md`.
4. **Apply:** Update this `CONTRACTS.md` file and update shared code in `systems/shared/` in a dedicated PR before building dependent feature code.
