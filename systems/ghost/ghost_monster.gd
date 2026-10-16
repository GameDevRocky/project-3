class_name GhostMonster
extends CharacterBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")
const GhostState = preload("res://systems/shared/ghost_state.gd")

signal ghost_moved(from_room: GameTypes.RoomId, to_room: GameTypes.RoomId, mode: GameTypes.GhostMode)
signal ghost_entered_painting(painting_id: StringName)
signal ghost_exited_painting(painting_id: StringName)
signal ghost_chase_started()
signal ghost_chase_ended()
signal ghost_roam_sound_requested()
signal ghost_teleported(to_room: GameTypes.RoomId)
signal player_killed()

@export var roam_speed: float = 1.8
@export var chase_speed: float = 3.2
@export var attack_distance: float = 0.85
@export var exterior_threshold_z: float = -0.35
@export var current_room: GameTypes.RoomId = GameTypes.RoomId.BASEMENT

const ROOM_WAYPOINTS: Dictionary = {
	GameTypes.RoomId.ENTRY_HALL: [
		Vector3(0.0, 0.2, -2.0),
		Vector3(-1.5, 0.2, -4.0),
		Vector3(1.5, 0.2, -3.5),
		Vector3(0.0, 0.2, -4.8),
	],
	GameTypes.RoomId.PARLOR: [
		Vector3(-6.5, 0.2, -2.5),
		Vector3(-8.5, 0.2, -4.5),
		Vector3(-9.5, 0.2, -2.0),
		Vector3(-7.5, 0.2, -4.8),
	],
	GameTypes.RoomId.STUDY: [
		Vector3(5.0, 0.2, -2.5),
		Vector3(7.0, 0.2, -4.5),
		Vector3(7.5, 0.2, -2.0),
		Vector3(5.5, 0.2, -4.8),
	],
	GameTypes.RoomId.DINING_ROOM: [
		Vector3(0.5, 0.2, -8.0),
		Vector3(3.5, 0.2, -8.5),
		Vector3(3.5, 0.2, -11.5),
		Vector3(0.5, 0.2, -11.5),
	],
	GameTypes.RoomId.BASEMENT: [
		Vector3(-4.0, -3.35, -10.0),
		Vector3(-4.0, -3.35, -14.0),
		Vector3(0.5, -3.35, -13.0),
		Vector3(-2.0, -3.35, -14.5),
	],
}

const ADJACENT_ROOMS: Dictionary = {
	GameTypes.RoomId.ENTRY_HALL: [GameTypes.RoomId.PARLOR, GameTypes.RoomId.STUDY, GameTypes.RoomId.DINING_ROOM, GameTypes.RoomId.BASEMENT],
	GameTypes.RoomId.PARLOR: [GameTypes.RoomId.ENTRY_HALL],
	GameTypes.RoomId.STUDY: [GameTypes.RoomId.ENTRY_HALL],
	GameTypes.RoomId.DINING_ROOM: [GameTypes.RoomId.ENTRY_HALL],
	GameTypes.RoomId.BASEMENT: [GameTypes.RoomId.ENTRY_HALL],
}

var mode: GameTypes.GhostMode = GameTypes.GhostMode.DORMANT
var current_painting_id: StringName = &""
var target_painting_id: StringName = &""
var is_chasing: bool = false
var _dormant: bool = true
var _target_player: Node3D = null
var _electrical_system: ElectricalSystem = null
var _portrait_system: PortraitSystem = null
var _exit_position: Vector3 = Vector3.ZERO
var _has_killed_target: bool = false
var _bound_painting_node: PortraitPainting = null

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var shadow_mesh: MeshInstance3D = $ShadowMesh
@onready var head_pivot: Node3D = get_node_or_null("ShadowMesh/HeadPivot") as Node3D
@onready var eye_left: MeshInstance3D = get_node_or_null("ShadowMesh/HeadPivot/EyeLeft") as MeshInstance3D
@onready var eye_right: MeshInstance3D = get_node_or_null("ShadowMesh/HeadPivot/EyeRight") as MeshInstance3D
@onready var eye_aura: OmniLight3D = get_node_or_null("ShadowMesh/HeadPivot/EyeAura") as OmniLight3D

var _is_eyes_flaring: bool = false

func _ready() -> void:
	add_to_group("ghost")
	add_to_group("mcp_watch")
	collision_layer = 4
	collision_mask = 7 # World (1) | Player (2) | Monster (4)
	floor_snap_length = 0.4
	floor_constant_speed = true
	floor_max_angle = deg_to_rad(55.0)
	if eye_left != null and eye_left.material_override != null:
		eye_left.material_override = eye_left.material_override.duplicate()
	if eye_right != null and eye_right.material_override != null:
		eye_right.material_override = eye_right.material_override.duplicate()
	_apply_dormancy_state()

func is_eyes_flaring() -> bool:
	return _is_eyes_flaring

func set_eyes_flaring(flaring: bool) -> void:
	_is_eyes_flaring = flaring
	var mult: float = 8.0 if flaring else 4.0
	var light_eng: float = 1.2 if flaring else 0.6
	if eye_left != null and eye_left.material_override is StandardMaterial3D:
		(eye_left.material_override as StandardMaterial3D).emission_energy_multiplier = mult
	if eye_right != null and eye_right.material_override is StandardMaterial3D:
		(eye_right.material_override as StandardMaterial3D).emission_energy_multiplier = mult
	if eye_aura != null:
		eye_aura.light_energy = light_eng

func _update_eye_tracking() -> void:
	if head_pivot == null or _target_player == null or not is_instance_valid(_target_player):
		return
	var target_head: Vector3 = _target_player.global_position + Vector3(0, 1.5, 0)
	var diff: Vector3 = target_head - head_pivot.global_position
	if diff.length_squared() > 0.01:
		head_pivot.look_at(target_head, Vector3.UP)

func _physics_process(delta: float) -> void:
	if _dormant:
		mode = GameTypes.GhostMode.DORMANT
		return

	_resolve_dependencies()
	if mode == GameTypes.GhostMode.PAINTING_BOUND:
		if _bound_painting_node != null and is_instance_valid(_bound_painting_node):
			global_position = _bound_painting_node.global_position
			velocity = Vector3.ZERO
			return
		if _should_remain_in_painting():
			velocity = Vector3.ZERO
			return
		_exit_current_painting()

	# A lit room is a hard movement barrier. Enter a valid frame or remain stunned.
	if _check_light_reaction():
		velocity = Vector3.ZERO
		return

	_update_eye_tracking()
	_process_trapped_and_sabotage(delta)

	match mode:
		GameTypes.GhostMode.FREE_ROAM, GameTypes.GhostMode.CHASE:
			_process_roam_or_chase(delta)
		GameTypes.GhostMode.PAINTING_BOUND:
			velocity = Vector3.ZERO

func set_monster_dormant(dormant: bool) -> void:
	_dormant = dormant
	if dormant:
		mode = GameTypes.GhostMode.DORMANT
	else:
		mode = GameTypes.GhostMode.FREE_ROAM
		_has_killed_target = false
	_apply_dormancy_state()

func _apply_dormancy_state() -> void:
	if _dormant:
		mode = GameTypes.GhostMode.DORMANT
		collision_layer = 0
		collision_mask = 0
		if shadow_mesh != null:
			shadow_mesh.visible = false
	else:
		collision_layer = 4 # Layer 3 (monster)
		collision_mask = 7  # World | Player | Monster
		if shadow_mesh != null and mode != GameTypes.GhostMode.PAINTING_BOUND:
			shadow_mesh.visible = true

func set_target_player(player: Node3D) -> void:
	_target_player = player

func get_ghost_state() -> GhostState:
	var state = GhostState.new()
	state.room_id = current_room
	state.position = global_position
	state.mode = mode
	state.current_painting_id = current_painting_id
	state.target_painting_id = target_painting_id
	state.is_chasing = is_chasing
	return state

func force_enter_nearest_painting(paintings_in_room: Array) -> bool:
	if paintings_in_room.is_empty():
		return false
	for p in paintings_in_room:
		if p.is_active and not p.is_covered and not p.is_occupied:
			var occupied: bool = false
			_resolve_dependencies()
			if _portrait_system != null:
				occupied = _portrait_system.set_monster_occupied(p.id, true)
			else:
				p.is_occupied = true
				occupied = true
			if not occupied:
				continue
			_exit_position = global_position
			current_painting_id = p.id
			mode = GameTypes.GhostMode.PAINTING_BOUND
			is_chasing = false
			if p is PortraitPainting:
				_bound_painting_node = p as PortraitPainting
			global_position = p.global_position
			if shadow_mesh != null:
				shadow_mesh.visible = false
			ghost_entered_painting.emit(p.id)
			return true
	return false

func can_exit_house(family_portrait_id: StringName) -> bool:
	return mode == GameTypes.GhostMode.PAINTING_BOUND and current_painting_id == family_portrait_id

func _check_light_reaction() -> bool:
	if _electrical_system == null or not _electrical_system.is_room_lit(current_room):
		return false
	if _portrait_system != null:
		var valid_paintings: Array[PaintingData] = _portrait_system.get_valid_entry_paintings(current_room)
		if not valid_paintings.is_empty():
			force_enter_nearest_painting(valid_paintings)
	return true

var _roam_waypoint: Vector3 = Vector3.ZERO
var _has_roam_waypoint: bool = false
var _roam_sound_timer: float = 3.0
var _trapped_timer: float = 0.0
var _blocked_flicker_timer: float = 0.0

func _get_dark_adjacent_rooms() -> Array[int]:
	var dark_neighbors: Array[int] = []
	var neighbors: Array = ADJACENT_ROOMS.get(current_room, [])
	for room in neighbors:
		if _electrical_system == null or not _electrical_system.is_room_lit(room):
			dark_neighbors.append(room)
	return dark_neighbors

func _find_all_unlit_rooms() -> Array[int]:
	var unlit: Array[int] = []
	for room in [GameTypes.RoomId.ENTRY_HALL, GameTypes.RoomId.PARLOR, GameTypes.RoomId.STUDY, GameTypes.RoomId.DINING_ROOM, GameTypes.RoomId.BASEMENT]:
		if room != current_room:
			if _electrical_system == null or not _electrical_system.is_room_lit(room):
				unlit.append(room)
	return unlit

func shadow_teleport(dest_room: GameTypes.RoomId, target_pos: Vector3) -> void:
	var from_room: GameTypes.RoomId = current_room
	current_room = dest_room
	global_position = target_pos
	_roam_waypoint = target_pos
	_has_roam_waypoint = true
	_trapped_timer = 0.0
	_blocked_flicker_timer = 0.0
	ghost_moved.emit(from_room, dest_room, mode)
	ghost_teleported.emit(dest_room)

func _process_trapped_and_sabotage(delta: float) -> void:
	if _dormant or mode == GameTypes.GhostMode.PAINTING_BOUND:
		_trapped_timer = 0.0
		_blocked_flicker_timer = 0.0
		return

	_resolve_dependencies()
	var dark_neighbors: Array[int] = _get_dark_adjacent_rooms()

	if dark_neighbors.is_empty():
		_trapped_timer += delta
		_blocked_flicker_timer += delta

		if _blocked_flicker_timer >= 10.0:
			_blocked_flicker_timer = 0.0
			var neighbors: Array = ADJACENT_ROOMS.get(current_room, [])
			if not neighbors.is_empty() and _electrical_system != null:
				var target_flicker_room = neighbors[0]
				_electrical_system.trigger_flicker(target_flicker_room, 2.5)

		if _trapped_timer >= 15.0:
			var unlit_rooms: Array[int] = _find_all_unlit_rooms()
			if not unlit_rooms.is_empty():
				var dest_room: GameTypes.RoomId = unlit_rooms[randi() % unlit_rooms.size()] as GameTypes.RoomId
				var points: Array = ROOM_WAYPOINTS.get(dest_room, [])
				var dest_pos: Vector3 = points[randi() % points.size()] if not points.is_empty() else global_position
				shadow_teleport(dest_room, dest_pos)
			else:
				_trapped_timer = 0.0
	else:
		_trapped_timer = 0.0
		_blocked_flicker_timer = 0.0

func _has_line_of_sight_to_player() -> bool:
	if _target_player == null or not is_instance_valid(_target_player):
		return false
	var space_state := get_world_3d().direct_space_state
	if space_state == null:
		return true
	var query := PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1.0, 0),
		_target_player.global_position + Vector3(0, 1.0, 0),
		1 # Layer 1 (world geometry)
	)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	return result.is_empty()

func _should_chase_player() -> bool:
	if _target_player == null or not is_instance_valid(_target_player):
		return false

	var player_room: GameTypes.RoomId = GameTypes.RoomId.ENTRY_HALL
	if _target_player is PlayerController:
		player_room = (_target_player as PlayerController).current_room
	elif _target_player.has_method("get_current_room"):
		player_room = _target_player.call("get_current_room")
	elif "current_room" in _target_player:
		player_room = _target_player.current_room

	if _electrical_system != null and _electrical_system.is_room_lit(player_room):
		return false

	if _target_player.global_position.z > exterior_threshold_z:
		return true

	if current_room == player_room:
		return true

	var dist: float = global_position.distance_to(_target_player.global_position)
	if dist <= 5.0 and _has_line_of_sight_to_player():
		return true

	return false

func _pick_next_roam_waypoint() -> void:
	var dark_neighbors: Array[int] = []
	var neighbors: Array = ADJACENT_ROOMS.get(current_room, [])
	for room in neighbors:
		if _electrical_system == null or not _electrical_system.is_room_lit(room):
			dark_neighbors.append(room)

	var target_room: int = current_room
	var is_current_dark: bool = (_electrical_system == null or not _electrical_system.is_room_lit(current_room))
	if not is_current_dark and not dark_neighbors.is_empty():
		target_room = dark_neighbors[randi() % dark_neighbors.size()]
	elif is_current_dark and not dark_neighbors.is_empty() and randf() < 0.4:
		target_room = dark_neighbors[randi() % dark_neighbors.size()]

	var points: Array = ROOM_WAYPOINTS.get(target_room, [])
	if not points.is_empty():
		_roam_waypoint = points[randi() % points.size()]
		_has_roam_waypoint = true
	else:
		_roam_waypoint = global_position
		_has_roam_waypoint = false

func _process_roam(delta: float) -> void:
	if is_chasing:
		is_chasing = false
		set_eyes_flaring(false)
		ghost_chase_ended.emit()
	mode = GameTypes.GhostMode.FREE_ROAM

	_roam_sound_timer -= delta
	if _roam_sound_timer <= 0.0:
		_roam_sound_timer = randf_range(3.5, 5.5)
		ghost_roam_sound_requested.emit()

	if not _has_roam_waypoint or global_position.distance_to(_roam_waypoint) <= 0.8:
		_pick_next_roam_waypoint()

	var dir: Vector3 = (_roam_waypoint - global_position).normalized()
	dir.y = 0
	velocity.x = dir.x * roam_speed
	velocity.z = dir.z * roam_speed
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

	if global_position.z > exterior_threshold_z:
		global_position.z = exterior_threshold_z - 0.05
		velocity.z = 0.0

func _process_roam_or_chase(delta: float) -> void:
	_resolve_target_player()
	if not _should_chase_player():
		_process_roam(delta)
		return

	if not is_chasing:
		is_chasing = true
		set_eyes_flaring(true)
		ghost_chase_started.emit()
	mode = GameTypes.GhostMode.CHASE

	var target_position: Vector3 = _target_player.global_position
	var dir: Vector3 = (target_position - global_position).normalized()
	dir.y = 0
	velocity.x = dir.x * chase_speed
	velocity.z = dir.z * chase_speed
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

	if target_position.z > exterior_threshold_z and global_position.z > exterior_threshold_z:
		global_position.z = exterior_threshold_z - 0.05
		velocity.z = 0.0
	if global_position.distance_to(_target_player.global_position) <= attack_distance:
		if _try_enter_carried_family_portrait():
			return
		_kill_target_player()

func _resolve_dependencies() -> void:
	var parent: Node = get_parent()
	if parent == null:
		return
	if _electrical_system == null or not is_instance_valid(_electrical_system):
		var electrical: Node = parent.get_node_or_null("ElectricalSystem")
		if electrical is ElectricalSystem:
			_electrical_system = electrical
	if _portrait_system == null or not is_instance_valid(_portrait_system):
		var portraits: Node = parent.get_node_or_null("PortraitSystem")
		if portraits is PortraitSystem:
			_portrait_system = portraits

func _resolve_target_player() -> void:
	if _target_player != null and is_instance_valid(_target_player):
		return
	if get_tree() != null:
		var player: Node = get_tree().get_first_node_in_group("player")
		if player is Node3D:
			_target_player = player

func _should_remain_in_painting() -> bool:
	if current_painting_id == &"":
		return false
	if _portrait_system != null:
		var data: PaintingData = _portrait_system.get_painting_data(current_painting_id)
		if data != null and data.is_family_portrait and data.is_being_carried:
			return true
	return _electrical_system != null and _electrical_system.is_room_lit(current_room)

func _exit_current_painting() -> void:
	var exited_id: StringName = current_painting_id
	if exited_id == &"":
		return
	if _portrait_system != null:
		_portrait_system.set_monster_occupied(exited_id, false)
	current_painting_id = &""
	_bound_painting_node = null
	mode = GameTypes.GhostMode.FREE_ROAM
	global_position = _exit_position
	if shadow_mesh != null:
		shadow_mesh.visible = true
	ghost_exited_painting.emit(exited_id)

func _try_enter_carried_family_portrait() -> bool:
	if _portrait_system == null or not _portrait_system.is_family_portrait_held():
		return false
	var family: PaintingData = _portrait_system.get_family_portrait_data()
	if family == null or family.is_covered or not family.is_active or family.is_occupied:
		return false
	return force_enter_nearest_painting([family])

func _kill_target_player() -> void:
	if _has_killed_target or _target_player == null:
		return
	_has_killed_target = true
	velocity = Vector3.ZERO
	if _target_player.has_method("kill_player"):
		_target_player.call("kill_player")
	player_killed.emit()

func _mcp_state() -> Dictionary:
	return {
		"room_id": current_room,
		"mode": mode,
		"painting_id": current_painting_id,
		"is_chasing": is_chasing,
		"dormant": _dormant,
	}
