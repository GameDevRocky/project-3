extends GutTest

const GhostMonsterScene = preload("res://systems/ghost/ghost_monster.tscn")
const ElectricalSystemScene = preload("res://systems/electrical/electrical_system.tscn")
const PortraitSystemScene = preload("res://systems/portraits/portrait_system.tscn")
const PortraitPaintingScene = preload("res://systems/portraits/portrait_painting.tscn")
const PlayerControllerScene = preload("res://systems/player/player_controller.tscn")

func test_lit_room_occupies_real_painting_and_darkness_releases_it() -> void:
	var world := Node3D.new()
	add_child_autoqfree(world)
	var electrical: ElectricalSystem = ElectricalSystemScene.instantiate()
	electrical.name = "ElectricalSystem"
	world.add_child(electrical)
	var portraits: PortraitSystem = PortraitSystemScene.instantiate()
	portraits.name = "PortraitSystem"
	var painting: PortraitPainting = PortraitPaintingScene.instantiate()
	painting.portrait_id = &"parlor_capture"
	painting.room_id = GameTypes.RoomId.PARLOR
	portraits.add_child(painting)
	world.add_child(portraits)
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	world.add_child(ghost)
	ghost.current_room = GameTypes.RoomId.PARLOR
	ghost.set_monster_dormant(false)

	electrical.set_room_light(GameTypes.RoomId.PARLOR, true)
	ghost._physics_process(0.1)
	assert_eq(ghost.get_ghost_state().mode, GameTypes.GhostMode.PAINTING_BOUND)
	assert_true(painting.is_occupied, "The registered PortraitPainting, not only its data snapshot, must be occupied")

	electrical.set_room_light(GameTypes.RoomId.PARLOR, false)
	ghost._physics_process(0.1)
	assert_eq(ghost.get_ghost_state().mode, GameTypes.GhostMode.FREE_ROAM)
	assert_false(painting.is_occupied)

func test_dark_contact_kills_the_target_player() -> void:
	var world := Node3D.new()
	add_child_autoqfree(world)
	var player: PlayerController = PlayerControllerScene.instantiate()
	world.add_child(player)
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	world.add_child(ghost)
	player.global_position = Vector3.ZERO
	ghost.global_position = Vector3(0.0, 0.0, 0.55)
	ghost.set_monster_dormant(false)

	assert_true(ghost.has_method("set_target_player"))
	if not ghost.has_method("set_target_player"):
		return
	ghost.set_target_player(player)
	ghost._physics_process(0.05)
	assert_false(player.is_alive)

func test_ghost_enters_carried_family_portrait_instead_of_killing_player() -> void:
	var world := Node3D.new()
	add_child_autoqfree(world)
	var portraits: PortraitSystem = PortraitSystemScene.instantiate()
	portraits.name = "PortraitSystem"
	var family: PortraitPainting = PortraitPaintingScene.instantiate()
	family.portrait_id = &"family_portrait"
	family.is_family_portrait = true
	portraits.add_child(family)
	world.add_child(portraits)
	var player: PlayerController = PlayerControllerScene.instantiate()
	world.add_child(player)
	player.boxes_packed_count = 4
	assert_true(player.interact_with_portrait(family))
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	world.add_child(ghost)
	ghost.set_monster_dormant(false)
	ghost.global_position = player.global_position + Vector3(0.0, 0.0, 0.55)

	assert_true(ghost.has_method("set_target_player"))
	if not ghost.has_method("set_target_player"):
		return
	ghost.set_target_player(player)
	ghost._physics_process(0.05)
	assert_true(player.is_alive)
	assert_true(family.is_occupied)
	assert_eq(ghost.get_ghost_state().current_painting_id, &"family_portrait")

func test_roaming_ghost_stops_at_exterior_threshold() -> void:
	var world := Node3D.new()
	add_child_autoqfree(world)
	var player: PlayerController = PlayerControllerScene.instantiate()
	world.add_child(player)
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	world.add_child(ghost)
	player.global_position = Vector3(0.0, 0.0, 8.0)
	ghost.global_position = Vector3(0.0, 0.0, -0.45)
	ghost.set_monster_dormant(false)

	assert_true(ghost.has_method("set_target_player"))
	if not ghost.has_method("set_target_player"):
		return
	ghost.set_target_player(player)
	for index: int in range(20):
		ghost._physics_process(0.1)
	assert_lte(ghost.global_position.z, -0.35, "A roaming ghost cannot cross the front threshold")

func test_ghost_hidden_and_non_colliding_when_dormant() -> void:
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	add_child_autoqfree(ghost)
	assert_true(ghost._dormant)
	assert_false(ghost.shadow_mesh.visible, "Ghost shadow mesh should be hidden when dormant")
	assert_eq(ghost.collision_layer, 0, "Dormant ghost should have no collision layer")
	assert_eq(ghost.collision_mask, 0, "Dormant ghost should have no collision mask")

	ghost.set_monster_dormant(false)
	assert_false(ghost._dormant)
	assert_true(ghost.shadow_mesh.visible, "Active ghost shadow mesh should be visible")
	assert_eq(ghost.collision_layer, 4, "Active ghost should have monster collision layer")
	assert_eq(ghost.collision_mask, 2, "Active ghost should have player collision mask")

func test_ghost_eyes_track_player_and_flare_on_chase() -> void:
	var world := Node3D.new()
	add_child_autoqfree(world)
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	world.add_child(ghost)
	ghost.set_monster_dormant(false)

	var head_pivot: Node3D = ghost.get_node_or_null("ShadowMesh/HeadPivot") as Node3D
	assert_not_null(head_pivot, "Ghost must have HeadPivot under ShadowMesh")
	var eye_left = ghost.get_node_or_null("ShadowMesh/HeadPivot/EyeLeft")
	var eye_right = ghost.get_node_or_null("ShadowMesh/HeadPivot/EyeRight")
	var eye_aura = ghost.get_node_or_null("ShadowMesh/HeadPivot/EyeAura")
	assert_not_null(eye_left, "Ghost must have EyeLeft")
	assert_not_null(eye_right, "Ghost must have EyeRight")
	assert_not_null(eye_aura, "Ghost must have EyeAura OmniLight3D")

	var player: PlayerController = PlayerControllerScene.instantiate()
	world.add_child(player)
	player.global_position = Vector3(4.0, 1.6, 0.0)
	ghost.global_position = Vector3(0.0, 0.0, 0.0)

	ghost.set_target_player(player)
	ghost._physics_process(0.1)

	assert_true(ghost.is_chasing, "Ghost should enter chase when unlit with player in sight")
	assert_true(ghost.is_eyes_flaring(), "Eyes should flare during chase")
	# Check head pivot forward vector (-Z local) points toward player (+X world)
	var forward: Vector3 = -head_pivot.global_transform.basis.z.normalized()
	assert_gt(forward.x, 0.7, "HeadPivot should rotate to face the player")

func test_ghost_wanders_in_darkness_and_chases_when_player_enters_room() -> void:
	var world := Node3D.new()
	add_child_autoqfree(world)
	var electrical: ElectricalSystem = ElectricalSystemScene.instantiate()
	electrical.name = "ElectricalSystem"
	world.add_child(electrical)

	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	world.add_child(ghost)
	ghost.global_position = Vector3(-7.0, 0.2, -3.0)
	ghost.current_room = GameTypes.RoomId.PARLOR
	ghost.set_monster_dormant(false)

	var player: PlayerController = PlayerControllerScene.instantiate()
	world.add_child(player)
	player.global_position = Vector3(0.0, 0.2, -3.0)
	player.current_room = GameTypes.RoomId.ENTRY_HALL
	ghost.set_target_player(player)

	# When player is in a separate room, ghost should be in FREE_ROAM wandering
	ghost._physics_process(0.1)
	assert_eq(ghost.mode, GameTypes.GhostMode.FREE_ROAM, "Ghost should wander in darkness when player is in another room")
	assert_false(ghost.is_chasing, "Ghost should not chase player in another room")
	assert_false(ghost.is_eyes_flaring())

	# When player steps into the same dark room, ghost engages CHASE
	player.global_position = Vector3(-6.0, 0.2, -3.0)
	player.current_room = GameTypes.RoomId.PARLOR
	ghost._physics_process(0.1)
	assert_eq(ghost.mode, GameTypes.GhostMode.CHASE, "Ghost should chase when player enters same dark room")
	assert_true(ghost.is_chasing)
	assert_true(ghost.is_eyes_flaring())



