class_name PowerMeterHUD
extends CanvasLayer

const GameTypes = preload("res://systems/shared/game_types.gd")

@export var electrical_system_path: NodePath = NodePath("")

@onready var power_bar: ProgressBar = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/ProgressBar")
@onready var wattage_label: Label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/Header/WattageLabel")
@onready var status_label: Label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/StatusLabel")
@onready var warning_banner: Label = get_node_or_null("WarningBanner")

var _electrical_system: ElectricalSystem = null

func _ready() -> void:
	layer = 10
	_resolve_electrical_system()

func set_electrical_system(system: ElectricalSystem) -> void:
	if _electrical_system != null:
		_disconnect_signals()
	_electrical_system = system
	if _electrical_system != null:
		_connect_signals()
		update_display(_electrical_system.get_current_power(), _electrical_system.max_power)

func _resolve_electrical_system() -> void:
	if _electrical_system != null:
		return
	if not electrical_system_path.is_empty():
		var node = get_node_or_null(electrical_system_path)
		if node is ElectricalSystem:
			set_electrical_system(node)
			return

	var parent = get_parent()
	if parent is ElectricalSystem:
		set_electrical_system(parent)
		return

	var tree := get_tree()
	if tree != null:
		var found = tree.get_first_node_in_group("electrical_system")
		if found is ElectricalSystem:
			set_electrical_system(found)

func _connect_signals() -> void:
	if not _electrical_system.power_meter_updated.is_connected(_on_power_meter_updated):
		_electrical_system.power_meter_updated.connect(_on_power_meter_updated)
	if not _electrical_system.light_state_changed.is_connected(_on_light_state_changed):
		_electrical_system.light_state_changed.connect(_on_light_state_changed)
	if not _electrical_system.breaker_state_changed.is_connected(_on_breaker_state_changed):
		_electrical_system.breaker_state_changed.connect(_on_breaker_state_changed)

func _disconnect_signals() -> void:
	if _electrical_system.power_meter_updated.is_connected(_on_power_meter_updated):
		_electrical_system.power_meter_updated.disconnect(_on_power_meter_updated)
	if _electrical_system.light_state_changed.is_connected(_on_light_state_changed):
		_electrical_system.light_state_changed.disconnect(_on_light_state_changed)
	if _electrical_system.breaker_state_changed.is_connected(_on_breaker_state_changed):
		_electrical_system.breaker_state_changed.disconnect(_on_breaker_state_changed)

func _on_power_meter_updated(current_watts: float, max_watts: float) -> void:
	update_display(current_watts, max_watts)

func _on_light_state_changed(_room_id: GameTypes.RoomId, _new_state: GameTypes.LightState) -> void:
	if _electrical_system != null:
		update_display(_electrical_system.get_current_power(), _electrical_system.max_power)

func _on_breaker_state_changed(_new_state: GameTypes.BreakerState) -> void:
	if _electrical_system != null:
		update_display(_electrical_system.get_current_power(), _electrical_system.max_power)

func update_display(current_watts: float, max_watts: float) -> void:
	if power_bar != null:
		power_bar.max_value = max_watts
		power_bar.value = current_watts

	if wattage_label != null:
		wattage_label.text = "%.1f W / %.0f W" % [current_watts, max_watts]

	var is_tripped := (_electrical_system != null and _electrical_system.breaker_state == GameTypes.BreakerState.TRIPPED)
	var lit_rooms := _electrical_system.get_lit_room_count() if _electrical_system != null else 0

	if is_tripped or current_watts <= 0.0:
		if status_label != null:
			status_label.text = "GRID BLACKOUT"
			status_label.modulate = Color(1.0, 0.3, 0.3)
		if warning_banner != null:
			warning_banner.visible = true
			warning_banner.text = "⚠️ MASTER BREAKER TRIPPED - RESET IN BASEMENT"
		if power_bar != null:
			power_bar.modulate = Color(1.0, 0.2, 0.2)
	elif lit_rooms > 0:
		var drain_rate := lit_rooms * (_electrical_system.drain_rate_per_room if _electrical_system != null else 1.0)
		if status_label != null:
			status_label.text = "DRAINING: -%.1f W/s (%d %s)" % [drain_rate, lit_rooms, "room" if lit_rooms == 1 else "rooms"]
		if warning_banner != null:
			if current_watts < 15.0:
				warning_banner.visible = true
				warning_banner.text = "⚡ LOW VOLTAGE WARNING - GRID OVERLOAD IMMINENT"
			else:
				warning_banner.visible = false

		if power_bar != null:
			if current_watts < 15.0:
				power_bar.modulate = Color(1.0, 0.25, 0.25)
				if status_label != null:
					status_label.modulate = Color(1.0, 0.3, 0.3)
			elif current_watts < 30.0:
				power_bar.modulate = Color(1.0, 0.75, 0.2)
				if status_label != null:
					status_label.modulate = Color(1.0, 0.8, 0.3)
			else:
				power_bar.modulate = Color(0.3, 0.9, 0.5)
				if status_label != null:
					status_label.modulate = Color(0.9, 0.9, 0.9)
	else:
		if status_label != null:
			if current_watts >= max_watts:
				status_label.text = "GRID IDLE (Full Reserve)"
				status_label.modulate = Color(0.8, 0.8, 0.8)
			else:
				var recharge_rate := _electrical_system.recharge_rate if _electrical_system != null else 5.0
				status_label.text = "RECHARGING: +%.1f W/s" % recharge_rate
				status_label.modulate = Color(0.4, 1.0, 0.6)
		if warning_banner != null:
			warning_banner.visible = false
		if power_bar != null:
			power_bar.modulate = Color(0.3, 0.9, 0.5)
