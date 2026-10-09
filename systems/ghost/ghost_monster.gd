class_name GhostMonster
extends CharacterBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")
const GhostState = preload("res://systems/shared/ghost_state.gd")

signal ghost_moved(from_room: GameTypes.RoomId, to_room: GameTypes.RoomId, mode: GameTypes.GhostMode)
signal ghost_entered_painting(painting_id: StringName)
signal ghost_exited_painting(painting_id: StringName)
signal ghost_chase_started()
signal ghost_chase_ended()
signal player_killed()

@export var roam_speed: float = 4.5
@export var chase_speed: float = 5.8
@export var current_room: GameTypes.RoomId = GameTypes.RoomId.BASEMENT

var mode: GameTypes.GhostMode = GameTypes.GhostMode.DORMANT
var current_painting_id: StringName = &""
var target_painting_id: StringName = &""
var is_chasing: bool = false
var _dormant: bool = true

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var shadow_mesh: MeshInstance3D = $ShadowMesh

func _ready() -> void:
	collision_layer = 4 # Layer 3 (monster)
	collision_mask = 1  # Layer 1 (world) | Layer 2 (player)

func _physics_process(delta: float) -> void:
	if _dormant:
		mode = GameTypes.GhostMode.DORMANT
		return

	# Query electrical system for current room light state if available in tree
	_check_light_reaction()

	match mode:
		GameTypes.GhostMode.FREE_ROAM, GameTypes.GhostMode.CHASE:
			_process_roam_or_chase(delta)
		GameTypes.GhostMode.PAINTING_BOUND:
			velocity = Vector3.ZERO
			move_and_slide()

func set_monster_dormant(dormant: bool) -> void:
	_dormant = dormant
	if dormant:
		mode = GameTypes.GhostMode.DORMANT
	else:
		mode = GameTypes.GhostMode.FREE_ROAM

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
	# Find first available uncovered painting
	for p in paintings_in_room:
		if p.is_active and not p.is_covered and not p.is_occupied:
			current_painting_id = p.portrait_id
			p.is_occupied = true
			mode = GameTypes.GhostMode.PAINTING_BOUND
			shadow_mesh.visible = false
			ghost_entered_painting.emit(p.portrait_id)
			return true
	return false

func can_exit_house(family_portrait_id: StringName) -> bool:
	return mode == GameTypes.GhostMode.PAINTING_BOUND and current_painting_id == family_portrait_id

func _check_light_reaction() -> void:
	var parent = get_parent()
	if parent == null:
		return
	var electrical = parent.get_node_or_null("ElectricalSystem")
	if electrical != null and electrical.has_method("is_room_lit"):
		if electrical.is_room_lit(current_room) and mode != GameTypes.GhostMode.PAINTING_BOUND:
			var portraits = parent.get_node_or_null("PortraitSystem")
			var valid_paintings = []
			if portraits != null and portraits.has_method("get_valid_entry_paintings"):
				valid_paintings = portraits.get_valid_entry_paintings(current_room)
			if not valid_paintings.is_empty():
				force_enter_nearest_painting(valid_paintings)

func _process_roam_or_chase(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	dir.y = 0
	var spd = chase_speed if is_chasing else roam_speed
	velocity = dir * spd
	move_and_slide()

	# Check collision with player
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider != null and collider.is_in_group("player"):
			player_killed.emit()
