class_name GameCoordinator
extends Node

const GameTypes = preload("res://systems/shared/game_types.gd")

enum Phase {
	STARTUP,
	PACKING,
	PORTRAIT,
	WON,
	LOST,
}

signal objective_updated(text: String)
signal game_finished(won: bool, message: String)
signal climax_began()

var phase: Phase = Phase.STARTUP
var climax_started: bool = false
var ending_message: String = ""

var _packed_boxes: Dictionary[int, bool] = {}
var _player: PlayerController = null
var _electrical: ElectricalSystem = null
var _portraits: PortraitSystem = null
var _ghost: GhostMonster = null
var _trunk: CarTrunk = null
var _breaker: BreakerPanel = null

func _ready() -> void:
	add_to_group("game_coordinator")
	add_to_group("mcp_watch")
	call_deferred("_wire_scene")

func _unhandled_input(event: InputEvent) -> void:
	if is_game_over() and event.is_action_pressed("interact") and get_tree() != null:
		get_tree().reload_current_scene()

func bind_systems(player: PlayerController, electrical: ElectricalSystem, portraits: PortraitSystem, ghost: GhostMonster, trunk: CarTrunk, breaker: BreakerPanel) -> void:
	_disconnect_systems()
	_player = player
	_electrical = electrical
	_portraits = portraits
	_ghost = ghost
	_trunk = trunk
	_breaker = breaker
	_connect_systems()
	if _ghost != null and _player != null:
		_ghost.set_target_player(_player)
	objective_updated.emit(get_objective_text())

func begin_packing() -> void:
	if phase != Phase.STARTUP:
		return
	phase = Phase.PACKING
	if _ghost != null:
		_ghost.set_monster_dormant(false)
	objective_updated.emit(get_objective_text())

func record_packed_item(item_type: GameTypes.CarriedItemType) -> void:
	if phase != Phase.PACKING or item_type < GameTypes.CarriedItemType.BOX_LIVING_ROOM or item_type > GameTypes.CarriedItemType.BOX_BASEMENT:
		return
	_packed_boxes[item_type] = true
	if _packed_boxes.size() >= 4:
		phase = Phase.PORTRAIT
	objective_updated.emit(get_objective_text())

func begin_portrait_climax() -> void:
	if phase != Phase.PORTRAIT or climax_started:
		return
	climax_started = true
	if _electrical != null:
		_electrical.trip_breaker()
	if _ghost != null:
		_ghost.set_monster_dormant(false)
	climax_began.emit()
	objective_updated.emit(get_objective_text())

func finish_portrait(was_safe: bool) -> void:
	if phase != Phase.PORTRAIT:
		return
	if was_safe:
		phase = Phase.WON
		ending_message = "ESCAPED\n\nYou successfully packed all your belongings, contained the shadows within the walls, and left the family home behind safely as the new dawn breaks."
	else:
		phase = Phase.LOST
		ending_message = "YOU BROUGHT IT WITH YOU\n\nYou loaded the family portrait into the car trunk, unaware the entity was trapped inside the canvas. As you drive away into the night, whispered breaths echo from the back seat."
	if _player != null:
		_player.velocity = Vector3.ZERO
		_player.set_physics_process(false)
	game_finished.emit(was_safe, ending_message)
	objective_updated.emit(get_objective_text())

func lose_to_ghost() -> void:
	if is_game_over():
		return
	phase = Phase.LOST
	ending_message = "THE DARKNESS TOOK YOU\n\nYou were caught in the dark before you could finish packing. The house claims another tenant, and your final portrait joins the gallery on the wall.\n\nPress E to try again."
	if get_tree() != null:
		get_tree().call_group("game_hud", "trigger_jumpscare_flash")
	if _player != null:
		_player.velocity = Vector3.ZERO
		_player.set_physics_process(false)
	game_finished.emit(false, ending_message)
	objective_updated.emit(get_objective_text())

func update_entity_room(body: Node3D, room_id: GameTypes.RoomId) -> void:
	if body is PlayerController:
		(body as PlayerController).current_room = room_id
	elif body is GhostMonster:
		(body as GhostMonster).current_room = room_id

func get_packed_box_count() -> int:
	return _packed_boxes.size()

func can_pack_boxes() -> bool:
	return phase == Phase.PACKING

func can_take_family_portrait() -> bool:
	return phase == Phase.PORTRAIT and not is_game_over()

func is_game_over() -> bool:
	return phase == Phase.WON or phase == Phase.LOST

func get_objective_text() -> String:
	match phase:
		Phase.STARTUP:
			return "OBJECTIVE\nFlip the breaker in the basement"
		Phase.PACKING:
			return "OBJECTIVE — PACK THE CAR\n%s Living Room Box\n%s Dining Room Box\n%s Study Box\n%s Basement Box" % [
				_box_mark(GameTypes.CarriedItemType.BOX_LIVING_ROOM),
				_box_mark(GameTypes.CarriedItemType.BOX_DINING_ROOM),
				_box_mark(GameTypes.CarriedItemType.BOX_STUDY),
				_box_mark(GameTypes.CarriedItemType.BOX_BASEMENT),
			]
		Phase.PORTRAIT:
			return "FINAL OBJECTIVE\n%s" % ("Escape to the car — it is coming" if climax_started else "Take the family portrait")
		Phase.WON:
			return "ESCAPED"
		Phase.LOST:
			return "FAILED"
	return ""

func _wire_scene() -> void:
	var root: Node = get_parent()
	if root == null:
		return
	var player: PlayerController = root.get_node_or_null("PlayerController") as PlayerController
	var electrical: ElectricalSystem = root.get_node_or_null("ElectricalSystem") as ElectricalSystem
	var portraits: PortraitSystem = root.get_node_or_null("PortraitSystem") as PortraitSystem
	var ghost: GhostMonster = root.get_node_or_null("GhostMonster") as GhostMonster
	var trunk: CarTrunk = get_tree().get_first_node_in_group("car_trunk") as CarTrunk if get_tree() != null else null
	var breaker: BreakerPanel = get_tree().get_first_node_in_group("breaker_panel") as BreakerPanel if get_tree() != null else null
	bind_systems(player, electrical, portraits, ghost, trunk, breaker)
	var room_container: Node = root.get_node_or_null("RoomVolumes")
	if room_container != null:
		for child: Node in room_container.get_children():
			if child is RoomVolume and not (child as RoomVolume).room_entered.is_connected(_on_room_entered):
				(child as RoomVolume).room_entered.connect(_on_room_entered)

func _connect_systems() -> void:
	if _player != null:
		if not _player.item_packed.is_connected(record_packed_item):
			_player.item_packed.connect(record_packed_item)
		if not _player.carried_item_changed.is_connected(_on_carried_item_changed):
			_player.carried_item_changed.connect(_on_carried_item_changed)
		if not _player.player_died.is_connected(lose_to_ghost):
			_player.player_died.connect(lose_to_ghost)
	if _breaker != null and not _breaker.breaker_interacted.is_connected(_on_breaker_interacted):
		_breaker.breaker_interacted.connect(_on_breaker_interacted)
	if _trunk != null and not _trunk.family_portrait_deposited.is_connected(finish_portrait):
		_trunk.family_portrait_deposited.connect(finish_portrait)

func _disconnect_systems() -> void:
	if _player != null:
		if _player.item_packed.is_connected(record_packed_item):
			_player.item_packed.disconnect(record_packed_item)
		if _player.carried_item_changed.is_connected(_on_carried_item_changed):
			_player.carried_item_changed.disconnect(_on_carried_item_changed)
		if _player.player_died.is_connected(lose_to_ghost):
			_player.player_died.disconnect(lose_to_ghost)
	if _breaker != null and _breaker.breaker_interacted.is_connected(_on_breaker_interacted):
		_breaker.breaker_interacted.disconnect(_on_breaker_interacted)
	if _trunk != null and _trunk.family_portrait_deposited.is_connected(finish_portrait):
		_trunk.family_portrait_deposited.disconnect(finish_portrait)

func _on_breaker_interacted(_new_state: GameTypes.BreakerState) -> void:
	if phase == Phase.STARTUP:
		begin_packing()

func _on_carried_item_changed(item_type: GameTypes.CarriedItemType) -> void:
	if item_type == GameTypes.CarriedItemType.FAMILY_PORTRAIT:
		begin_portrait_climax()

func _on_room_entered(body: Node3D, room_id: GameTypes.RoomId) -> void:
	update_entity_room(body, room_id)

func _box_mark(item_type: GameTypes.CarriedItemType) -> String:
	return "[x]" if _packed_boxes.has(item_type) else "[ ]"

func _mcp_state() -> Dictionary:
	return {
		"phase": phase,
		"packed_boxes": get_packed_box_count(),
		"climax_started": climax_started,
		"game_over": is_game_over(),
		"ending": ending_message,
	}
