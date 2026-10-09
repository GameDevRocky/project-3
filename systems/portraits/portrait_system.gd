class_name PortraitSystem
extends Node3D
## Registry and contract seam for portrait state. Ghost AI owns movement decisions.

signal painting_state_changed(painting_id: StringName, data: PaintingData)
signal monster_occupancy_changed(painting_id: StringName, has_monster: bool)
signal family_portrait_picked_up()
signal family_portrait_dropped(room_id: int, position: Vector3)

var _paintings: Dictionary[StringName, PortraitPainting] = {}
var _occupied_painting_id: StringName = &""

func _ready() -> void:
	for candidate: Node in get_tree().get_nodes_in_group("portrait_paintings"):
		if candidate is PortraitPainting:
			register_painting(candidate as PortraitPainting)

func register_painting(painting: PortraitPainting) -> bool:
	if painting == null or painting.portrait_id == &"":
		push_warning("Portrait registration rejected: painting needs a non-empty portrait_id.")
		return false
	if _paintings.has(painting.portrait_id):
		push_warning("Portrait registration rejected: duplicate id '%s'." % painting.portrait_id)
		return false
	_paintings[painting.portrait_id] = painting
	painting.occupancy_guard = can_enter_painting
	if painting.is_occupied:
		if _occupied_painting_id != &"":
			painting.set_occupied(false)
		else:
			_occupied_painting_id = painting.portrait_id
	painting.state_changed.connect(_on_painting_state_changed)
	painting.occupancy_changed.connect(_on_painting_occupancy_changed)
	_on_painting_state_changed(painting.get_data())
	return true

func unregister_painting(painting_id: StringName) -> bool:
	if not _paintings.has(painting_id):
		return false
	var painting: PortraitPainting = _paintings[painting_id]
	if painting.is_occupied:
		return false
	painting.state_changed.disconnect(_on_painting_state_changed)
	painting.occupancy_changed.disconnect(_on_painting_occupancy_changed)
	painting.occupancy_guard = Callable()
	_paintings.erase(painting_id)
	return true

func get_painting_data(painting_id: StringName) -> PaintingData:
	var painting: PortraitPainting = _paintings.get(painting_id) as PortraitPainting
	return painting.get_data() if is_instance_valid(painting) else null

func get_paintings_in_room(room_id: int) -> Array[PaintingData]:
	var result: Array[PaintingData] = []
	for painting: PortraitPainting in _paintings.values():
		if is_instance_valid(painting) and painting.room_id == room_id:
			result.append(painting.get_data())
	return result

func get_valid_entry_paintings(room_id: int) -> Array[PaintingData]:
	var result: Array[PaintingData] = []
	for painting: PortraitPainting in _paintings.values():
		if is_instance_valid(painting) and painting.room_id == room_id and painting.is_eligible_for_ghost():
			result.append(painting.get_data())
	return result

func find_nearest_valid_entry_painting(room_id: int, from_position: Vector3) -> PortraitPainting:
	var nearest: PortraitPainting = null
	var nearest_distance: float = INF
	for painting: PortraitPainting in _paintings.values():
		if not is_instance_valid(painting) or painting.room_id != room_id or not painting.is_eligible_for_ghost():
			continue
		var distance: float = from_position.distance_squared_to(painting.global_position)
		if distance < nearest_distance:
			nearest = painting
			nearest_distance = distance
	return nearest

func can_enter_painting(painting_id: StringName) -> bool:
	var painting: PortraitPainting = _paintings.get(painting_id) as PortraitPainting
	return _occupied_painting_id == &"" and is_instance_valid(painting) and painting.is_eligible_for_ghost()

func set_monster_occupied(painting_id: StringName, occupied: bool) -> bool:
	var painting: PortraitPainting = _paintings.get(painting_id) as PortraitPainting
	if not is_instance_valid(painting):
		return false
	if occupied:
		if not can_enter_painting(painting_id):
			return false
		return painting.set_occupied(true)
	if not painting.is_occupied or _occupied_painting_id != painting_id:
		return false
	return painting.set_occupied(false)

func enter_painting(painting_id: StringName) -> bool:
	return set_monster_occupied(painting_id, true)

func exit_painting(painting_id: StringName) -> bool:
	return set_monster_occupied(painting_id, false)

func get_occupied_painting_id() -> StringName:
	return _occupied_painting_id

func get_painting_status(painting_id: StringName) -> Dictionary:
	var data: PaintingData = get_painting_data(painting_id)
	if data == null:
		return {"found": false, "is_covered": false, "is_active": false, "is_occupied": false}
	return {"found": true, "is_covered": data.is_covered, "is_active": data.is_active, "is_occupied": data.is_occupied}

func drape_sheet(painting_id: StringName) -> bool:
	var painting: PortraitPainting = _paintings.get(painting_id) as PortraitPainting
	return is_instance_valid(painting) and painting.set_covered(true)

func remove_sheet(painting_id: StringName) -> bool:
	var painting: PortraitPainting = _paintings.get(painting_id) as PortraitPainting
	return is_instance_valid(painting) and painting.set_covered(false)

func set_painting_active(painting_id: StringName, active: bool) -> bool:
	var painting: PortraitPainting = _paintings.get(painting_id) as PortraitPainting
	return is_instance_valid(painting) and painting.set_active(active)

func get_family_portrait_data() -> PaintingData:
	var portrait: PortraitPainting = _get_family_portrait()
	return portrait.get_data() if is_instance_valid(portrait) else null

func is_family_portrait_held() -> bool:
	var portrait: PortraitPainting = _get_family_portrait()
	return is_instance_valid(portrait) and portrait.is_being_carried

func remove_family_portrait(all_boxes_loaded: bool, carry_socket: Node3D) -> bool:
	var portrait: PortraitPainting = _get_family_portrait()
	if not all_boxes_loaded or not is_instance_valid(portrait):
		return false
	if not portrait.remove_from_wall(carry_socket):
		return false
	family_portrait_picked_up.emit()
	return true

func drop_family_portrait(room_id: int, world_transform: Transform3D, new_parent: Node) -> bool:
	var portrait: PortraitPainting = _get_family_portrait()
	if not is_instance_valid(portrait) or not portrait.drop_at(world_transform, new_parent):
		return false
	portrait.set_room_id(room_id)
	family_portrait_dropped.emit(room_id, portrait.global_position)
	return true

func is_family_portrait_safe_to_remove() -> bool:
	var portrait: PortraitPainting = _get_family_portrait()
	return is_instance_valid(portrait) and portrait.is_safe_to_remove_from_house()

func _get_family_portrait() -> PortraitPainting:
	for painting: PortraitPainting in _paintings.values():
		if is_instance_valid(painting) and painting.is_family_portrait:
			return painting
	return null

func _on_painting_state_changed(data: PaintingData) -> void:
	painting_state_changed.emit(data.id, data)

func _on_painting_occupancy_changed(painting_id: StringName, has_monster: bool) -> void:
	if has_monster:
		_occupied_painting_id = painting_id
	elif _occupied_painting_id == painting_id:
		_occupied_painting_id = &""
	monster_occupancy_changed.emit(painting_id, has_monster)
