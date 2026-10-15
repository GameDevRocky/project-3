extends GutTest

const COORDINATOR_PATH := "res://systems/core/game_coordinator.gd"
const PlayerControllerScene = preload("res://systems/player/player_controller.tscn")
const ElectricalSystemScene = preload("res://systems/electrical/electrical_system.tscn")
const GhostMonsterScene = preload("res://systems/ghost/ghost_monster.tscn")

func test_startup_breaker_advances_to_packing_and_wakes_ghost() -> void:
	var coordinator: Node = _make_coordinator()
	if coordinator == null:
		return
	var player: PlayerController = PlayerControllerScene.instantiate()
	var electrical: ElectricalSystem = ElectricalSystemScene.instantiate()
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	add_child_autoqfree(player)
	add_child_autoqfree(electrical)
	add_child_autoqfree(ghost)
	coordinator.bind_systems(player, electrical, null, ghost, null, null)

	assert_eq(coordinator.phase, 0)
	coordinator.begin_packing()
	assert_eq(coordinator.phase, 1)
	assert_eq(ghost.get_ghost_state().mode, GameTypes.GhostMode.FREE_ROAM)

func test_four_unique_boxes_advance_to_portrait_objective() -> void:
	var coordinator: Node = _make_coordinator()
	if coordinator == null:
		return
	coordinator.begin_packing()
	coordinator.record_packed_item(GameTypes.CarriedItemType.BOX_LIVING_ROOM)
	coordinator.record_packed_item(GameTypes.CarriedItemType.BOX_LIVING_ROOM)
	coordinator.record_packed_item(GameTypes.CarriedItemType.BOX_DINING_ROOM)
	coordinator.record_packed_item(GameTypes.CarriedItemType.BOX_STUDY)
	assert_eq(coordinator.phase, 1, "A duplicate box cannot advance the objective")
	coordinator.record_packed_item(GameTypes.CarriedItemType.BOX_BASEMENT)
	assert_eq(coordinator.phase, 2)
	assert_eq(coordinator.get_packed_box_count(), 4)
	assert_true(coordinator.get_objective_text().contains("Take the family portrait"))

func test_portrait_pickup_starts_blackout_climax() -> void:
	var coordinator: Node = _make_coordinator()
	if coordinator == null:
		return
	var player: PlayerController = PlayerControllerScene.instantiate()
	var electrical: ElectricalSystem = ElectricalSystemScene.instantiate()
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	add_child_autoqfree(player)
	add_child_autoqfree(electrical)
	add_child_autoqfree(ghost)
	coordinator.bind_systems(player, electrical, null, ghost, null, null)
	coordinator.begin_packing()
	for item_type: GameTypes.CarriedItemType in [GameTypes.CarriedItemType.BOX_LIVING_ROOM, GameTypes.CarriedItemType.BOX_DINING_ROOM, GameTypes.CarriedItemType.BOX_STUDY, GameTypes.CarriedItemType.BOX_BASEMENT]:
		coordinator.record_packed_item(item_type)

	coordinator.begin_portrait_climax()
	assert_true(coordinator.climax_started)
	assert_eq(electrical.breaker_state, GameTypes.BreakerState.TRIPPED)
	assert_eq(ghost.get_ghost_state().mode, GameTypes.GhostMode.FREE_ROAM)

func test_safe_portrait_wins_and_occupied_portrait_loses() -> void:
	var winning: Node = _make_coordinator()
	if winning == null:
		return
	winning.phase = 2
	winning.finish_portrait(true)
	assert_eq(winning.phase, 3)
	assert_true(winning.is_game_over())

	var losing: Node = _make_coordinator()
	if losing == null:
		return
	losing.phase = 2
	losing.finish_portrait(false)
	assert_eq(losing.phase, 4)
	assert_true(losing.is_game_over())

func test_room_entry_updates_player_and_ghost_room_state() -> void:
	var coordinator: Node = _make_coordinator()
	if coordinator == null:
		return
	var player: PlayerController = PlayerControllerScene.instantiate()
	var ghost: GhostMonster = GhostMonsterScene.instantiate()
	add_child_autoqfree(player)
	add_child_autoqfree(ghost)
	coordinator.update_entity_room(player, GameTypes.RoomId.STUDY)
	coordinator.update_entity_room(ghost, GameTypes.RoomId.PARLOR)
	assert_eq(player.current_room, GameTypes.RoomId.STUDY)
	assert_eq(ghost.current_room, GameTypes.RoomId.PARLOR)

func _make_coordinator() -> Node:
	var script_resource: Script = load(COORDINATOR_PATH) as Script
	assert_not_null(script_resource, "GameCoordinator script must exist")
	if script_resource == null:
		return null
	var coordinator: Node = script_resource.new()
	add_child_autoqfree(coordinator)
	return coordinator
