extends GutTest

const PlayerControllerScene = preload("res://systems/player/player_controller.tscn")
const PortraitPaintingScene = preload("res://systems/portraits/portrait_painting.tscn")

func test_player_picks_up_one_item_and_rejects_a_second() -> void:
	var player: PlayerController = PlayerControllerScene.instantiate()
	add_child_autoqfree(player)
	var first := Node3D.new()
	first.name = "LivingRoomBox"
	add_child_autoqfree(first)
	var second := Node3D.new()
	second.name = "StudyBox"
	add_child_autoqfree(second)

	assert_true(player.has_method("try_pick_up_item"), "Player must expose its internal carry helper")
	if not player.has_method("try_pick_up_item"):
		return
	assert_true(player.try_pick_up_item(first, GameTypes.CarriedItemType.BOX_LIVING_ROOM))
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.BOX_LIVING_ROOM)
	assert_false(player.try_pick_up_item(second, GameTypes.CarriedItemType.BOX_STUDY))
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.BOX_LIVING_ROOM)

func test_deposit_box_clears_carry_and_counts_once() -> void:
	var player: PlayerController = PlayerControllerScene.instantiate()
	add_child_autoqfree(player)
	var box := Node3D.new()
	box.name = "DiningRoomBox"
	add_child_autoqfree(box)

	assert_true(player.has_method("try_pick_up_item"))
	if not player.has_method("try_pick_up_item"):
		return
	assert_true(player.try_pick_up_item(box, GameTypes.CarriedItemType.BOX_DINING_ROOM))
	assert_true(player.deposit_box_in_car())
	assert_eq(player.boxes_packed_count, 1)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.NONE)
	assert_false(player.deposit_box_in_car(), "An empty hand cannot score another box")
	assert_eq(player.boxes_packed_count, 1)

func test_dust_sheet_transfers_to_and_from_painting() -> void:
	var player: PlayerController = PlayerControllerScene.instantiate()
	add_child_autoqfree(player)
	var sheet := Node3D.new()
	sheet.name = "DustSheet"
	add_child_autoqfree(sheet)
	var painting: PortraitPainting = PortraitPaintingScene.instantiate()
	painting.portrait_id = &"sheet_test"
	add_child_autoqfree(painting)

	assert_true(player.has_method("try_pick_up_item"))
	assert_true(player.has_method("interact_with_portrait"))
	if not player.has_method("try_pick_up_item") or not player.has_method("interact_with_portrait"):
		return
	assert_true(player.try_pick_up_item(sheet, GameTypes.CarriedItemType.DUST_SHEET))
	assert_true(player.interact_with_portrait(painting))
	assert_true(painting.is_covered)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.NONE)
	assert_true(player.interact_with_portrait(painting))
	assert_false(painting.is_covered)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.DUST_SHEET)

func test_family_portrait_requires_four_boxes_and_attaches_to_player() -> void:
	var player: PlayerController = PlayerControllerScene.instantiate()
	add_child_autoqfree(player)
	var portrait: PortraitPainting = PortraitPaintingScene.instantiate()
	portrait.portrait_id = &"family_portrait"
	portrait.is_family_portrait = true
	add_child_autoqfree(portrait)

	assert_true(player.has_method("interact_with_portrait"))
	if not player.has_method("interact_with_portrait"):
		return
	assert_false(player.interact_with_portrait(portrait), "Family portrait stays mounted before all boxes are packed")
	player.boxes_packed_count = 4
	assert_true(player.interact_with_portrait(portrait))
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.FAMILY_PORTRAIT)
	assert_true(portrait.is_being_carried)
