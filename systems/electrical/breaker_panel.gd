class_name BreakerPanel
extends StaticBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")

signal breaker_interacted(new_state: GameTypes.BreakerState)

@export var electrical_system_path: NodePath = NodePath("")

var _electrical_system: ElectricalSystem = null

func _ready() -> void:
	add_to_group("breaker_panel")
	add_to_group("interactables")
	collision_layer = 1 # World layer so InteractionRay detects it
	_ensure_collision_shape()

func _ensure_collision_shape() -> void:
	for child in get_children():
		if child is CollisionShape3D:
			return
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 0.8, 0.3)
	col.shape = box
	add_child(col)

## Called when the player presses interact ('E') while looking at the breaker panel
func interact(_actor: Node = null) -> void:
	var electrical := _get_electrical_system()
	if electrical == null:
		push_warning("BreakerPanel cannot find ElectricalSystem.")
		return

	if electrical.breaker_state == GameTypes.BreakerState.TRIPPED:
		# Reset tripped breaker and restore full 100W power
		electrical.reset_breaker()
		breaker_interacted.emit(electrical.breaker_state)
		print("Breaker panel reset! Power restored to 100W.")
	else:
		# If operational and all lights off (e.g. Phase 0), activate all house lights
		if electrical.get_lit_room_count() == 0:
			electrical.turn_on_all_lights()
			breaker_interacted.emit(electrical.breaker_state)
			print("Basement breaker flipped! All house lights activated.")
		else:
			# If already lit, reset power back to full 100W
			electrical.reset_breaker()
			breaker_interacted.emit(electrical.breaker_state)

func set_electrical_system(system: ElectricalSystem) -> void:
	_electrical_system = system

func _get_electrical_system() -> ElectricalSystem:
	if _electrical_system != null and is_instance_valid(_electrical_system):
		return _electrical_system

	if not electrical_system_path.is_empty():
		var node = get_node_or_null(electrical_system_path)
		if node is ElectricalSystem:
			_electrical_system = node
			return _electrical_system

	var tree := get_tree()
	if tree != null:
		var found = tree.get_first_node_in_group("electrical_system")
		if found is ElectricalSystem:
			_electrical_system = found
			return _electrical_system

	return null
