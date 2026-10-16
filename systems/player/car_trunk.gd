class_name CarTrunk
extends StaticBody3D

const GameTypes = preload("res://systems/shared/game_types.gd")

signal box_deposited(item_type: GameTypes.CarriedItemType)
signal family_portrait_deposited(was_safe: bool)

func _ready() -> void:
	add_to_group("car_trunk")
	add_to_group("interactables")
	collision_layer = 1
	collision_mask = 0

func interact(actor: Node = null) -> void:
	if actor == null or not actor.has_method("get_carried_item"):
		return
	var coordinator: Node = get_tree().get_first_node_in_group("game_coordinator") if get_tree() != null else null
	var item_type: GameTypes.CarriedItemType = actor.call("get_carried_item") as GameTypes.CarriedItemType
	if item_type >= GameTypes.CarriedItemType.BOX_LIVING_ROOM and item_type <= GameTypes.CarriedItemType.BOX_BASEMENT:
		if coordinator != null and coordinator.has_method("can_pack_boxes") and not bool(coordinator.call("can_pack_boxes")):
			return
		if actor.call("deposit_box_in_car"):
			box_deposited.emit(item_type)
	elif item_type == GameTypes.CarriedItemType.FAMILY_PORTRAIT:
		if coordinator != null and coordinator.has_method("can_take_family_portrait") and not bool(coordinator.call("can_take_family_portrait")):
			return
		var safe: bool = not bool(actor.call("is_carried_family_portrait_occupied"))
		if actor.call("deposit_family_portrait", self):
			family_portrait_deposited.emit(safe)

func get_interaction_prompt(actor: Node = null) -> String:
	if actor == null or not actor.has_method("get_carried_item"):
		return "Car trunk"
	var coordinator: Node = get_tree().get_first_node_in_group("game_coordinator") if get_tree() != null else null
	var item_type: GameTypes.CarriedItemType = actor.call("get_carried_item") as GameTypes.CarriedItemType
	if item_type >= GameTypes.CarriedItemType.BOX_LIVING_ROOM and item_type <= GameTypes.CarriedItemType.BOX_BASEMENT:
		if coordinator != null and coordinator.has_method("can_pack_boxes") and not bool(coordinator.call("can_pack_boxes")):
			return "Restore power at breaker first"
		return "E — Pack box"
	if item_type == GameTypes.CarriedItemType.FAMILY_PORTRAIT:
		if coordinator != null and coordinator.has_method("can_take_family_portrait") and not bool(coordinator.call("can_take_family_portrait")):
			return "Load all four boxes first"
		return "E — Leave with family portrait"
	return "Bring the remaining belongings here"
