extends GutTest

const MAIN_SCENE: PackedScene = preload("res://systems/core/main.tscn")
const GHOST_SCENE: PackedScene = preload("res://systems/ghost/ghost_monster.tscn")

func test_house_paintings_are_registered_unique_and_available_at_start() -> void:
	var main: Node3D = MAIN_SCENE.instantiate() as Node3D
	add_child_autoqfree(main)
	await get_tree().process_frame

	var portraits: PortraitSystem = main.get_node("PortraitSystem") as PortraitSystem
	var expected_counts: Dictionary[int, int] = {
		GameTypes.RoomId.ENTRY_HALL: 2,
		GameTypes.RoomId.PARLOR: 3,
		GameTypes.RoomId.STUDY: 3,
		GameTypes.RoomId.DINING_ROOM: 2,
		GameTypes.RoomId.BASEMENT: 3,
		GameTypes.RoomId.EXTERIOR_DRIVEWAY: 0,
	}
	var seen_ids: Dictionary[StringName, bool] = {}
	var total_count: int = 0

	for room_id: int in expected_counts:
		var room_paintings: Array[PaintingData] = portraits.get_paintings_in_room(room_id)
		assert_eq(room_paintings.size(), expected_counts[room_id], "room %d has its planned painting count" % room_id)
		for painting: PaintingData in room_paintings:
			assert_false(painting.is_covered, "%s starts uncovered" % painting.id)
			assert_true(painting.is_active, "%s starts active" % painting.id)
			assert_false(painting.is_occupied, "%s starts unoccupied" % painting.id)
			assert_false(seen_ids.has(painting.id), "%s has a unique ID" % painting.id)
			seen_ids[painting.id] = true
			total_count += 1
			var painting_node: PortraitPainting = _find_painting(portraits, painting.id)
			assert_not_null(painting_node, "%s is a scene instance" % painting.id)
			if painting_node != null:
				var inward: Vector3 = _room_center(room_id) - painting_node.global_position
				inward.y = 0.0
				assert_gt(painting_node.global_basis.z.normalized().dot(inward.normalized()), 0.7, "%s faces into its room" % painting.id)

	assert_eq(total_count, 13, "the house has 13 registered paintings including the family portrait")
	var basement_options: Array[PaintingData] = portraits.get_valid_entry_paintings(GameTypes.RoomId.BASEMENT)
	assert_eq(basement_options.size(), 3, "the monster's starting room has three eligible paintings")
	var ghost: GhostMonster = main.get_node("GhostMonster") as GhostMonster
	var nearest_basement: PortraitPainting = portraits.find_nearest_valid_entry_painting(ghost.current_room, ghost.global_position)
	assert_not_null(nearest_basement, "the dormant monster can reach an eligible painting in its starting room")
	assert_eq(nearest_basement.room_id, GameTypes.RoomId.BASEMENT)

	var family: PaintingData = portraits.get_family_portrait_data()
	assert_not_null(family, "the final family portrait remains registered")
	assert_true(family.is_family_portrait)
	assert_eq(family.room_id, GameTypes.RoomId.ENTRY_HALL)
	assert_false(family.is_covered)
	assert_true(family.is_active)

func test_ghost_interface_renders_its_mesh_and_transfers_occupancy_between_basement_canvases() -> void:
	var main: Node3D = MAIN_SCENE.instantiate() as Node3D
	add_child_autoqfree(main)
	await get_tree().process_frame

	var portraits: PortraitSystem = main.get_node("PortraitSystem") as PortraitSystem
	var ghost: GhostMonster = main.get_node("GhostMonster") as GhostMonster
	var basement_options: Array[PaintingData] = portraits.get_valid_entry_paintings(GameTypes.RoomId.BASEMENT)
	assert_true(ghost.force_enter_nearest_painting(basement_options), "the Ghost System entry interface can occupy a basement painting")

	var first_id: StringName = ghost.current_painting_id
	var first_painting: PortraitPainting = _find_painting(portraits, first_id)
	assert_not_null(first_painting)
	assert_true(first_painting.is_occupied)

	var first_viewport: SubViewport = first_painting.get_node_or_null("MonsterArtwork") as SubViewport
	assert_not_null(first_viewport, "the occupied painting has an in-canvas render target")
	var canvas: MeshInstance3D = first_painting.get_node("Canvas") as MeshInstance3D
	assert_true(canvas.mesh is QuadMesh, "the artwork uses one centered canvas UV surface")
	var canvas_material: ShaderMaterial = canvas.material_override as ShaderMaterial
	var artwork_texture: Texture2D = canvas_material.get_shader_parameter("monster_artwork_texture") as Texture2D
	assert_true(artwork_texture is ViewportTexture, "the canvas shader uses the rendered monster texture")

	var silhouette: MeshInstance3D = first_viewport.get_node("MonsterArtRoot/MonsterSilhouette") as MeshInstance3D
	var source_ghost: GhostMonster = GHOST_SCENE.instantiate() as GhostMonster
	var source_mesh: MeshInstance3D = source_ghost.get_node("ShadowMesh") as MeshInstance3D
	assert_eq(silhouette.mesh.get_class(), source_mesh.mesh.get_class(), "the artwork uses the actual in-game monster mesh type")
	assert_eq((silhouette.mesh as CapsuleMesh).radius, (source_mesh.mesh as CapsuleMesh).radius)
	assert_eq((silhouette.mesh as CapsuleMesh).height, (source_mesh.mesh as CapsuleMesh).height)
	source_ghost.free()

	ghost._exit_current_painting()
	assert_false(first_painting.is_occupied, "exiting clears the previous painting")
	var next_data: PaintingData = null
	for candidate: PaintingData in portraits.get_valid_entry_paintings(GameTypes.RoomId.BASEMENT):
		if candidate.id != first_id:
			next_data = candidate
			break
	assert_not_null(next_data, "a second basement refuge remains eligible")
	assert_true(ghost.force_enter_nearest_painting([next_data]), "the same entry interface can select the next painting")
	assert_eq(ghost.current_painting_id, next_data.id)
	assert_true(_find_painting(portraits, next_data.id).is_occupied)
	assert_false(first_painting.is_occupied, "the monster is not duplicated in the previous canvas")
	assert_eq(portraits.get_occupied_painting_id(), next_data.id)

	ghost._exit_current_painting()
	assert_false(_find_painting(portraits, next_data.id).is_occupied)

func test_covering_basement_painting_blocks_entry_until_uncovered() -> void:
	var main: Node3D = MAIN_SCENE.instantiate() as Node3D
	add_child_autoqfree(main)
	await get_tree().process_frame

	var portraits: PortraitSystem = main.get_node("PortraitSystem") as PortraitSystem
	var painting: PortraitPainting = portraits.find_nearest_valid_entry_painting(GameTypes.RoomId.BASEMENT, Vector3(-2.0, -3.0, -12.0))
	assert_not_null(painting)
	var painting_id: StringName = painting.portrait_id
	assert_true(portraits.drape_sheet(painting_id), "the painting remains coverable")
	assert_true(painting.is_covered)
	assert_false(portraits.can_enter_painting(painting_id), "a covered canvas is not eligible")
	assert_false(portraits.set_monster_occupied(painting_id, true), "the registry rejects entry while covered")
	assert_true(portraits.remove_sheet(painting_id), "the sheet can be removed")
	assert_true(portraits.can_enter_painting(painting_id), "uncovering restores eligibility")

func _room_center(room_id: int) -> Vector3:
	match room_id:
		GameTypes.RoomId.ENTRY_HALL:
			return Vector3(0.0, 0.0, -3.0)
		GameTypes.RoomId.PARLOR:
			return Vector3(-7.0, 0.0, -3.0)
		GameTypes.RoomId.STUDY:
			return Vector3(6.0, 0.0, -3.0)
		GameTypes.RoomId.DINING_ROOM:
			return Vector3(2.0, 0.0, -9.5)
		GameTypes.RoomId.BASEMENT:
			return Vector3(-2.0, -2.0, -12.0)
	return Vector3.ZERO

func _find_painting(portraits: PortraitSystem, painting_id: StringName) -> PortraitPainting:
	for candidate: Node in get_tree().get_nodes_in_group("portrait_paintings"):
		if candidate is PortraitPainting and (candidate as PortraitPainting).portrait_id == painting_id:
			return candidate as PortraitPainting
	return null