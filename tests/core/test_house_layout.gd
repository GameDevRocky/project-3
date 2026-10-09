extends GutTest

const MAIN_SCENE_PATH := "res://systems/core/main.tscn"

func test_main_scene_instantiates() -> void:
	var scene_res = load(MAIN_SCENE_PATH)
	assert_not_null(scene_res, "main.tscn should load without parse errors")
	var instance = scene_res.instantiate()
	assert_not_null(instance, "main.tscn should instantiate cleanly")
	add_child_autoqfree(instance)

func test_house_geometry_and_rooms_exist() -> void:
	var scene_res = load(MAIN_SCENE_PATH)
	var instance = scene_res.instantiate()
	add_child_autoqfree(instance)

	var geom = instance.get_node_or_null("HouseGeometry")
	assert_not_null(geom, "HouseGeometry CSGCombiner3D must exist")

	var rooms = instance.get_node_or_null("RoomVolumes")
	assert_not_null(rooms, "RoomVolumes container must exist")

	var expected_rooms: Dictionary = {
		"RoomVolume_EntryHall": GameTypes.RoomId.ENTRY_HALL,
		"RoomVolume_Parlor": GameTypes.RoomId.PARLOR,
		"RoomVolume_Study": GameTypes.RoomId.STUDY,
		"RoomVolume_DiningRoom": GameTypes.RoomId.DINING_ROOM,
		"RoomVolume_Basement": GameTypes.RoomId.BASEMENT,
		"RoomVolume_Driveway": GameTypes.RoomId.EXTERIOR_DRIVEWAY
	}

	for node_name in expected_rooms.keys():
		var rv = rooms.get_node_or_null(node_name)
		assert_not_null(rv, "Room node '%s' must exist" % node_name)
		if rv != null and rv is RoomVolume:
			assert_eq(rv.room_id, expected_rooms[node_name], "Room '%s' must match expected RoomId" % node_name)

func test_all_interactive_sockets_exist() -> void:
	var scene_res = load(MAIN_SCENE_PATH)
	var instance = scene_res.instantiate()
	add_child_autoqfree(instance)

	var sockets = instance.get_node_or_null("Sockets")
	assert_not_null(sockets, "Sockets container must exist")

	# Car and Trunk
	var car = sockets.get_node_or_null("CarSocket")
	assert_not_null(car, "CarSocket must exist")
	var trunk = sockets.get_node_or_null("CarSocket/TrunkSocket")
	assert_not_null(trunk, "TrunkSocket must exist on the car")

	# Breaker
	var breaker = sockets.get_node_or_null("BreakerPanelSocket")
	assert_not_null(breaker, "BreakerPanelSocket must exist")

	# Family Portrait
	var family_portrait = sockets.get_node_or_null("FamilyPortraitSocket")
	assert_not_null(family_portrait, "FamilyPortraitSocket must exist by the front door")

	# 4 Moving Boxes
	var boxes = sockets.get_node_or_null("MovingBoxSockets")
	assert_not_null(boxes, "MovingBoxSockets container must exist")
	assert_not_null(boxes.get_node_or_null("Box_LivingRoom"), "Living room box socket must exist")
	assert_not_null(boxes.get_node_or_null("Box_DiningRoom"), "Dining room box socket must exist")
	assert_not_null(boxes.get_node_or_null("Box_Study"), "Study box socket must exist")
	assert_not_null(boxes.get_node_or_null("Box_Basement"), "Basement box socket must exist")

	# Lights and Switches
	var lights = sockets.get_node_or_null("LightFixtureSockets")
	assert_not_null(lights, "LightFixtureSockets must exist")
	assert_eq(lights.get_child_count(), 5, "Must have 5 room light fixtures")

	var switches = sockets.get_node_or_null("SwitchSockets")
	assert_not_null(switches, "SwitchSockets must exist")
	assert_eq(switches.get_child_count(), 5, "Must have 5 room wall switches")
