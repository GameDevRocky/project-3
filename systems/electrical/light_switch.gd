class_name LightSwitch
extends StaticBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")

@export var room_id: GameTypes.RoomId = GameTypes.RoomId.ENTRY_HALL
@export var electrical_system_path: NodePath = NodePath("")

var _electrical_system: ElectricalSystem = null

func _ready() -> void:
	add_to_group("light_switches")
	add_to_group("interactables")
	collision_layer = 1 # World layer so InteractionRay detects it
	_ensure_collision_shape()

func _ensure_collision_shape() -> void:
	for child in get_children():
		if child is CollisionShape3D:
			return
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.3, 0.4, 0.2)
	col.shape = box
	add_child(col)

## Called when the player presses interact ('E') while looking at this switch
func interact(_actor: Node = null) -> void:
	var electrical := _get_electrical_system()
	if electrical == null:
		push_warning("LightSwitch for room %d cannot find ElectricalSystem." % room_id)
		return

	var is_lit := electrical.is_room_lit(room_id)
	electrical.set_room_light(room_id, not is_lit)

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
