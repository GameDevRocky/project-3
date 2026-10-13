extends GutTest

const GameTypes = preload("res://systems/shared/game_types.gd")
const ElectricalSystemScript = preload("res://systems/electrical/electrical_system.gd")
const LightSwitchScript = preload("res://systems/electrical/light_switch.gd")
const PlayerControllerScene = preload("res://systems/player/player_controller.tscn")

func test_light_switch_toggles_room_light() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var switch: LightSwitch = LightSwitchScript.new()
	switch.room_id = GameTypes.RoomId.PARLOR
	switch.set_electrical_system(electrical)
	add_child_autoqfree(switch)

	assert_false(electrical.is_room_lit(GameTypes.RoomId.PARLOR), "Parlor should start dark")

	# Interact -> turns light ON
	switch.interact()
	assert_true(electrical.is_room_lit(GameTypes.RoomId.PARLOR), "Parlor should be lit after interaction")

	# Interact again -> turns light OFF
	switch.interact()
	assert_false(electrical.is_room_lit(GameTypes.RoomId.PARLOR), "Parlor should be dark after second interaction")

func test_light_switch_cannot_turn_on_light_when_breaker_tripped() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var switch: LightSwitch = LightSwitchScript.new()
	switch.room_id = GameTypes.RoomId.STUDY
	switch.set_electrical_system(electrical)
	add_child_autoqfree(switch)

	electrical.trip_breaker()

	switch.interact()
	assert_false(electrical.is_room_lit(GameTypes.RoomId.STUDY), "Cannot turn on light when breaker is tripped")

func test_player_interaction_with_light_switch() -> void:
	var root: Node3D = Node3D.new()
	add_child_autoqfree(root)

	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	electrical.name = "ElectricalSystem"
	root.add_child(electrical)

	var switch: LightSwitch = LightSwitchScript.new()
	switch.name = "Switch_EntryHall"
	switch.room_id = GameTypes.RoomId.ENTRY_HALL
	switch.set_electrical_system(electrical)
	switch.position = Vector3(0, 1.5, -1.0)
	root.add_child(switch)

	var player: PlayerController = PlayerControllerScene.instantiate()
	player.position = Vector3(0, 0, 0)
	root.add_child(player)

	# Await physics frame so PhysicsServer registers colliders in space
	await get_tree().physics_frame
	await get_tree().physics_frame

	var ray: RayCast3D = player.get_node("Camera3D/InteractionRay")
	ray.force_raycast_update()

	# Call try_interact
	player.try_interact()
	assert_true(electrical.is_room_lit(GameTypes.RoomId.ENTRY_HALL), "Player interact should turn on Entry Hall light")

	# Interact again
	player.try_interact()
	assert_false(electrical.is_room_lit(GameTypes.RoomId.ENTRY_HALL), "Player interact again should turn off Entry Hall light")
