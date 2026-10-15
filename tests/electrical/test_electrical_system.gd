extends GutTest

const GameTypes = preload("res://systems/shared/game_types.gd")
const ElectricalSystemScript = preload("res://systems/electrical/electrical_system.gd")

func test_electrical_initial_state() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	assert_eq(electrical.get_current_power(), 100.0, "Power meter should start at 100 Watts")
	assert_eq(electrical.get_lit_room_count(), 0, "No rooms should start illuminated")

	for room in [GameTypes.RoomId.ENTRY_HALL, GameTypes.RoomId.PARLOR, GameTypes.RoomId.STUDY, GameTypes.RoomId.DINING_ROOM, GameTypes.RoomId.BASEMENT]:
		assert_eq(electrical.get_room_light_state(room), GameTypes.LightState.OFF, "Room %d light should start OFF" % room)
		assert_false(electrical.is_room_lit(room), "Room %d is_room_lit should be false" % room)

	assert_false(electrical.is_room_lit(GameTypes.RoomId.EXTERIOR_DRIVEWAY), "Exterior driveway should never be lit")

func test_set_room_light_and_signals() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)
	watch_signals(electrical)

	electrical.set_room_light(GameTypes.RoomId.PARLOR, true)
	assert_true(electrical.is_room_lit(GameTypes.RoomId.PARLOR), "Parlor should now be lit")
	assert_eq(electrical.get_room_light_state(GameTypes.RoomId.PARLOR), GameTypes.LightState.ON, "Parlor light state should be ON")
	assert_eq(electrical.get_lit_room_count(), 1, "Lit room count should be 1")
	assert_signal_emitted_with_parameters(electrical, "light_state_changed", [GameTypes.RoomId.PARLOR, GameTypes.LightState.ON])

	electrical.set_room_light(GameTypes.RoomId.PARLOR, false)
	assert_false(electrical.is_room_lit(GameTypes.RoomId.PARLOR), "Parlor should now be off")
	assert_eq(electrical.get_room_light_state(GameTypes.RoomId.PARLOR), GameTypes.LightState.OFF, "Parlor light state should be OFF")
	assert_eq(electrical.get_lit_room_count(), 0, "Lit room count should be 0")
	assert_signal_emitted_with_parameters(electrical, "light_state_changed", [GameTypes.RoomId.PARLOR, GameTypes.LightState.OFF])

func test_turn_on_all_lights() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	electrical.turn_on_all_lights()
	assert_eq(electrical.get_lit_room_count(), 5, "All 5 house rooms should be lit")
	assert_true(electrical.is_room_lit(GameTypes.RoomId.ENTRY_HALL), "Entry hall should be lit")
	assert_true(electrical.is_room_lit(GameTypes.RoomId.PARLOR), "Parlor should be lit")
	assert_true(electrical.is_room_lit(GameTypes.RoomId.STUDY), "Study should be lit")
	assert_true(electrical.is_room_lit(GameTypes.RoomId.DINING_ROOM), "Dining room should be lit")
	assert_true(electrical.is_room_lit(GameTypes.RoomId.BASEMENT), "Basement should be lit")

func test_power_drain_with_lit_rooms() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	electrical.set_room_light(GameTypes.RoomId.ENTRY_HALL, true)
	electrical.set_room_light(GameTypes.RoomId.STUDY, true)
	assert_eq(electrical.get_lit_room_count(), 2, "2 rooms lit")

	# 2 rooms * 1.0 W/s * 3.0s = 6.0 Watts drained
	electrical._process(3.0)
	assert_almost_eq(electrical.get_current_power(), 94.0, 0.01, "Power should drain by 6.0 Watts")

func test_power_recharge_when_all_rooms_dark() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	electrical.current_power = 80.0
	assert_eq(electrical.get_lit_room_count(), 0, "All rooms dark")

	# Recharge at 5.0 W/s * 2.0s = +10.0 Watts
	electrical._process(2.0)
	assert_almost_eq(electrical.get_current_power(), 90.0, 0.01, "Power should recharge to 90.0 Watts")

	# Overcharge should clamp to max_power (100.0)
	electrical._process(5.0)
	assert_eq(electrical.get_current_power(), 100.0, "Power should clamp at 100.0 Watts")

func test_automatic_breaker_trip_at_zero_power() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)
	watch_signals(electrical)

	electrical.set_room_light(GameTypes.RoomId.DINING_ROOM, true)
	electrical.current_power = 2.0

	# Process 3 seconds with 1 room lit -> drains 3.0W, drops below 0W
	electrical._process(3.0)

	assert_eq(electrical.get_current_power(), 0.0, "Power should clamp at 0.0 Watts")
	assert_false(electrical.is_room_lit(GameTypes.RoomId.DINING_ROOM), "Dining room light should cut off")
	assert_eq(electrical.get_room_light_state(GameTypes.RoomId.DINING_ROOM), GameTypes.LightState.OFF, "Light state should be OFF")
	assert_eq(electrical.get_lit_room_count(), 0, "No rooms should be lit after breaker trip")
	assert_signal_emitted_with_parameters(electrical, "breaker_state_changed", [GameTypes.BreakerState.TRIPPED])

	# Attempt to turn on lights while tripped should fail
	electrical.set_room_light(GameTypes.RoomId.BASEMENT, true)
	assert_false(electrical.is_room_lit(GameTypes.RoomId.BASEMENT), "Cannot turn on lights while breaker is tripped")

func test_manual_trip_and_reset_breaker() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)
	watch_signals(electrical)

	electrical.set_room_light(GameTypes.RoomId.ENTRY_HALL, true)
	electrical.trip_breaker()

	assert_false(electrical.is_room_lit(GameTypes.RoomId.ENTRY_HALL), "Light should be OFF after trip")
	assert_signal_emitted_with_parameters(electrical, "breaker_state_changed", [GameTypes.BreakerState.TRIPPED])

	electrical.reset_breaker()
	assert_eq(electrical.get_current_power(), 100.0, "Resetting breaker should restore 100 Watts")
	assert_signal_emitted_with_parameters(electrical, "breaker_state_changed", [GameTypes.BreakerState.OPERATIONAL])

	# Now lights can be turned on again
	electrical.set_room_light(GameTypes.RoomId.ENTRY_HALL, true)
	assert_true(electrical.is_room_lit(GameTypes.RoomId.ENTRY_HALL), "Can turn on light after resetting breaker")

func test_ghost_light_reaction_queries() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	# Verify public interface used by GhostMonster in systems/ghost/ghost_monster.gd
	assert_true(electrical.has_method("is_room_lit"), "Must have is_room_lit for ghost AI")
	assert_true(electrical.has_method("get_room_light_state"), "Must have get_room_light_state for ghost AI")
	assert_true(electrical.has_signal("light_state_changed"), "Must have light_state_changed signal for ghost AI")

	# Initial state: dark room -> ghost can roam freely
	assert_false(electrical.is_room_lit(GameTypes.RoomId.BASEMENT), "Basement starts dark, ghost can roam")

	# Lights turn on -> room lit -> ghost must freeze in painting
	electrical.set_room_light(GameTypes.RoomId.BASEMENT, true)
	assert_true(electrical.is_room_lit(GameTypes.RoomId.BASEMENT), "Basement is lit, ghost must freeze")

	# Breaker trips -> room becomes dark again -> ghost resumes roaming
	electrical.trip_breaker()
	assert_false(electrical.is_room_lit(GameTypes.RoomId.BASEMENT), "Breaker tripped, basement is dark again, ghost unfreezes")

func test_paranormal_flicker_temporarily_preserves_a_lit_room() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)
	electrical.set_room_light(GameTypes.RoomId.STUDY, true)

	assert_true(electrical.has_method("trigger_flicker"))
	if not electrical.has_method("trigger_flicker"):
		return
	assert_true(electrical.trigger_flicker(GameTypes.RoomId.STUDY, 0.25))
	assert_eq(electrical.get_room_light_state(GameTypes.RoomId.STUDY), GameTypes.LightState.FLICKERING)
	assert_true(electrical.is_room_lit(GameTypes.RoomId.STUDY), "Flickering light remains a light barrier")
	electrical._process(0.3)
	assert_eq(electrical.get_room_light_state(GameTypes.RoomId.STUDY), GameTypes.LightState.ON)

