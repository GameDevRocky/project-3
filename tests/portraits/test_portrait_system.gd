extends GutTest

const PaintingScript = preload("res://systems/portraits/portrait_painting.gd")
const RegistryScript = preload("res://systems/portraits/portrait_system.gd")

func test_cover_blocks_entry_and_uncover_restores_eligibility() -> void:
	var registry: PortraitSystem = RegistryScript.new()
	var painting: PortraitPainting = PaintingScript.new()
	painting.portrait_id = &"parlor_01"
	painting.room_id = 1
	registry.add_child(painting)
	add_child(registry)
	assert_true(registry.drape_sheet(&"parlor_01"))
	assert_true(painting.is_covered)
	assert_eq(registry.get_valid_entry_paintings(1).size(), 0)
	assert_false(registry.set_monster_occupied(&"parlor_01", true))
	assert_true(registry.set_painting_active(&"parlor_01", false))
	assert_eq(registry.get_valid_entry_paintings(1).size(), 0)
	assert_true(registry.set_painting_active(&"parlor_01", true))
	assert_true(registry.remove_sheet(&"parlor_01"))
	assert_eq(registry.get_valid_entry_paintings(1).size(), 1)
	registry.queue_free()
	await get_tree().process_frame

func test_only_one_painting_can_claim_the_ghost() -> void:
	var registry: PortraitSystem = RegistryScript.new()
	var first: PortraitPainting = PaintingScript.new()
	first.portrait_id = &"first"
	var second: PortraitPainting = PaintingScript.new()
	second.portrait_id = &"second"
	registry.add_child(first)
	registry.add_child(second)
	add_child(registry)
	assert_true(registry.set_monster_occupied(&"first", true))
	assert_false(registry.set_monster_occupied(&"second", true))
	assert_true(registry.set_monster_occupied(&"first", false))
	assert_true(registry.set_monster_occupied(&"second", true))
	assert_false(first.is_occupied)
	assert_true(second.is_occupied)
	registry.queue_free()
	await get_tree().process_frame

func test_duplicate_ids_are_rejected() -> void:
	var registry: PortraitSystem = RegistryScript.new()
	var first: PortraitPainting = PaintingScript.new()
	first.portrait_id = &"shared_id"
	var duplicate: PortraitPainting = PaintingScript.new()
	duplicate.portrait_id = &"shared_id"
	add_child(registry)
	add_child(first)
	add_child(duplicate)
	assert_true(registry.register_painting(first))
	assert_false(registry.register_painting(duplicate))
	registry.queue_free()
	first.queue_free()
	duplicate.queue_free()
	await get_tree().process_frame

func test_carried_family_portrait_stays_occupied_and_is_unsafe() -> void:
	var registry: PortraitSystem = RegistryScript.new()
	var portrait: PortraitPainting = PaintingScript.new()
	portrait.portrait_id = &"family"
	portrait.is_family_portrait = true
	registry.add_child(portrait)
	add_child(registry)
	var socket := Node3D.new()
	add_child(socket)
	assert_true(registry.set_monster_occupied(&"family", true))
	assert_true(registry.remove_family_portrait(true, socket))
	assert_true(registry.set_monster_occupied(&"family", false))
	assert_true(registry.set_monster_occupied(&"family", true))
	assert_true(portrait.is_occupied)
	assert_true(portrait.is_being_carried)
	assert_false(registry.is_family_portrait_safe_to_remove())
	var drop_parent := Node3D.new()
	add_child(drop_parent)
	assert_true(registry.drop_family_portrait(0, Transform3D(Basis.IDENTITY, Vector3(1, 0, 1)), drop_parent))
	assert_true(portrait.is_occupied)
	assert_false(portrait.is_being_carried)
	registry.queue_free()
	socket.queue_free()
	drop_parent.queue_free()
	await get_tree().process_frame

func test_nearest_query_skips_covered_inactive_and_occupied_frames() -> void:
	var registry: PortraitSystem = RegistryScript.new()
	var covered: PortraitPainting = PaintingScript.new()
	covered.portrait_id = &"covered"
	covered.room_id = 1
	covered.is_covered = true
	var inactive: PortraitPainting = PaintingScript.new()
	inactive.portrait_id = &"inactive"
	inactive.room_id = 1
	inactive.is_active = false
	var available: PortraitPainting = PaintingScript.new()
	available.portrait_id = &"available"
	available.room_id = 1
	available.position = Vector3(3, 0, 0)
	registry.add_child(covered)
	registry.add_child(inactive)
	registry.add_child(available)
	add_child(registry)
	assert_eq(registry.get_valid_entry_paintings(1).size(), 1)
	assert_eq(registry.find_nearest_valid_entry_painting(1, Vector3.ZERO).portrait_id, &"available")
	assert_null(registry.find_nearest_valid_entry_painting(5, Vector3.ZERO))
	registry.queue_free()
	await get_tree().process_frame
