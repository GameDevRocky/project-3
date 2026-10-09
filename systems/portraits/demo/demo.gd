extends Node3D
## Test-only first-person controller and room builder. No player/game code dependency.

const PAINTING_SCENE: PackedScene = preload("res://systems/portraits/demo/portrait_painting_demo.tscn")

@onready var _player: CharacterBody3D = $TestPlayer
@onready var _camera: Camera3D = $TestPlayer/Camera3D
@onready var _carry_socket: Node3D = $TestPlayer/Camera3D/CarrySocket
@onready var _system: PortraitSystem = $PortraitSystem
@onready var _status: RichTextLabel = $HUD/Status

var _mouse_captured: bool = false
var _boxes_loaded: bool = false
var _ghost_id: StringName = &""
var _last_action_result: String = "Ready. Aim at a painting to begin."
var _paintings: Array[PortraitPainting] = []

func _ready() -> void:
	_build_room()
	_register_existing()
	_update_hud()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_mouse_captured = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and _mouse_captured:
		_player.rotate_y(-event.relative.x * 0.0025)
		_camera.rotate_x(-event.relative.y * 0.0025)
		_camera.rotation.x = clampf(_camera.rotation.x, -1.3, 1.3)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_mouse_captured = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_E:
			_interact()
		elif event.keycode == KEY_C:
			_toggle_cover()
		elif event.keycode == KEY_X:
			_toggle_active()
		elif event.keycode == KEY_G:
			_enter_ghost()
		elif event.keycode == KEY_T:
			_enter_target_ghost()
		elif event.keycode == KEY_H:
			_exit_ghost()
		elif event.keycode == KEY_B:
			_boxes_loaded = not _boxes_loaded
			_update_hud()
		elif event.keycode == KEY_Q:
			_drop_family_portrait()

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1.0
	var direction: Vector3 = (_player.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	_player.velocity.x = direction.x * 3.2
	_player.velocity.z = direction.z * 3.2
	_player.move_and_slide()

func _build_room() -> void:
	_make_box("Old Oak Floor", Vector3(12.0, 0.25, 10.0), Vector3(0, -0.18, 0), Color(0.25, 0.18, 0.12))
	_make_box("Back Wall", Vector3(12.0, 4.2, 0.25), Vector3(0, 1.9, -5.0), Color(0.36, 0.30, 0.23))
	_make_box("Left Wall", Vector3(0.25, 4.2, 10.0), Vector3(-6.0, 1.9, 0), Color(0.34, 0.28, 0.21))
	_make_box("Right Wall", Vector3(0.25, 4.2, 10.0), Vector3(6.0, 1.9, 0), Color(0.32, 0.27, 0.21))
	_make_box("Ceiling", Vector3(12.0, 0.2, 10.0), Vector3(0, 4.0, 0), Color(0.43, 0.38, 0.29))
	_make_box("Entry Door", Vector3(1.35, 2.75, 0.10), Vector3(-5.1, 1.35, -4.82), Color(0.16, 0.095, 0.055))
	_make_box("Door Header", Vector3(1.62, 0.16, 0.18), Vector3(-5.1, 2.82, -4.73), Color(0.29, 0.19, 0.095))
	_make_box("Door Left Casing", Vector3(0.14, 2.72, 0.18), Vector3(-5.85, 1.35, -4.73), Color(0.29, 0.19, 0.095))
	_make_box("Door Right Casing", Vector3(0.14, 2.72, 0.18), Vector3(-4.35, 1.35, -4.73), Color(0.29, 0.19, 0.095))
	_make_box("Sideboard", Vector3(2.2, 0.9, 0.65), Vector3(-3.9, 0.45, -3.75), Color(0.20, 0.12, 0.07))
	_make_box("Settee", Vector3(2.2, 0.8, 0.9), Vector3(3.6, 0.4, 2.4), Color(0.25, 0.18, 0.16))
	var light := OmniLight3D.new()
	light.name = "Warm Inspection Light"
	light.position = Vector3(0, 3.4, 0)
	light.light_color = Color(1.0, 0.77, 0.52)
	light.light_energy = 1.25
	light.omni_range = 12.0
	add_child(light)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.055, 0.047, 0.04)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.42, 0.38, 0.32)
	env.ambient_light_energy = 0.55
	environment.environment = env
	add_child(environment)
	_add_painting(&"family_portrait", 0, true, Vector3(-3.5, 2.35, -4.82), Vector2(1.22, 1.58), 0.0)
	_add_painting(&"parlor_landscape", 1, false, Vector3(0.0, 2.35, -4.82), Vector2(0.92, 1.15), 0.0)
	_add_painting(&"covered_portrait", 1, false, Vector3(3.7, 2.25, -4.82), Vector2(0.82, 1.08), 0.0, true)
	_add_painting(&"inactive_portrait", 2, false, Vector3(-5.82, 2.25, -1.8), Vector2(0.75, 0.98), -PI * 0.5, false, false)
	_add_painting(&"hall_landscape", 0, false, Vector3(-5.82, 2.25, 1.0), Vector2(0.8, 1.02), -PI * 0.5)
	_add_painting(&"study_portrait", 2, false, Vector3(5.82, 2.25, -1.0), Vector2(0.78, 1.0), PI * 0.5)

func _register_existing() -> void:
	for child: Node in get_children():
		if child is PortraitPainting:
			var painting := child as PortraitPainting
			_paintings.append(painting)
			_system.register_painting(painting)

func _add_painting(id: StringName, room: int, family: bool, location: Vector3, size: Vector2, yaw: float, covered: bool = false, active: bool = true) -> void:
	var painting := PAINTING_SCENE.instantiate() as PortraitPainting
	painting.name = String(id)
	painting.portrait_id = id
	painting.room_id = room
	painting.is_family_portrait = family
	painting.is_covered = covered
	painting.is_active = active
	painting.painting_size = size
	painting.position = location
	painting.rotation.y = yaw
	if family:
		painting.frame_color = Color(0.32, 0.20, 0.085)
		painting.portrait_tint = Color(1.0, 0.9, 0.73)
	add_child(painting)

func _interact() -> void:
	var target: PortraitPainting = _find_target()
	if target == null:
		return
	if target.is_family_portrait and target.is_being_carried:
		_drop_family_portrait()
	elif target.is_family_portrait:
		_system.remove_family_portrait(_boxes_loaded, _carry_socket)
	else:
		target.interact(true, _boxes_loaded, _carry_socket)
	_update_hud()

func _toggle_active() -> void:
	var target: PortraitPainting = _find_target()
	if target != null and not target.is_occupied:
		target.set_active(not target.is_active)
	_update_hud()

func _toggle_cover() -> void:
	var target: PortraitPainting = _find_target()
	if target != null:
		target.set_covered(not target.is_covered)
	_update_hud()

func _enter_ghost() -> void:
	if _ghost_id != &"":
		return
	var target: PortraitPainting = _system.find_nearest_valid_entry_painting(1, _player.global_position)
	if target == null:
		var valid: Array[PaintingData] = _system.get_valid_entry_paintings(0)
		if not valid.is_empty():
			for painting: PortraitPainting in _paintings:
				if painting.portrait_id == valid[0].id:
					target = painting
					break
	if target != null and _system.set_monster_occupied(target.portrait_id, true):
		_ghost_id = target.portrait_id
		_last_action_result = "Ghost entered %s." % target.portrait_id
	else:
		_last_action_result = "No eligible painting found in the demo rooms."
	_update_hud()

func _enter_target_ghost() -> void:
	var target: PortraitPainting = _find_target()
	if target == null:
		_last_action_result = "Aim at a painting first."
	elif _system.enter_painting(target.portrait_id):
		_ghost_id = target.portrait_id
		_last_action_result = "Ghost entered %s." % target.portrait_id
	else:
		_last_action_result = "Entry rejected: painting is covered, inactive, occupied, or invalid."
	_update_hud()

func _exit_ghost() -> void:
	if _ghost_id != &"":
		_system.set_monster_occupied(_ghost_id, false)
		_last_action_result = "Ghost left %s." % _ghost_id
		_ghost_id = &""
	_update_hud()

func _drop_family_portrait() -> void:
	var portrait: PaintingData = _system.get_family_portrait_data()
	if portrait == null or not portrait.is_being_carried:
		return
	var drop_transform: Transform3D = Transform3D(Basis(Vector3.UP, _player.rotation.y), _player.global_position + Vector3(0.0, 1.6, 0.0) - _player.global_basis.z * 0.8)
	_system.drop_family_portrait(0, drop_transform, self)
	_update_hud()

func _find_target() -> PortraitPainting:
	var origin: Vector3 = _camera.global_position
	var forward: Vector3 = -_camera.global_basis.z
	var nearest: PortraitPainting = null
	var nearest_distance: float = 2.7
	for painting: PortraitPainting in _paintings:
		if not is_instance_valid(painting):
			continue
		var offset: Vector3 = painting.global_position - origin
		var distance: float = offset.length()
		if distance <= nearest_distance and forward.dot(offset.normalized()) > 0.82:
			nearest = painting
			nearest_distance = distance
	return nearest

func _make_box(label: String, size: Vector3, location: Vector3, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	mesh_instance.material_override = material
	mesh_instance.position = location
	add_child(mesh_instance)

func _update_hud() -> void:
	if _status == null:
		return
	var lines: String = "[center][b]THE LAST PORTRAIT — SYSTEM TEST ROOM[/b][/center]\n"
	lines += "WASD move · Mouse look · Click to capture mouse · Esc release\n"
	lines += "Aim at a frame: E pick up / drop or cover ordinary frame · C cover / uncover any frame · X activate / deactivate\n"
	lines += "G ghost enters nearest valid · T attempts focused frame · H ghost exits · B boxes loaded · Q drop portrait\n"
	lines += "[i]%s[/i]\n\n" % _last_action_result
	lines += "Boxes loaded: %s · Occupied frame: %s\n" % ["YES" if _boxes_loaded else "NO", String(_ghost_id) if _ghost_id != &"" else "none"]
	lines += "Family portrait carried: %s · Safe to remove: %s\n\n" % ["YES" if _system.is_family_portrait_held() else "NO", "YES" if _system.is_family_portrait_safe_to_remove() else "NO"]
	for painting: PortraitPainting in _paintings:
		if is_instance_valid(painting):
			lines += "%s · Room %d · %s · %s · %s\n" % [String(painting.portrait_id), painting.room_id, "covered" if painting.is_covered else "uncovered", "inactive" if not painting.is_active else "active", "GHOST INSIDE" if painting.is_occupied else "empty"]
	_status.text = lines
