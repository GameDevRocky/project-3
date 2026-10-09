extends GutTest

const MAIN_SCENE_PATH := "res://systems/core/main.tscn"

func test_portrait_system_and_paintings_in_main_scene() -> void:
	var scene_res = load(MAIN_SCENE_PATH)
	assert_not_null(scene_res, "main.tscn must load")
	var instance = scene_res.instantiate()
	add_child_autoqfree(instance)

	var portrait_sys = instance.get_node_or_null("PortraitSystem")
	assert_not_null(portrait_sys, "PortraitSystem node must exist in main.tscn")
	assert_true(portrait_sys is PortraitSystem, "PortraitSystem must be of type PortraitSystem")

	var valid_paintings = portrait_sys.get_valid_entry_paintings(GameTypes.RoomId.PARLOR)
	assert_gt(valid_paintings.size(), 0, "Parlor must have valid entry paintings")
