extends GutTest

const PlayerControllerScript = preload("res://systems/player/player_controller.gd")

func test_player_initial_state() -> void:
	var player: PlayerController = PlayerControllerScript.new()
	add_child_autoqfree(player)
	var state = player.get_player_state()
	assert_true(state.is_alive, "Player should start alive")
	assert_eq(state.boxes_packed_count, 0, "Initial boxes packed should be 0")
	assert_eq(state.carried_item, GameTypes.CarriedItemType.NONE, "Initial carried item should be NONE")

	player.kill_player()
	assert_false(player.get_player_state().is_alive, "Player should be dead after kill_player()")
	player.queue_free()
