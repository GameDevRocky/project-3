extends GutTest

const GameTypes = preload("res://systems/shared/game_types.gd")
const RoomVolume = preload("res://systems/core/room_volume.gd")
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

func test_complete_gameplay_nodes_exist() -> void:
	var scene_res = load(MAIN_SCENE_PATH)
	var instance = scene_res.instantiate()
	add_child_autoqfree(instance)
	assert_not_null(instance.get_node_or_null("GameCoordinator"))
	assert_not_null(instance.get_node_or_null("GameHUD"))
	assert_not_null(instance.get_node_or_null("GhostMonster"))
	assert_not_null(instance.get_node_or_null("HousePresentation"))
	assert_not_null(instance.get_node_or_null("ProceduralAudio"))
	assert_not_null(instance.get_node_or_null("Sockets/CarSocket/CarTrunk"))
	assert_not_null(instance.get_node_or_null("Sockets/MovingBoxSockets/DustSheet"))
	assert_true(instance.get_node("Sockets/MovingBoxSockets/Box_LivingRoom") is CarryableItem)

func test_painting_orientations() -> void:
	var scene_res = load(MAIN_SCENE_PATH)
	var instance = scene_res.instantiate()
	add_child_autoqfree(instance)
	var portraits = instance.get_node_or_null("PortraitSystem")
	assert_not_null(portraits)

	var basement_1: Node3D = portraits.get_node_or_null("Painting_Basement_1") as Node3D
	assert_not_null(basement_1)
	assert_gt(basement_1.transform.basis.z.x, 0.9, "Painting_Basement_1 must face East (+X) toward the stairs")

	var family: Node3D = portraits.get_node_or_null("FamilyPortrait") as Node3D
	assert_not_null(family)
	assert_lt(family.transform.basis.z.z, -0.9, "FamilyPortrait must face North (-Z) into the entry foyer")

	var parlor_1: Node3D = portraits.get_node_or_null("Painting_Parlor_1") as Node3D
	assert_not_null(parlor_1)
	assert_gt(parlor_1.transform.basis.z.x, 0.9, "Painting_Parlor_1 must face East (+X) into the parlor")

	var study_1: Node3D = portraits.get_node_or_null("Painting_Study_1") as Node3D
	assert_not_null(study_1)
	assert_lt(study_1.transform.basis.z.x, -0.9, "Painting_Study_1 must face West (-X) into the study")

	var dining_1: Node3D = portraits.get_node_or_null("Painting_Dining_1") as Node3D
	assert_not_null(dining_1)
	assert_gt(dining_1.transform.basis.z.z, 0.9, "Painting_Dining_1 must face South (+Z) into the dining room")

	var parlor_2: Node3D = portraits.get_node_or_null("Painting_Parlor_2") as Node3D
	assert_not_null(parlor_2)
	assert_gt(parlor_2.transform.basis.z.z, 0.9, "Painting_Parlor_2 must face South (+Z) into the parlor")

func test_parlor_geometry_and_label_alignment() -> void:
	var scene_res = load(MAIN_SCENE_PATH)
	var instance = scene_res.instantiate()
	add_child_autoqfree(instance)
	var geom = instance.get_node_or_null("HouseGeometry")
	assert_not_null(geom)

	var floor_node: CSGBox3D = geom.get_node_or_null("ParlorFloor") as CSGBox3D
	assert_not_null(floor_node)
	assert_eq(floor_node.size.z, 6.0, "Parlor floor depth should be 6.0m")

	var ceiling_node: CSGBox3D = geom.get_node_or_null("ParlorCeiling") as CSGBox3D
	assert_not_null(ceiling_node)
	assert_eq(ceiling_node.size.z, 6.0, "Parlor ceiling depth should be 6.0m")

	var west_wall: CSGBox3D = geom.get_node_or_null("ParlorWestWall") as CSGBox3D
	assert_not_null(west_wall)
	assert_eq(west_wall.size.z, 6.0, "Parlor west wall depth should be 6.0m")

	var south_wall: CSGBox3D = geom.get_node_or_null("ParlorSouthWall") as CSGBox3D
	assert_not_null(south_wall)
	assert_eq(south_wall.position.z, 0.0, "Parlor south wall should be flush at Z=0.0")

	var north_wall: CSGBox3D = geom.get_node_or_null("ParlorNorthWall") as CSGBox3D
	assert_not_null(north_wall)
	assert_eq(north_wall.position.z, -6.0, "Parlor north wall should be flush at Z=-6.0")

	var parlor_2: Node3D = instance.get_node_or_null("PortraitSystem/Painting_Parlor_2") as Node3D
	assert_not_null(parlor_2)
	assert_almost_eq(parlor_2.position.z, -5.85, 0.05, "Painting_Parlor_2 should be mounted on Z=-6.0 wall")

	var presentation = instance.get_node_or_null("HousePresentation")
	assert_not_null(presentation)
	var parlor_label: Label3D = presentation.get_node_or_null("PARLORLabel") as Label3D
	assert_not_null(parlor_label)
	assert_almost_eq(parlor_label.position.z, -3.0, 0.1, "PARLOR label should be centered over Z=-3.0 doorway")
	assert_almost_eq(parlor_label.position.x, -2.95, 0.1, "PARLOR label should be on Entry Hall face of wall")

	var study_label: Label3D = presentation.get_node_or_null("STUDYLabel") as Label3D
	assert_not_null(study_label)
	assert_almost_eq(study_label.position.z, -3.0, 0.1, "STUDY label should be centered over Z=-3.0 doorway")
	assert_almost_eq(study_label.position.x, 2.95, 0.1, "STUDY label should be on Entry Hall face of wall")

