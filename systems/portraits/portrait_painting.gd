class_name PortraitPainting
extends Node3D
## Reusable interactive painting. Canvas faces local +Z; hang it against a wall.

signal state_changed(data: PaintingData)
signal occupancy_changed(painting_id: StringName, has_monster: bool)

@export var portrait_id: StringName = &"portrait"
@export_range(0, 5) var room_id: int = 0
@export var is_family_portrait: bool = false
@export var is_covered: bool = false
@export var is_active: bool = true
@export var is_occupied: bool = false
@export var is_being_carried: bool = false
@export var painting_size: Vector2 = Vector2(0.85, 1.1)
@export var frame_color: Color = Color(0.29, 0.17, 0.075)
@export var portrait_tint: Color = Color(0.88, 0.82, 0.66)

var _canvas_material: ShaderMaterial
var _sheet: MeshInstance3D
var _data := PaintingData.new()
var _ghost_tween: Tween
var occupancy_guard: Callable

func _ready() -> void:
	add_to_group("portrait_paintings")
	_build_visuals()
	_refresh_state(false)

func get_data() -> PaintingData:
	_refresh_data()
	return _data

func is_eligible_for_ghost() -> bool:
	# The heirloom may be carried into the climax and still receive the ghost.
	return is_active and not is_covered and not is_occupied and (not is_being_carried or is_family_portrait)

func get_interaction_prompt(has_dust_sheet: bool = true, all_boxes_loaded: bool = false) -> String:
	if is_family_portrait:
		if is_being_carried:
			return "E — Drop family portrait"
		if is_covered:
			return "E — Remove dust-sheet"
		if has_dust_sheet:
			return "E — Drape dust-sheet"
		if not all_boxes_loaded:
			return "Load all four boxes first"
		return "E — Take family portrait"
	return "E — Remove dust-sheet" if is_covered else ("E — Drape dust-sheet" if has_dust_sheet else "Find a dust-sheet")

## Player adapter hook. Does not depend on or instantiate the Player System.
func interact(has_dust_sheet: bool, all_boxes_loaded: bool = false, carry_socket: Node3D = null) -> bool:
	if is_family_portrait:
		if is_being_carried:
			return false
		if is_covered:
			return set_covered(false)
		if has_dust_sheet:
			return set_covered(true)
		if not all_boxes_loaded:
			return false
		return remove_from_wall(carry_socket)
	if is_covered:
		return set_covered(false)
	if has_dust_sheet:
		return set_covered(true)
	return false

func set_covered(covered: bool) -> bool:
	if is_being_carried or is_covered == covered:
		return false
	is_covered = covered
	_refresh_state()
	return true

func set_active(active: bool) -> bool:
	if is_active == active:
		return false
	if not active and is_occupied:
		return false
	is_active = active
	_refresh_state()
	return true

func set_room_id(new_room_id: int) -> void:
	room_id = new_room_id
	_refresh_state()

func set_occupied(occupied: bool) -> bool:
	if is_occupied == occupied:
		return false
	if occupied and not is_eligible_for_ghost():
		return false
	if occupied and occupancy_guard.is_valid() and not occupancy_guard.call(portrait_id):
		return false
	is_occupied = occupied
	_refresh_state()
	_animate_ghost(occupied)
	occupancy_changed.emit(portrait_id, occupied)
	return true

func remove_from_wall(carry_socket: Node3D) -> bool:
	if not is_family_portrait or is_being_carried or carry_socket == null:
		return false
	var previous_parent: Node = get_parent()
	if previous_parent == null:
		return false
	previous_parent.remove_child(self)
	carry_socket.add_child(self)
	global_transform = carry_socket.global_transform
	is_being_carried = true
	_refresh_state()
	return true

func drop_at(world_transform: Transform3D, new_parent: Node) -> bool:
	if not is_family_portrait or not is_being_carried or new_parent == null:
		return false
	var old_parent: Node = get_parent()
	if old_parent == null:
		return false
	old_parent.remove_child(self)
	new_parent.add_child(self)
	global_transform = world_transform
	is_being_carried = false
	_refresh_state()
	return true

func is_safe_to_remove_from_house() -> bool:
	return is_family_portrait and not is_occupied

func _build_visuals() -> void:
	if get_child_count() > 0:
		return
	var w: float = painting_size.x
	var h: float = painting_size.y
	var border: float = 0.095 if is_family_portrait else 0.065
	_add_box("FrameBacking", Vector3(w + border * 2.0, h + border * 2.0, 0.09), Vector3(0, 0, -0.035), frame_color.darkened(0.35))
	_add_box("Canvas", Vector3(w, h, 0.018), Vector3(0, 0, 0.014), Color.WHITE)
	var gold: Color = Color(0.58, 0.39, 0.15) if is_family_portrait else Color(0.43, 0.31, 0.16)
	var trim: float = border * 0.3
	_add_box("FrameTop", Vector3(w + border * 2, border, 0.13), Vector3(0, h * 0.5 + border * 0.5, 0), gold)
	_add_box("FrameBottom", Vector3(w + border * 2, border, 0.13), Vector3(0, -h * 0.5 - border * 0.5, 0), gold)
	_add_box("FrameLeft", Vector3(border, h, 0.13), Vector3(-w * 0.5 - border * 0.5, 0, 0), frame_color)
	_add_box("FrameRight", Vector3(border, h, 0.13), Vector3(w * 0.5 + border * 0.5, 0, 0), frame_color)
	_add_box("InnerGoldTop", Vector3(w, trim, 0.15), Vector3(0, h * 0.5 - trim * 0.5, 0.012), gold.lightened(0.2))
	_add_box("InnerGoldBottom", Vector3(w, trim, 0.15), Vector3(0, -h * 0.5 + trim * 0.5, 0.012), gold.lightened(0.2))
	_add_box("InnerGoldLeft", Vector3(trim, h, 0.15), Vector3(-w * 0.5 + trim * 0.5, 0, 0.012), gold.lightened(0.2))
	_add_box("InnerGoldRight", Vector3(trim, h, 0.15), Vector3(w * 0.5 - trim * 0.5, 0, 0.012), gold.lightened(0.2))
	for x_sign: float in [-1.0, 1.0]:
		for y_sign: float in [-1.0, 1.0]:
			_add_rosette(Vector3(x_sign * (w * 0.5 + border * 0.5), y_sign * (h * 0.5 + border * 0.5), 0.085), gold)
	var canvas_shader_path: String = "res://systems/portraits/canvas_paint.gdshader"
	if not ResourceLoader.exists(canvas_shader_path):
		canvas_shader_path = "res://canvas_paint.gdshader"
	var shader: Shader = load(canvas_shader_path)
	_canvas_material = ShaderMaterial.new()
	_canvas_material.shader = shader
	_canvas_material.set_shader_parameter("base_tint", portrait_tint)
	_canvas_material.set_shader_parameter("family_style", is_family_portrait)
	_canvas_material.set_shader_parameter("ghost_amount", 1.0 if is_occupied else 0.0)
	var canvas_node: MeshInstance3D = get_node("Canvas")
	canvas_node.material_override = _canvas_material
	_sheet = MeshInstance3D.new()
	_sheet.name = "CoverSheet"
	var quad := QuadMesh.new()
	quad.size = Vector2(w + border * 1.25, h + border * 1.25)
	_sheet.mesh = quad
	_sheet.position = Vector3(0, 0, 0.1)
	var sheet_shader_path: String = "res://systems/portraits/cloth_sheet.gdshader"
	if not ResourceLoader.exists(sheet_shader_path):
		sheet_shader_path = "res://cloth_sheet.gdshader"
	var sheet_shader: Shader = load(sheet_shader_path)
	var sheet_material := ShaderMaterial.new()
	sheet_material.shader = sheet_shader
	_sheet.material_override = sheet_material
	add_child(_sheet)
	_sheet.visible = is_covered

func _add_box(node_name: String, size: Vector3, local_position: Vector3, color: Color) -> void:
	var item := MeshInstance3D.new()
	item.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	material.metallic = 0.38 if node_name.begins_with("InnerGold") or node_name.begins_with("FrameTop") or node_name.begins_with("FrameBottom") else 0.05
	item.material_override = material
	item.position = local_position
	add_child(item)

func _add_rosette(local_position: Vector3, color: Color) -> void:
	var rosette := MeshInstance3D.new()
	rosette.name = "BrassCornerRosette"
	var sphere := SphereMesh.new()
	sphere.radius = 0.043 if is_family_portrait else 0.032
	sphere.height = sphere.radius * 2.0
	rosette.mesh = sphere
	rosette.scale = Vector3(1.0, 1.0, 0.42)
	var material := StandardMaterial3D.new()
	material.albedo_color = color.lightened(0.15)
	material.roughness = 0.52
	material.metallic = 0.58
	rosette.material_override = material
	rosette.position = local_position
	add_child(rosette)

func _refresh_state(emit_change: bool = true) -> void:
	if _sheet != null:
		_sheet.visible = is_covered
	if _canvas_material != null:
		_canvas_material.set_shader_parameter("active_amount", 1.0 if is_active else 0.42)
	_refresh_data()
	if emit_change and is_inside_tree():
		state_changed.emit(_data)

func _animate_ghost(entering: bool) -> void:
	if _canvas_material == null:
		return
	if _ghost_tween != null and _ghost_tween.is_running():
		_ghost_tween.kill()
	_ghost_tween = create_tween()
	var target: float = 1.0 if entering else 0.0
	_ghost_tween.tween_method(_set_ghost_amount, float(_canvas_material.get_shader_parameter("ghost_amount")), target, 0.48)

func _set_ghost_amount(amount: float) -> void:
	if _canvas_material != null:
		_canvas_material.set_shader_parameter("ghost_amount", amount)

func _refresh_data() -> void:
	_data.id = portrait_id
	_data.room_id = room_id
	_data.is_family_portrait = is_family_portrait
	_data.is_covered = is_covered
	_data.is_active = is_active
	_data.is_occupied = is_occupied
	_data.global_position = global_position
	_data.global_rotation = global_rotation
	_data.is_being_carried = is_being_carried
