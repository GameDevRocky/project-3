class_name PlayerState
extends RefCounted
## Read-only snapshot of player state.

var room_id: GameTypes.RoomId = GameTypes.RoomId.EXTERIOR_DRIVEWAY
var position: Vector3 = Vector3.ZERO
var carried_item: GameTypes.CarriedItemType = GameTypes.CarriedItemType.NONE
var is_alive: bool = true
var boxes_packed_count: int = 0
