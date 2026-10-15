class_name CarryableItem
extends StaticBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")

@export var item_type: GameTypes.CarriedItemType = GameTypes.CarriedItemType.BOX_LIVING_ROOM
@export var item_label: String = "Moving Box"

func _ready() -> void:
	add_to_group("carryable_items")
	add_to_group("interactables")
	collision_layer = 1
	collision_mask = 0
	_build_visuals()

func interact(actor: Node = null) -> void:
	if actor != null and actor.has_method("try_pick_up_item"):
		actor.call("try_pick_up_item", self, item_type)

func get_interaction_prompt(_actor: Node = null) -> String:
	return "E — Pick up %s" % item_label

func on_picked_up(_actor: Node) -> void:
	set_process(false)

func on_dropped() -> void:
	set_process(true)

func _build_visuals() -> void:
	if get_node_or_null("CollisionShape3D") == null:
		var collision := CollisionShape3D.new()
		collision.name = "CollisionShape3D"
		var shape := BoxShape3D.new()
		shape.size = Vector3(0.7, 0.55, 0.62) if item_type != GameTypes.CarriedItemType.DUST_SHEET else Vector3(0.72, 0.18, 0.48)
		collision.shape = shape
		add_child(collision)
	if get_node_or_null("MeshInstance3D") == null:
		var visual := MeshInstance3D.new()
		visual.name = "MeshInstance3D"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.68, 0.53, 0.6) if item_type != GameTypes.CarriedItemType.DUST_SHEET else Vector3(0.7, 0.16, 0.46)
		visual.mesh = mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.55, 0.36, 0.18) if item_type != GameTypes.CarriedItemType.DUST_SHEET else Color(0.82, 0.79, 0.7)
		material.roughness = 0.92
		visual.material_override = material
		add_child(visual)
	if get_node_or_null("Label3D") == null:
		var label := Label3D.new()
		label.name = "Label3D"
		label.text = item_label
		label.font_size = 42
		label.modulate = Color(0.12, 0.08, 0.04) if item_type != GameTypes.CarriedItemType.DUST_SHEET else Color(0.25, 0.22, 0.2)
		label.outline_size = 4
		label.position = Vector3(0.0, 0.0, 0.32)
		label.pixel_size = 0.004
		add_child(label)
