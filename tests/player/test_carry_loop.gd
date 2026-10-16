extends GutTest

const PlayerControllerScene = preload("res://systems/player/player_controller.tscn")
const PortraitPaintingScene = preload("res://systems/portraits/portrait_painting.tscn")
const GameCoordinatorClass = preload("res://systems/core/game_coordinator.gd")
const CarryableItemScene = preload("res://systems/player/carryable_item.tscn")
const CarTrunkScene = preload("res://systems/player/car_trunk.tscn")

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

func test_deposit_keeps_registered_family_portrait_alive() -> void:
	var root := Node3D.new()
	add_child_autoqfree(root)
	var portrait_system := PortraitSystem.new()
	root.add_child(portrait_system)
	var player: PlayerController = PlayerControllerScene.instantiate()
	root.add_child(player)
	var portrait: PortraitPainting = PortraitPaintingScene.instantiate()
	portrait.portrait_id = &"family_portrait"
	portrait.is_family_portrait = true
	root.add_child(portrait)
	await get_tree().process_frame

	assert_true(portrait_system.register_painting(portrait))
	player.boxes_packed_count = 4
	assert_true(player.interact_with_portrait(portrait))
	assert_true(portrait_system.enter_painting(&"family_portrait"))
	assert_true(player.deposit_family_portrait())
	await get_tree().process_frame

	assert_true(is_instance_valid(portrait), "Depositing must not free a registered portrait")
	assert_not_null(portrait_system.get_painting_data(&"family_portrait"))
	assert_false(portrait.is_being_carried)

func test_box_pickup_blocked_in_phase_0() -> void:
	var root := Node3D.new()
	add_child_autoqfree(root)
	var coordinator = GameCoordinatorClass.new()
	root.add_child(coordinator)
	var player: PlayerController = PlayerControllerScene.instantiate()
	root.add_child(player)
	var box: CarryableItem = CarryableItemScene.instantiate()
	box.item_type = GameTypes.CarriedItemType.BOX_LIVING_ROOM
	box.item_label = "Living Room Box"
	root.add_child(box)
	await get_tree().process_frame

	assert_eq(coordinator.phase, GameCoordinatorClass.Phase.STARTUP)
	assert_eq(box.get_interaction_prompt(), "Restore power at breaker first")
	box.interact(player)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.NONE, "Player cannot pick up box in Phase 0")

	coordinator.phase = GameCoordinatorClass.Phase.PACKING
	assert_true(box.get_interaction_prompt().begins_with("E — Pick up"))
	box.interact(player)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.BOX_LIVING_ROOM, "Player can pick up box in Phase 1")

func test_trunk_rejects_premature_deposits() -> void:
	var root := Node3D.new()
	add_child_autoqfree(root)
	var coordinator = GameCoordinatorClass.new()
	root.add_child(coordinator)
	var player: PlayerController = PlayerControllerScene.instantiate()
	root.add_child(player)
	var trunk: CarTrunk = CarTrunkScene.instantiate()
	root.add_child(trunk)
	var box := Node3D.new()
	box.name = "TestBox"
	root.add_child(box)
	await get_tree().process_frame

	assert_true(player.try_pick_up_item(box, GameTypes.CarriedItemType.BOX_LIVING_ROOM))
	assert_eq(coordinator.phase, GameCoordinatorClass.Phase.STARTUP)
	trunk.interact(player)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.BOX_LIVING_ROOM, "Trunk rejects box deposit during Phase 0")

	coordinator.phase = GameCoordinatorClass.Phase.PACKING
	trunk.interact(player)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.NONE, "Trunk accepts box deposit during Phase 1")

