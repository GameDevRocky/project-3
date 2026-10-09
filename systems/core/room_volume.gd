class_name RoomVolume
extends Area3D

## Emitted when an entity (Player, Monster, or Prop) enters this room volume
signal room_entered(body: Node3D, room_id: GameTypes.RoomId)

## Emitted when an entity exits this room volume
signal room_exited(body: Node3D, room_id: GameTypes.RoomId)

@export var room_id: GameTypes.RoomId = GameTypes.RoomId.ENTRY_HALL

func _ready() -> void:
	# Ensure collision layer 5 (room_triggers) is set
	collision_layer = 16 # Layer 5
	collision_mask = 6   # Layer 2 (Player) | Layer 3 (Monster)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	room_entered.emit(body, room_id)

func _on_body_exited(body: Node3D) -> void:
	room_exited.emit(body, room_id)
