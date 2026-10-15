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
