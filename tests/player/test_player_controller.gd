extends GutTest

const PlayerControllerScript = preload("res://systems/player/player_controller.gd")
const PlayerControllerScene = preload("res://systems/player/player_controller.tscn")

class MockInteractable extends StaticBody3D:
	var interacted: bool = false
	func interact(_actor: Node = null) -> void:
		interacted = true

func test_player_initial_state() -> void:
	var player: PlayerController = PlayerControllerScript.new()
	add_child_autoqfree(player)
	var state = player.get_player_state()
	assert_true(state.is_alive, "Player should start alive")
	assert_eq(state.boxes_packed_count, 0, "Initial boxes packed should be 0")
	assert_eq(state.carried_item, GameTypes.CarriedItemType.NONE, "Initial carried item should be NONE")

	player.kill_player()
	assert_false(player.get_player_state().is_alive, "Player should be dead after kill_player()")

func test_player_try_interact_calls_interact_on_target() -> void:
	var root: Node3D = Node3D.new()
	add_child_autoqfree(root)

	var target: MockInteractable = MockInteractable.new()
	var col: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(1, 1, 1)
	col.shape = box
	target.add_child(col)
	target.position = Vector3(0, 1.6, -1.0)
	root.add_child(target)

	var player: PlayerController = PlayerControllerScene.instantiate()
	player.position = Vector3.ZERO
	root.add_child(player)

	await get_tree().physics_frame
	await get_tree().physics_frame

	var ray: RayCast3D = player.get_node("Camera3D/InteractionRay")
	ray.force_raycast_update()

	assert_false(target.interacted, "Target should not be interacted before calling try_interact")
	player.try_interact()
	assert_true(target.interacted, "Target interact() should be called by try_interact()")

func test_mouse_look_rotates_body_and_clamps_camera_pitch() -> void:
	var player: PlayerController = PlayerControllerScene.instantiate()
	add_child_autoqfree(player)
	await get_tree().process_frame

	player._apply_look(Vector2(100.0, -10000.0))

	var player_camera: Camera3D = player.get_node("Camera3D") as Camera3D
	assert_lt(player.rotation.y, 0.0, "Horizontal mouse motion should rotate the player body")
	assert_almost_eq(
		player_camera.rotation.x,
		PI / 2.2,
		0.001,
		"Vertical mouse motion should rotate and clamp the camera",
	)

func test_drop_key_releases_a_retrieved_dust_sheet_and_allows_box_pickup() -> void:
	var root := Node3D.new()
	add_child_autoqfree(root)
	var player: PlayerController = PlayerControllerScene.instantiate()
	root.add_child(player)
	var painting: PortraitPainting = load("res://systems/portraits/portrait_painting.tscn").instantiate() as PortraitPainting
	painting.portrait_id = &"drop_sheet_test"
	painting.is_covered = true
	root.add_child(painting)
	await get_tree().process_frame

	assert_true(player.interact_with_portrait(painting), "Removing a sheet picks it up")
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.DUST_SHEET)
	assert_true(player.get_interaction_prompt().contains("G"), "The drop key is shown while carrying an item")
	var carried_sheet: Node3D = player.carried_node

	var drop_event := InputEventKey.new()
	drop_event.keycode = KEY_G
	drop_event.pressed = true
	player._input(drop_event)
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.NONE, "G drops the carried sheet")
	assert_eq(carried_sheet.get_parent(), root, "The dropped sheet is returned to the world")
	assert_almost_eq(carried_sheet.global_position.y, player.global_position.y + 0.025, 0.001, "The dropped sheet rests at floor level")

	var box := Node3D.new()
	root.add_child(box)
	assert_true(player.try_pick_up_item(box, GameTypes.CarriedItemType.BOX_BASEMENT), "The freed carry slot can pick up a box")
	assert_eq(player.get_carried_item(), GameTypes.CarriedItemType.BOX_BASEMENT)
