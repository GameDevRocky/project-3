extends GutTest

const GameTypes = preload("res://systems/shared/game_types.gd")
const RoomVolume = preload("res://systems/core/room_volume.gd")

func test_room_volume_exports_room_id() -> void:
	var rv: RoomVolume = RoomVolume.new()
	assert_not_null(rv)
	assert_eq(rv.room_id, GameTypes.RoomId.ENTRY_HALL, "Default room should be ENTRY_HALL")
	
	rv.room_id = GameTypes.RoomId.PARLOR
	assert_eq(rv.room_id, GameTypes.RoomId.PARLOR, "Should allow updating room_id")
	rv.free()

func test_room_volume_emits_room_entered_signal() -> void:
	var rv: RoomVolume = RoomVolume.new()
	add_child_autoqfree(rv)
	watch_signals(rv)
	
	var mock_body: CharacterBody3D = CharacterBody3D.new()
	add_child_autoqfree(mock_body)
	
	rv._on_body_entered(mock_body)
	assert_signal_emitted(rv, "room_entered")
	assert_signal_emit_count(rv, "room_entered", 1)
	
	rv._on_body_exited(mock_body)
	assert_signal_emitted(rv, "room_exited")
	assert_signal_emit_count(rv, "room_exited", 1)
