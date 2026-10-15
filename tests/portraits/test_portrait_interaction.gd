extends GutTest

const PortraitPaintingScene = preload("res://systems/portraits/portrait_painting.tscn")
const PlayerControllerScene = preload("res://systems/player/player_controller.tscn")

func test_production_portrait_has_raycast_interaction_body() -> void:
	var painting: PortraitPainting = PortraitPaintingScene.instantiate()
	add_child_autoqfree(painting)
	var interaction_body: Node = painting.get_node_or_null("InteractionBody")
	assert_not_null(interaction_body, "Production paintings need a collider for the player's raycast")
	if interaction_body == null:
		return
	assert_true(interaction_body is StaticBody3D)
	assert_true(interaction_body.has_method("interact"))
	assert_true(interaction_body.has_method("get_interaction_prompt"))

func test_raycast_adapter_transfers_carried_sheet_to_painting() -> void:
	var root := Node3D.new()
	add_child_autoqfree(root)
	var player: PlayerController = PlayerControllerScene.instantiate()
	root.add_child(player)
	var painting: PortraitPainting = PortraitPaintingScene.instantiate()
	painting.portrait_id = &"adapter_test"
	root.add_child(painting)
	var sheet := Node3D.new()
	root.add_child(sheet)
	assert_true(player.try_pick_up_item(sheet, GameTypes.CarriedItemType.DUST_SHEET))
	var interaction_body: Node = painting.get_node_or_null("InteractionBody")
	assert_not_null(interaction_body)
	if interaction_body == null or not interaction_body.has_method("interact"):
		return
	interaction_body.call("interact", player)
	assert_true(painting.is_covered)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.NONE)
