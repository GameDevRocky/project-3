extends GutTest

const GameTypes = preload("res://systems/shared/game_types.gd")
const ElectricalSystemScript = preload("res://systems/electrical/electrical_system.gd")
const BreakerPanelScript = preload("res://systems/electrical/breaker_panel.gd")
const PlayerControllerScene = preload("res://systems/player/player_controller.tscn")

func test_breaker_panel_initial_interaction_turns_on_all_lights() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var breaker: BreakerPanel = BreakerPanelScript.new()
	breaker.set_electrical_system(electrical)
	add_child_autoqfree(breaker)

	assert_eq(electrical.get_lit_room_count(), 0, "No rooms should start lit before breaker flip")

	# Flip breaker in basement -> Phase 0 turns on all lights
	breaker.interact()
	assert_eq(electrical.get_lit_room_count(), 5, "Flipping breaker panel turns on all 5 house lights")
	assert_eq(electrical.get_current_power(), 100.0, "Power meter should be 100 Watts")

func test_breaker_panel_resets_tripped_breaker() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var breaker: BreakerPanel = BreakerPanelScript.new()
	breaker.set_electrical_system(electrical)
	add_child_autoqfree(breaker)

	# Trip breaker manually or by power drain
	electrical.set_room_light(GameTypes.RoomId.PARLOR, true)
	electrical.trip_breaker()
	assert_eq(electrical.breaker_state, GameTypes.BreakerState.TRIPPED, "Breaker should be tripped")

	# Interact with breaker panel to reset it
	breaker.interact()
	assert_eq(electrical.breaker_state, GameTypes.BreakerState.OPERATIONAL, "Breaker should now be operational")
	assert_eq(electrical.get_current_power(), 100.0, "Power should be fully restored to 100 Watts")

func test_player_interaction_with_breaker_panel() -> void:
	var root: Node3D = Node3D.new()
	add_child_autoqfree(root)

	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	electrical.name = "ElectricalSystem"
	root.add_child(electrical)

	var breaker: BreakerPanel = BreakerPanelScript.new()
	breaker.name = "BreakerPanel"
	breaker.set_electrical_system(electrical)
	breaker.position = Vector3(0, 1.5, -1.0)
	root.add_child(breaker)

	var player: PlayerController = PlayerControllerScene.instantiate()
	player.position = Vector3.ZERO
	root.add_child(player)

	await get_tree().physics_frame
	await get_tree().physics_frame

	var ray: RayCast3D = player.get_node("Camera3D/InteractionRay")
	ray.force_raycast_update()

	# Player presses 'E'
	player.try_interact()
	assert_eq(electrical.get_lit_room_count(), 5, "Player interact should flip breaker and turn on house lights")
