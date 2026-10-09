class_name PaintingData
extends Resource
## Portrait-owned mirror of the PaintingData fields in docs/CONTRACTS.md.
## room_id uses the shared enum's integer value until systems/shared is available.

@export var id: StringName = &""
@export_range(0, 5) var room_id: int = 0
@export var is_family_portrait: bool = false
@export var is_covered: bool = false
@export var is_active: bool = true
@export var is_occupied: bool = false
@export var global_position: Vector3 = Vector3.ZERO
@export var global_rotation: Vector3 = Vector3.ZERO
@export var is_being_carried: bool = false

func is_entry_eligible() -> bool:
	return is_active and not is_covered and not is_occupied and (not is_being_carried or is_family_portrait)
