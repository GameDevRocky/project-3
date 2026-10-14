class_name ElectricalSystem
extends Node3D

const GameTypes = preload("res://systems/shared/game_types.gd")
const PowerMeterHUDScene = preload("res://systems/electrical/power_meter_hud.tscn")

## Emitted when a room's illumination state changes
signal light_state_changed(room_id: GameTypes.RoomId, new_state: GameTypes.LightState)

## Emitted when the master breaker trips (overload/blackout) or is reset
signal breaker_state_changed(new_state: GameTypes.BreakerState)

## Emitted when the power grid reserve updates
signal power_meter_updated(current_watts: float, max_watts: float)

## Emitted when a specific light bulb blows out
signal bulb_blown(room_id: GameTypes.RoomId, fixture_id: StringName)

@export var max_power: float = 100.0
@export var current_power: float = 100.0
@export var drain_rate_per_room: float = 1.0 ## Watts per second per lit room
@export var recharge_rate: float = 5.0 ## Watts per second when all lights OFF
@export var breaker_state: GameTypes.BreakerState = GameTypes.BreakerState.OPERATIONAL

## Room light states for indoor house circuits
var _room_states: Dictionary[int, int] = {
	GameTypes.RoomId.ENTRY_HALL: GameTypes.LightState.OFF,
	GameTypes.RoomId.PARLOR: GameTypes.LightState.OFF,
	GameTypes.RoomId.STUDY: GameTypes.LightState.OFF,
	GameTypes.RoomId.DINING_ROOM: GameTypes.LightState.OFF,
	GameTypes.RoomId.BASEMENT: GameTypes.LightState.OFF,
}

## Optional references to visual OmniLight3D fixtures
var _light_fixtures: Dictionary[int, Node3D] = {}

func _ready() -> void:
	add_to_group("electrical_system")
	_bind_scene_fixtures()
	_ensure_hud()

func _process(delta: float) -> void:
	if breaker_state == GameTypes.BreakerState.TRIPPED:
		return

	var lit_count: int = get_lit_room_count()
	if lit_count > 0:
		current_power = max(0.0, current_power - (lit_count * drain_rate_per_room * delta))
		power_meter_updated.emit(current_power, max_power)
		if current_power < 15.0:
			_update_fixture_energies()
		if current_power <= 0.0:
			trip_breaker()
	else:
		if current_power < max_power:
			current_power = min(max_power, current_power + (recharge_rate * delta))
			power_meter_updated.emit(current_power, max_power)
			if current_power >= 15.0:
				_update_fixture_energies()

## Returns the current light state of a given room
func get_room_light_state(room_id: GameTypes.RoomId) -> GameTypes.LightState:
	if breaker_state == GameTypes.BreakerState.TRIPPED:
		return GameTypes.LightState.OFF
	return _room_states.get(room_id, GameTypes.LightState.OFF) as GameTypes.LightState

## Returns true if the room is actively illuminated (ON or FLICKERING)
func is_room_lit(room_id: GameTypes.RoomId) -> bool:
	if breaker_state == GameTypes.BreakerState.TRIPPED:
		return false
	var state: GameTypes.LightState = get_room_light_state(room_id)
	return state == GameTypes.LightState.ON or state == GameTypes.LightState.FLICKERING

## Returns the current power remaining in Watts
func get_current_power() -> float:
	return current_power

## Returns the number of currently lit rooms
func get_lit_room_count() -> int:
	if breaker_state == GameTypes.BreakerState.TRIPPED:
		return 0
	var count: int = 0
	for room in _room_states.keys():
		if is_room_lit(room as GameTypes.RoomId):
			count += 1
	return count

## Sets an individual room's light state
func set_room_light(room_id: GameTypes.RoomId, turn_on: bool) -> void:
	if not _room_states.has(room_id):
		return

	if breaker_state == GameTypes.BreakerState.TRIPPED:
		return

	var new_state: GameTypes.LightState = GameTypes.LightState.ON if turn_on else GameTypes.LightState.OFF
	var old_state: GameTypes.LightState = _room_states[room_id] as GameTypes.LightState
	if old_state == new_state:
		return

	_room_states[room_id] = new_state
	_sync_fixture(room_id, turn_on)
	light_state_changed.emit(room_id, new_state)

## Trips the master breaker, plunging the house into darkness
func trip_breaker() -> void:
	if breaker_state == GameTypes.BreakerState.TRIPPED:
		return

	breaker_state = GameTypes.BreakerState.TRIPPED
	breaker_state_changed.emit(breaker_state)

	# Turn off all room lights
	for room_id in _room_states.keys():
		var was_lit: bool = (_room_states[room_id] != GameTypes.LightState.OFF)
		_room_states[room_id] = GameTypes.LightState.OFF
		_sync_fixture(room_id as GameTypes.RoomId, false)
		if was_lit:
			light_state_changed.emit(room_id as GameTypes.RoomId, GameTypes.LightState.OFF)

## Resets the tripped breaker, restoring power to 100W
func reset_breaker() -> void:
	breaker_state = GameTypes.BreakerState.OPERATIONAL
	current_power = max_power
	breaker_state_changed.emit(breaker_state)
	power_meter_updated.emit(current_power, max_power)

## Turns on all 5 house rooms (used during Phase 0 basement breaker flip)
func turn_on_all_lights() -> void:
	if breaker_state == GameTypes.BreakerState.TRIPPED:
		return

	for room_id in [GameTypes.RoomId.ENTRY_HALL, GameTypes.RoomId.PARLOR, GameTypes.RoomId.STUDY, GameTypes.RoomId.DINING_ROOM, GameTypes.RoomId.BASEMENT]:
		set_room_light(room_id, true)

func _bind_scene_fixtures() -> void:
	var root: Node = get_tree().current_scene if get_tree() != null else null
	if root == null:
		return
	var sockets: Node = root.get_node_or_null("Sockets/LightFixtureSockets")
	if sockets == null:
		return
	var mapping: Dictionary = {
		GameTypes.RoomId.ENTRY_HALL: sockets.get_node_or_null("Light_EntryHall"),
		GameTypes.RoomId.PARLOR: sockets.get_node_or_null("Light_Parlor"),
		GameTypes.RoomId.STUDY: sockets.get_node_or_null("Light_Study"),
		GameTypes.RoomId.DINING_ROOM: sockets.get_node_or_null("Light_DiningRoom"),
		GameTypes.RoomId.BASEMENT: sockets.get_node_or_null("Light_Basement")
	}
	for room in mapping.keys():
		var fixture = mapping[room]
		if fixture != null and fixture is Node3D:
			_light_fixtures[room] = fixture
			_sync_fixture(room as GameTypes.RoomId, is_room_lit(room as GameTypes.RoomId))

func _sync_fixture(room_id: GameTypes.RoomId, lit: bool) -> void:
	var fixture: Node3D = _light_fixtures.get(room_id)
	if fixture != null:
		if "visible" in fixture:
			fixture.visible = lit
		if "light_energy" in fixture:
			var dim_factor: float = clampf(current_power / 15.0, 0.35, 1.0) if current_power < 15.0 else 1.0
			fixture.light_energy = 1.2 * dim_factor

func _update_fixture_energies() -> void:
	for room_id in _room_states.keys():
		if is_room_lit(room_id as GameTypes.RoomId):
			_sync_fixture(room_id as GameTypes.RoomId, true)

func _ensure_hud() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
	if tree.get_first_node_in_group("power_meter_hud") != null:
		return
	var hud := PowerMeterHUDScene.instantiate()
	add_child(hud)
	hud.add_to_group("power_meter_hud")
	hud.set_electrical_system(self)
