class_name PlayerController
extends CharacterBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")
const PlayerState = preload("res://systems/shared/player_state.gd")

@export var walk_speed: float = 3.5
@export var sprint_speed: float = 5.8
@export var mouse_sensitivity: float = 0.003

@onready var camera: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay

var current_room: GameTypes.RoomId = GameTypes.RoomId.EXTERIOR_DRIVEWAY
var carried_item: GameTypes.CarriedItemType = GameTypes.CarriedItemType.NONE
var is_alive: bool = true
var boxes_packed_count: int = 0

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2 # Layer 2 (player)
	collision_mask = 1 | 4 # Layer 1 (world) | Layer 3 (monster)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if not is_alive:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.clampf(-PI/2.2, PI/2.2)

	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("interact"):
		try_interact()

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var spd = sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	if direction:
		velocity.x = direction.x * spd
		velocity.z = direction.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd)
		velocity.z = move_toward(velocity.z, 0, spd)

	move_and_slide()

func get_player_state() -> PlayerState:
	var state = PlayerState.new()
	state.room_id = current_room
	state.position = global_position
	state.carried_item = carried_item
	state.is_alive = is_alive
	state.boxes_packed_count = boxes_packed_count
	return state

func try_interact() -> void:
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider != null:
			print("Interacted with: ", collider.name)

func kill_player() -> void:
	is_alive = bool(false)
	velocity = Vector3.ZERO
	print("Player killed!")

func deposit_box_in_car() -> bool:
	if carried_item >= GameTypes.CarriedItemType.BOX_LIVING_ROOM and carried_item <= GameTypes.CarriedItemType.BOX_BASEMENT:
		carried_item = GameTypes.CarriedItemType.NONE
		boxes_packed_count += 1
		return true
	return false

func is_carrying_box() -> bool:
	return carried_item >= GameTypes.CarriedItemType.BOX_LIVING_ROOM and carried_item <= GameTypes.CarriedItemType.BOX_BASEMENT

func get_carried_item() -> GameTypes.CarriedItemType:
	return carried_item
