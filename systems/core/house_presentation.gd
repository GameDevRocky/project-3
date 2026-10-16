class_name HousePresentation
extends Node3D

func _ready() -> void:
	_configure_environment()
	_build_entry_hall()
	_build_parlor()
	_build_study()
	_build_dining_room()
	_build_basement()
	_build_room_labels()

func _configure_environment() -> void:
	var root: Node = get_parent()
	if root == null:
		return
	var world_environment: WorldEnvironment = root.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment == null:
		return
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.012, 0.016, 0.026)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.22, 0.26, 0.34)
	environment.ambient_light_energy = 0.14
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment

func _build_entry_hall() -> void:
	_add_box("EntryRug", Vector3(2.3, 0.035, 3.2), Vector3(0.0, 0.23, -2.8), Color(0.22, 0.055, 0.045))
	_add_box("EntryConsole", Vector3(1.8, 0.12, 0.45), Vector3(1.65, 0.9, -4.8), Color(0.22, 0.11, 0.045))
	for x: float in [1.0, 2.3]:
		_add_box("ConsoleLeg", Vector3(0.12, 0.85, 0.12), Vector3(x, 0.48, -4.8), Color(0.18, 0.075, 0.025))
	_add_cylinder("CoatRack", 0.08, 2.25, Vector3(-1.9, 1.25, -1.1), Color(0.16, 0.08, 0.035))

func _build_parlor() -> void:
	_add_box("SofaBase", Vector3(2.8, 0.55, 0.9), Vector3(-8.4, 0.52, -1.5), Color(0.24, 0.13, 0.14))
	_add_box("SofaBack", Vector3(2.8, 1.15, 0.25), Vector3(-8.4, 1.12, -1.88), Color(0.28, 0.15, 0.16))
	_add_box("SofaArm", Vector3(0.28, 0.78, 0.95), Vector3(-9.82, 0.7, -1.5), Color(0.2, 0.1, 0.11))
	_add_box("SofaArm", Vector3(0.28, 0.78, 0.95), Vector3(-6.98, 0.7, -1.5), Color(0.2, 0.1, 0.11))
	_add_box("CoffeeTable", Vector3(2.1, 0.13, 1.05), Vector3(-7.8, 0.62, -3.6), Color(0.19, 0.095, 0.035))
	for x: float in [-8.65, -6.95]:
		for z: float in [-3.95, -3.25]:
			_add_box("TableLeg", Vector3(0.1, 0.52, 0.1), Vector3(x, 0.35, z), Color(0.14, 0.06, 0.02))

func _build_study() -> void:
	_add_box("StudyDesk", Vector3(2.6, 0.14, 1.0), Vector3(6.2, 0.92, -4.7), Color(0.2, 0.1, 0.04))
	for x: float in [5.1, 7.3]:
		_add_box("DeskLeg", Vector3(0.16, 0.82, 0.16), Vector3(x, 0.48, -4.7), Color(0.14, 0.065, 0.025))
	for z: float in [-1.1, -2.45, -3.8, -5.15]:
		_add_box("Bookshelf", Vector3(0.45, 2.35, 1.0), Vector3(8.55, 1.3, z), Color(0.18, 0.085, 0.03))
		for shelf_y: float in [0.55, 1.15, 1.75, 2.35]:
			_add_box("Books", Vector3(0.48, 0.24, 0.82), Vector3(8.27, shelf_y, z), Color(0.32, 0.12 + shelf_y * 0.03, 0.07))

func _build_dining_room() -> void:
	_add_box("DiningTable", Vector3(3.6, 0.16, 1.55), Vector3(1.2, 0.92, -9.7), Color(0.19, 0.085, 0.028))
	for x: float in [-0.25, 2.65]:
		for z: float in [-10.25, -9.15]:
			_add_box("DiningLeg", Vector3(0.16, 0.82, 0.16), Vector3(x, 0.48, z), Color(0.13, 0.052, 0.016))
	for chair_position: Vector3 in [Vector3(-0.2, 0.5, -8.5), Vector3(1.2, 0.5, -8.5), Vector3(2.6, 0.5, -8.5), Vector3(-0.2, 0.5, -10.9), Vector3(1.2, 0.5, -10.9), Vector3(2.6, 0.5, -10.9)]:
		_add_box("DiningChair", Vector3(0.62, 0.12, 0.62), chair_position, Color(0.21, 0.09, 0.03))
		_add_box("ChairBack", Vector3(0.62, 0.92, 0.12), chair_position + Vector3(0.0, 0.48, 0.25 if chair_position.z < -9.7 else -0.25), Color(0.17, 0.065, 0.02))

func _build_basement() -> void:
	for y: float in [-3.0, -2.15, -1.3]:
		_add_box("UtilityShelf", Vector3(2.5, 0.1, 0.65), Vector3(-4.5, y, -14.8), Color(0.16, 0.17, 0.18))
	for x: float in [-5.55, -3.45]:
		_add_box("ShelfPost", Vector3(0.1, 2.5, 0.1), Vector3(x, -2.2, -14.8), Color(0.13, 0.14, 0.15))
	_add_cylinder("BasementPipe", 0.12, 6.5, Vector3(1.55, -1.8, -12.0), Color(0.25, 0.22, 0.18), Vector3(PI * 0.5, 0.0, 0.0))

func _build_room_labels() -> void:
	_add_label("ENTRY HALL", Vector3(0.0, 2.35, -0.18), PI)
	_add_label("PARLOR", Vector3(-2.95, 2.45, -3.0), PI * 0.5)
	_add_label("STUDY", Vector3(2.95, 2.45, -3.0), -PI * 0.5)
	_add_label("DINING ROOM", Vector3(1.0, 2.35, -6.12), 0.0)
	_add_label("BASEMENT", Vector3(-1.8, 1.1, -7.85), PI)

func _add_box(node_name: String, size: Vector3, location: Vector3, color: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.material_override = _material(color)
	visual.position = location
	add_child(visual)

func _add_cylinder(node_name: String, radius: float, height: float, location: Vector3, color: Color, rotation_value: Vector3 = Vector3.ZERO) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	visual.mesh = mesh
	visual.material_override = _material(color)
	visual.position = location
	visual.rotation = rotation_value
	add_child(visual)

func _add_label(text_value: String, location: Vector3, yaw: float) -> void:
	var label := Label3D.new()
	label.name = "%sLabel" % text_value.replace(" ", "")
	label.text = text_value
	label.font_size = 42
	label.outline_size = 8
	label.pixel_size = 0.004
	label.modulate = Color(0.58, 0.43, 0.25)
	label.position = location
	label.rotation.y = yaw
	add_child(label)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	material.metallic = 0.04
	return material
