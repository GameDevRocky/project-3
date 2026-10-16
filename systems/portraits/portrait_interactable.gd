class_name PortraitInteractable
extends StaticBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")

@onready var painting: PortraitPainting = get_parent() as PortraitPainting

func _ready() -> void:
	add_to_group("interactables")
	collision_layer = 1
	collision_mask = 0
	var collision: CollisionShape3D = get_node_or_null("CollisionShape3D") as CollisionShape3D
	if painting != null and collision != null and collision.shape is BoxShape3D:
		(collision.shape as BoxShape3D).size = Vector3(painting.painting_size.x + 0.2, painting.painting_size.y + 0.2, 0.22)

func interact(actor: Node = null) -> void:
	if painting != null and actor != null and actor.has_method("interact_with_portrait"):
		actor.call("interact_with_portrait", painting)

func get_interaction_prompt(actor: Node = null) -> String:
	if painting == null:
		return "Old portrait"
	var has_sheet: bool = false
	var boxes_loaded: bool = false
	if actor != null and actor.has_method("get_carried_item"):
		has_sheet = actor.call("get_carried_item") == GameTypes.CarriedItemType.DUST_SHEET
	var coordinator: Node = get_tree().get_first_node_in_group("game_coordinator") if get_tree() != null else null
	if coordinator != null and coordinator.has_method("can_take_family_portrait"):
		boxes_loaded = bool(coordinator.call("can_take_family_portrait"))
	elif actor is PlayerController:
		boxes_loaded = (actor as PlayerController).boxes_packed_count >= 4
	return painting.get_interaction_prompt(has_sheet, boxes_loaded)
