class_name PlayerController
extends CharacterBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")
const PlayerState = preload("res://systems/shared/player_state.gd")

signal player_died()
signal item_packed(item_type: GameTypes.CarriedItemType)
signal carried_item_changed(item_type: GameTypes.CarriedItemType)
signal interaction_performed()

@export var walk_speed: float = 3.5
@export var sprint_speed: float = 5.5
@export var mouse_sensitivity: float = 0.003
@export var max_stamina: float = 3.0
@export var stamina_recovery_rate: float = 1.35

@onready var camera: Camera3D = get_node_or_null("Camera3D")
@onready var interaction_ray: RayCast3D = get_node_or_null("Camera3D/InteractionRay")
@onready var carry_socket: Node3D = get_node_or_null("Camera3D/CarrySocket")
@onready var dark_adaptation_light: OmniLight3D = get_node_or_null("Camera3D/DarkAdaptationLight")

var current_room: GameTypes.RoomId = GameTypes.RoomId.EXTERIOR_DRIVEWAY
var carried_item: GameTypes.CarriedItemType = GameTypes.CarriedItemType.NONE
var is_alive: bool = true
var boxes_packed_count: int = 0
var stamina: float = max_stamina
var carried_node: Node3D = null
var current_interaction_prompt: String = ""
var _electrical_system: ElectricalSystem = null

func _ready() -> void:
	_ensure_runtime_nodes()
	add_to_group("player")
	add_to_group("mcp_watch")
	collision_layer = 2 # Layer 2 (player)
	collision_mask = 1 | 4 # Layer 1 (world) | Layer 3 (monster)
	floor_snap_length = 0.4
	floor_constant_speed = true
	floor_max_angle = deg_to_rad(50.0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if not is_alive:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_apply_look((event as InputEventMouseMotion).relative)

	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event.is_action_pressed("interact"):
		try_interact()

func _apply_look(mouse_delta: Vector2) -> void:
	rotate_y(-mouse_delta.x * mouse_sensitivity)
	if camera == null:
		return
	var pitch_limit: float = PI / 2.2
	camera.rotation.x = clampf(
		camera.rotation.x - mouse_delta.y * mouse_sensitivity,
		-pitch_limit,
		pitch_limit,
	)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var wants_sprint: bool = Input.is_action_pressed("sprint") and not input_dir.is_zero_approx() and stamina > 0.0
	var spd: float = sprint_speed if wants_sprint else walk_speed
	if wants_sprint:
		stamina = maxf(0.0, stamina - delta)
	else:
		stamina = minf(max_stamina, stamina + stamina_recovery_rate * delta)

	if direction:
		velocity.x = direction.x * spd
		velocity.z = direction.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd)
		velocity.z = move_toward(velocity.z, 0, spd)

	move_and_slide()
	_update_dark_adaptation()
	_update_interaction_prompt()

func get_player_state() -> PlayerState:
	var state = PlayerState.new()
	state.room_id = current_room
	state.position = global_position
	state.carried_item = carried_item
	state.is_alive = is_alive
	state.boxes_packed_count = boxes_packed_count
	return state

func try_interact() -> void:
	if interaction_ray != null and interaction_ray.is_colliding():
		var collider: Object = interaction_ray.get_collider()
		if collider != null:
			if collider.has_method("interact"):
				collider.interact(self)
			elif collider is Node and (collider as Node).get_parent() != null and (collider as Node).get_parent().has_method("interact"):
				(collider as Node).get_parent().interact(self)
			interaction_performed.emit()

func kill_player() -> void:
	if not is_alive:
		return
	is_alive = false
	velocity = Vector3.ZERO
	player_died.emit()

func try_pick_up_item(item: Node3D, item_type: GameTypes.CarriedItemType) -> bool:
	if item == null or not is_instance_valid(item) or carried_item != GameTypes.CarriedItemType.NONE:
		return false
	if item_type == GameTypes.CarriedItemType.NONE or item_type == GameTypes.CarriedItemType.FAMILY_PORTRAIT:
		return false
	carried_item = item_type
	carried_node = item
	_attach_carried_node(item)
	carried_item_changed.emit(carried_item)
	return true

func interact_with_portrait(painting: PortraitPainting) -> bool:
	if painting == null or not is_instance_valid(painting):
		return false
	if painting.is_covered:
		if carried_item != GameTypes.CarriedItemType.NONE:
			return false
		if not painting.set_covered(false):
			return false
		carried_item = GameTypes.CarriedItemType.DUST_SHEET
		carried_node = _create_sheet_visual()
		carried_item_changed.emit(carried_item)
		return true
	if carried_item == GameTypes.CarriedItemType.DUST_SHEET:
		if not painting.set_covered(true):
			return false
		_clear_carried_node()
		_set_carried_item(GameTypes.CarriedItemType.NONE)
		return true
	if not painting.is_family_portrait or carried_item != GameTypes.CarriedItemType.NONE:
		return false
	if boxes_packed_count < 4 or carry_socket == null:
		return false
	if not painting.remove_from_wall(carry_socket):
		return false
	carried_node = painting
	_set_carried_item(GameTypes.CarriedItemType.FAMILY_PORTRAIT)
	return true

func deposit_box_in_car() -> bool:
	if carried_item >= GameTypes.CarriedItemType.BOX_LIVING_ROOM and carried_item <= GameTypes.CarriedItemType.BOX_BASEMENT:
		var packed_type: GameTypes.CarriedItemType = carried_item
		_clear_carried_node()
		_set_carried_item(GameTypes.CarriedItemType.NONE)
		boxes_packed_count += 1
		item_packed.emit(packed_type)
		return true
	return false

func deposit_family_portrait(deposit_parent: Node = null) -> bool:
	if carried_item != GameTypes.CarriedItemType.FAMILY_PORTRAIT:
		return false
	if carried_node == null or not is_instance_valid(carried_node) or not carried_node is PortraitPainting:
		return false
	var portrait := carried_node as PortraitPainting
	var world_parent: Node = deposit_parent
	if world_parent == null:
		world_parent = get_parent()
	if world_parent == null and get_tree() != null:
		world_parent = get_tree().current_scene
	if world_parent == null:
		return false
	var deposit_transform: Transform3D = global_transform
	if world_parent is Node3D:
		deposit_transform = (world_parent as Node3D).global_transform
		deposit_transform.origin += Vector3.UP * 0.9
	if not portrait.drop_at(deposit_transform, world_parent):
		return false
	carried_node = null
	_set_carried_item(GameTypes.CarriedItemType.NONE)
	return true

func is_carried_family_portrait_occupied() -> bool:
	return carried_item == GameTypes.CarriedItemType.FAMILY_PORTRAIT and is_instance_valid(carried_node) and carried_node is PortraitPainting and (carried_node as PortraitPainting).is_occupied

func drop_carried_item() -> bool:
	if carried_item == GameTypes.CarriedItemType.NONE:
		return false
	if carried_node != null and is_instance_valid(carried_node):
		var world_parent: Node = get_tree().current_scene if get_tree() != null else get_parent()
		if carried_node is PortraitPainting:
			var drop_transform := Transform3D(Basis.IDENTITY, global_position - global_basis.z * 1.2 + Vector3.UP)
			(carried_node as PortraitPainting).drop_at(drop_transform, world_parent)
		else:
			carried_node.reparent(world_parent, true)
			carried_node.global_position = global_position - global_basis.z * 1.2 + Vector3.UP * 0.4
			_restore_collision(carried_node)
	carried_node = null
	_set_carried_item(GameTypes.CarriedItemType.NONE)
	return true

func is_carrying_box() -> bool:
	return carried_item >= GameTypes.CarriedItemType.BOX_LIVING_ROOM and carried_item <= GameTypes.CarriedItemType.BOX_BASEMENT

func get_carried_item() -> GameTypes.CarriedItemType:
	return carried_item

func get_interaction_prompt() -> String:
	return current_interaction_prompt

func get_stamina_ratio() -> float:
	return stamina / max_stamina if max_stamina > 0.0 else 0.0

func _ensure_runtime_nodes() -> void:
	if camera == null:
		camera = get_node_or_null("Camera3D") as Camera3D
	if camera == null:
		return
	if carry_socket == null:
		carry_socket = camera.get_node_or_null("CarrySocket") as Node3D
	if carry_socket == null:
		carry_socket = Marker3D.new()
		carry_socket.name = "CarrySocket"
		camera.add_child(carry_socket)
		carry_socket.position = Vector3(0.55, -0.45, -1.15)
	if dark_adaptation_light == null:
		dark_adaptation_light = camera.get_node_or_null("DarkAdaptationLight") as OmniLight3D
	if dark_adaptation_light == null:
		dark_adaptation_light = OmniLight3D.new()
		dark_adaptation_light.name = "DarkAdaptationLight"
		camera.add_child(dark_adaptation_light)
		dark_adaptation_light.position = Vector3(0.0, -0.15, -0.4)
		dark_adaptation_light.light_color = Color(0.32, 0.42, 0.58)
		dark_adaptation_light.light_energy = 0.32
		dark_adaptation_light.omni_range = 3.2
		dark_adaptation_light.shadow_enabled = false

func _attach_carried_node(item: Node3D) -> void:
	if item is CollisionObject3D:
		item.set_meta("carry_collision_layer", (item as CollisionObject3D).collision_layer)
		item.set_meta("carry_collision_mask", (item as CollisionObject3D).collision_mask)
		(item as CollisionObject3D).collision_layer = 0
		(item as CollisionObject3D).collision_mask = 0
	if carry_socket != null:
		item.reparent(carry_socket, true)
		item.transform = Transform3D.IDENTITY
	if item.has_method("on_picked_up"):
		item.call("on_picked_up", self)

func _restore_collision(item: Node3D) -> void:
	if item is CollisionObject3D:
		(item as CollisionObject3D).collision_layer = int(item.get_meta("carry_collision_layer", 1))
		(item as CollisionObject3D).collision_mask = int(item.get_meta("carry_collision_mask", 0))
	if item.has_method("on_dropped"):
		item.call("on_dropped")

func _clear_carried_node() -> void:
	if carried_node != null and is_instance_valid(carried_node):
		carried_node.queue_free()
	carried_node = null

func _set_carried_item(item_type: GameTypes.CarriedItemType) -> void:
	carried_item = item_type
	carried_item_changed.emit(carried_item)

func _create_sheet_visual() -> Node3D:
	if carry_socket == null:
		return null
	var visual := MeshInstance3D.new()
	visual.name = "CarriedDustSheet"
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.75, 0.75)
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.82, 0.79, 0.7)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	visual.material_override = material
	carry_socket.add_child(visual)
	visual.rotation = Vector3(-0.25, 0.0, 0.0)
	return visual

func _resolve_electrical_system() -> ElectricalSystem:
	if _electrical_system != null and is_instance_valid(_electrical_system):
		return _electrical_system
	if get_tree() != null:
		var candidate: Node = get_tree().get_first_node_in_group("electrical_system")
		if candidate is ElectricalSystem:
			_electrical_system = candidate
	return _electrical_system

func _update_dark_adaptation() -> void:
	if dark_adaptation_light == null:
		return
	var electrical: ElectricalSystem = _resolve_electrical_system()
	dark_adaptation_light.visible = electrical == null or not electrical.is_room_lit(current_room)

func _update_interaction_prompt() -> void:
	current_interaction_prompt = ""
	if interaction_ray == null or not interaction_ray.is_colliding():
		return
	var collider: Object = interaction_ray.get_collider()
	if collider != null and collider.has_method("get_interaction_prompt"):
		current_interaction_prompt = str(collider.call("get_interaction_prompt", self))
	elif collider is Node and (collider as Node).get_parent() != null and (collider as Node).get_parent().has_method("get_interaction_prompt"):
		current_interaction_prompt = str((collider as Node).get_parent().call("get_interaction_prompt", self))

func _mcp_state() -> Dictionary:
	return {
		"room_id": current_room,
		"carried_item": carried_item,
		"boxes_packed": boxes_packed_count,
		"alive": is_alive,
		"stamina": stamina,
		"prompt": current_interaction_prompt,
	}
