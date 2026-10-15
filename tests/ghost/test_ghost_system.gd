extends GutTest

const GhostMonsterScene = preload("res://systems/ghost/ghost_monster.tscn")
const PaintingDataScript = preload("res://systems/portraits/painting_data.gd")

func test_ghost_initial_state_is_dormant() -> void:
	var monster: GhostMonster = GhostMonsterScene.instantiate()
	add_child_autoqfree(monster)
	var state = monster.get_ghost_state()
	assert_eq(state.mode, GameTypes.GhostMode.DORMANT, "Monster should start DORMANT before breaker is flipped")

	monster.set_monster_dormant(false)
	assert_eq(monster.get_ghost_state().mode, GameTypes.GhostMode.FREE_ROAM, "Monster should enter FREE_ROAM when activated")
	monster.queue_free()

func test_ghost_enters_painting_when_forced() -> void:
	var monster: GhostMonster = GhostMonsterScene.instantiate()
	add_child_autoqfree(monster)
	monster.set_monster_dormant(false)

	var p: PaintingData = PaintingDataScript.new()
	p.id = &"parlor_art"
	p.is_active = true
	p.is_covered = false
	p.is_occupied = false

	var success = monster.force_enter_nearest_painting([p])
	assert_true(success, "Monster should successfully enter valid uncovered painting")
	assert_eq(monster.get_ghost_state().mode, GameTypes.GhostMode.PAINTING_BOUND, "Monster mode should be PAINTING_BOUND")
	assert_true(p.is_occupied, "Painting should be marked occupied")
	monster.queue_free()
