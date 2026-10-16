extends GutTest

const GameTypes = preload("res://systems/shared/game_types.gd")
const ElectricalSystemScript = preload("res://systems/electrical/electrical_system.gd")

func test_electrical_initial_state() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	assert_eq(electrical.get_current_power(), 250.0, "Power meter should start at 250 Watts")
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

	# 2 standard rooms lit: break-even equilibrium (4.0 - 4.0 = 0.0 W/s)
	electrical.set_room_light(GameTypes.RoomId.PARLOR, true)
	electrical.set_room_light(GameTypes.RoomId.STUDY, true)
	assert_eq(electrical.get_lit_room_count(), 2, "2 rooms lit")
	electrical._process(3.0)
	assert_almost_eq(electrical.get_current_power(), 250.0, 0.01, "2 standard lit rooms should be at break-even (250W)")

	# 3 standard rooms lit: net drain of -2.0 W/s (4.0 - 6.0 = -2.0 W/s)
	electrical.set_room_light(GameTypes.RoomId.DINING_ROOM, true)
	assert_eq(electrical.get_lit_room_count(), 3, "3 rooms lit")
	electrical._process(3.0)
	assert_almost_eq(electrical.get_current_power(), 244.0, 0.01, "3 rooms should drain 6.0 Watts over 3s")

func test_entry_hall_heavy_power_drain() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	# Entry Hall alone consumes 4.0 W/s, breaking even with the 4.0 W/s generator
	electrical.set_room_light(GameTypes.RoomId.ENTRY_HALL, true)
	assert_eq(electrical.get_room_drain_rate(GameTypes.RoomId.ENTRY_HALL), 4.0, "Entry Hall should drain 4.0 W/s")
	assert_almost_eq(electrical.get_net_power_rate(), 0.0, 0.01, "Entry Hall alone should break even with generator")

	# Entry Hall + Parlor consumes 6.0 W/s (net -2.0 W/s drain)
	electrical.set_room_light(GameTypes.RoomId.PARLOR, true)
	assert_almost_eq(electrical.get_net_power_rate(), -2.0, 0.01, "Entry Hall + Parlor should net drain at -2.0 W/s")
	electrical._process(3.0)
	assert_almost_eq(electrical.get_current_power(), 244.0, 0.01, "Power should drain by 6.0W over 3s")

func test_power_recharge_when_all_rooms_dark() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	electrical.current_power = 200.0
	assert_eq(electrical.get_lit_room_count(), 0, "All rooms dark")

	# Recharge at 4.0 W/s * 2.0s = +8.0 Watts
	electrical._process(2.0)
	assert_almost_eq(electrical.get_current_power(), 208.0, 0.01, "Power should recharge to 208.0 Watts")

	# 1 room lit: net recharge at +2.0 W/s (4.0 - 2.0 = +2.0 W/s)
	electrical.set_room_light(GameTypes.RoomId.PARLOR, true)
	electrical._process(2.0)
	assert_almost_eq(electrical.get_current_power(), 212.0, 0.01, "1 lit room should net recharge to 212.0 Watts")

	# Overcharge should clamp to max_power (250.0)
	electrical.set_room_light(GameTypes.RoomId.PARLOR, false)
	electrical._process(20.0)
	assert_eq(electrical.get_current_power(), 250.0, "Power should clamp at 250.0 Watts")

func test_automatic_breaker_trip_at_zero_power() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)
	watch_signals(electrical)

	# Turn on 3 rooms: net drain of -2.0 W/s
	electrical.set_room_light(GameTypes.RoomId.ENTRY_HALL, true)
	electrical.set_room_light(GameTypes.RoomId.STUDY, true)
	electrical.set_room_light(GameTypes.RoomId.DINING_ROOM, true)
	electrical.current_power = 2.0

	# Process 2 seconds with 3 rooms lit -> drains 4.0W, drops below 0W
	electrical._process(2.0)

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
	assert_eq(electrical.get_current_power(), 250.0, "Resetting breaker should restore 250 Watts")
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

