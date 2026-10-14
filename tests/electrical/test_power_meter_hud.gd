extends GutTest

const GameTypes = preload("res://systems/shared/game_types.gd")
const ElectricalSystemScript = preload("res://systems/electrical/electrical_system.gd")
const PowerMeterHUDScene = preload("res://systems/electrical/power_meter_hud.tscn")

func test_hud_initial_state() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var hud: PowerMeterHUD = PowerMeterHUDScene.instantiate()
	add_child_autoqfree(hud)
	hud.set_electrical_system(electrical)

	assert_eq(hud.power_bar.value, 100.0, "Power bar should start at 100")
	assert_true(hud.wattage_label.text.contains("100.0 W / 100 W"), "Wattage label should show 100.0 W")
	assert_true(hud.status_label.text.contains("GRID IDLE"), "Status label should show GRID IDLE when all dark")
	assert_false(hud.warning_banner.visible, "Warning banner should be hidden initially")

func test_hud_draining_display() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var hud: PowerMeterHUD = PowerMeterHUDScene.instantiate()
	add_child_autoqfree(hud)
	hud.set_electrical_system(electrical)

	# Turn on 2 rooms
	electrical.set_room_light(GameTypes.RoomId.PARLOR, true)
	electrical.set_room_light(GameTypes.RoomId.STUDY, true)

	assert_true(hud.status_label.text.contains("DRAINING: -2.0 W/s"), "Status should show -2.0 W/s drain rate")
	assert_true(hud.status_label.text.contains("2 rooms"), "Status should list 2 rooms lit")

func test_hud_low_voltage_warning() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var hud: PowerMeterHUD = PowerMeterHUDScene.instantiate()
	add_child_autoqfree(hud)
	hud.set_electrical_system(electrical)

	electrical.set_room_light(GameTypes.RoomId.ENTRY_HALL, true)
	electrical.current_power = 12.0
	hud.update_display(12.0, 100.0)

	assert_true(hud.warning_banner.visible, "Warning banner should be visible when voltage is low")
	assert_true(hud.warning_banner.text.contains("LOW VOLTAGE"), "Warning text should indicate low voltage")

func test_hud_blackout_state() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var hud: PowerMeterHUD = PowerMeterHUDScene.instantiate()
	add_child_autoqfree(hud)
	hud.set_electrical_system(electrical)

	electrical.trip_breaker()

	assert_true(hud.status_label.text.contains("BLACKOUT"), "Status should display GRID BLACKOUT")
	assert_true(hud.warning_banner.visible, "Warning banner should display on blackout")
	assert_true(hud.warning_banner.text.contains("BREAKER TRIPPED"), "Warning should instruct to reset in basement")

func test_hud_recharging_display() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var hud: PowerMeterHUD = PowerMeterHUDScene.instantiate()
	add_child_autoqfree(hud)
	hud.set_electrical_system(electrical)

	electrical.current_power = 60.0
	hud.update_display(60.0, 100.0)

	assert_true(hud.status_label.text.contains("RECHARGING: +5.0 W/s"), "Status should indicate recharging rate")
	assert_false(hud.warning_banner.visible, "Warning banner should be hidden when recharging safely")

func test_low_power_fixture_dimming() -> void:
	var electrical: ElectricalSystem = ElectricalSystemScript.new()
	add_child_autoqfree(electrical)

	var mock_light := OmniLight3D.new()
	mock_light.light_energy = 1.2
	add_child_autoqfree(mock_light)

	electrical._light_fixtures[GameTypes.RoomId.PARLOR] = mock_light
	electrical.set_room_light(GameTypes.RoomId.PARLOR, true)

	# Full power: 1.2
	assert_almost_eq(mock_light.light_energy, 1.2, 0.01, "Light should have full energy at 100W")

	# Low power (< 15W): dims
	electrical.current_power = 7.5
	electrical._sync_fixture(GameTypes.RoomId.PARLOR, true)
	assert_lt(mock_light.light_energy, 1.2, "Light energy should dim when power is low")
