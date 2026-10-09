class_name GhostState
extends RefCounted
## Read-only snapshot of the monster's runtime state for UI and other systems.

var room_id: GameTypes.RoomId = GameTypes.RoomId.BASEMENT
var position: Vector3 = Vector3.ZERO
var mode: GameTypes.GhostMode = GameTypes.GhostMode.DORMANT
var current_painting_id: StringName = &""
var target_painting_id: StringName = &""
var is_chasing: bool = false
