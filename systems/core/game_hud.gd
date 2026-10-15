class_name GameHUD
extends CanvasLayer

var _coordinator: GameCoordinator = null
var _player: PlayerController = null
var _objective_label: Label = null
var _prompt_label: Label = null
var _stamina_bar: ProgressBar = null
var _overlay: ColorRect = null
var _ending_label: Label = null

func _ready() -> void:
	layer = 20
	add_to_group("game_hud")
	_build_interface()
	call_deferred("_resolve_dependencies")

func _process(_delta: float) -> void:
	if _coordinator == null or not is_instance_valid(_coordinator) or _player == null or not is_instance_valid(_player):
		_resolve_dependencies()
	if _coordinator != null and _objective_label != null:
		_objective_label.text = _coordinator.get_objective_text()
	if _player != null:
		if _prompt_label != null:
			_prompt_label.text = _player.get_interaction_prompt()
		if _stamina_bar != null:
			_stamina_bar.value = _player.get_stamina_ratio() * 100.0
	if _coordinator != null and _overlay != null:
		_overlay.visible = _coordinator.is_game_over()
		if _ending_label != null and _overlay.visible:
			_ending_label.text = "%s\n\nPress E to restart" % _coordinator.ending_message

func _resolve_dependencies() -> void:
	if get_tree() == null:
		return
	_coordinator = get_tree().get_first_node_in_group("game_coordinator") as GameCoordinator
	_player = get_tree().get_first_node_in_group("player") as PlayerController

func _build_interface() -> void:
	var root := Control.new()
	root.name = "Interface"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var objective_panel := PanelContainer.new()
	objective_panel.name = "ObjectivePanel"
	objective_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	objective_panel.position = Vector2(-360.0, 24.0)
	objective_panel.size = Vector2(330.0, 170.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.025, 0.035, 0.88)
	panel_style.border_color = Color(0.58, 0.42, 0.2, 0.85)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	objective_panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(objective_panel)
	_objective_label = Label.new()
	_objective_label.name = "ObjectiveLabel"
	_objective_label.text = "OBJECTIVE\nFlip the breaker in the basement"
	_objective_label.add_theme_font_size_override("font_size", 20)
	_objective_label.add_theme_color_override("font_color", Color(0.94, 0.86, 0.68))
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_panel.add_child(_objective_label)

	var crosshair := Label.new()
	crosshair.name = "Crosshair"
	crosshair.text = "+"
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crosshair.add_theme_font_size_override("font_size", 24)
	crosshair.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78, 0.9))
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-16.0, -16.0)
	crosshair.size = Vector2(32.0, 32.0)
	root.add_child(crosshair)

	_prompt_label = Label.new()
	_prompt_label.name = "InteractionPrompt"
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.add_theme_font_size_override("font_size", 22)
	_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.72))
	_prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt_label.position = Vector2(-300.0, -92.0)
	_prompt_label.size = Vector2(600.0, 44.0)
	root.add_child(_prompt_label)

	var stamina_label := Label.new()
	stamina_label.text = "STAMINA"
	stamina_label.position = Vector2(30.0, 648.0)
	stamina_label.add_theme_font_size_override("font_size", 14)
	root.add_child(stamina_label)
	_stamina_bar = ProgressBar.new()
	_stamina_bar.name = "StaminaBar"
	_stamina_bar.position = Vector2(30.0, 674.0)
	_stamina_bar.size = Vector2(220.0, 18.0)
	_stamina_bar.show_percentage = false
	_stamina_bar.value = 100.0
	var stamina_background := StyleBoxFlat.new()
	stamina_background.bg_color = Color(0.08, 0.09, 0.12, 0.88)
	stamina_background.corner_radius_top_left = 4
	stamina_background.corner_radius_top_right = 4
	stamina_background.corner_radius_bottom_left = 4
	stamina_background.corner_radius_bottom_right = 4
	var stamina_fill := StyleBoxFlat.new()
	stamina_fill.bg_color = Color(0.72, 0.56, 0.3, 0.95)
	stamina_fill.corner_radius_top_left = 4
	stamina_fill.corner_radius_top_right = 4
	stamina_fill.corner_radius_bottom_left = 4
	stamina_fill.corner_radius_bottom_right = 4
	_stamina_bar.add_theme_stylebox_override("background", stamina_background)
	_stamina_bar.add_theme_stylebox_override("fill", stamina_fill)
	root.add_child(_stamina_bar)

	_overlay = ColorRect.new()
	_overlay.name = "EndingOverlay"
	_overlay.color = Color(0.015, 0.01, 0.018, 0.93)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	root.add_child(_overlay)
	_ending_label = Label.new()
	_ending_label.name = "EndingLabel"
	_ending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ending_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ending_label.add_theme_font_size_override("font_size", 36)
	_ending_label.add_theme_color_override("font_color", Color(0.92, 0.78, 0.62))
	_ending_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(_ending_label)
