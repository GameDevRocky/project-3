class_name GameHUD
extends CanvasLayer

var _coordinator: GameCoordinator = null
var _player: PlayerController = null
var _objective_label: Label = null
var _prompt_label: Label = null
var _stamina_bar: ProgressBar = null
var _overlay: ColorRect = null
var _ending_label: Label = null
var _intro_panel: Control = null
var _notification_label: Label = null
var _jumpscare_rect: ColorRect = null
var _intro_dismissed: bool = false
var _notification_timer: float = 0.0
var _jumpscare_timer: float = 0.0

func _ready() -> void:
	layer = 20
	add_to_group("game_hud")
	_build_interface()
	call_deferred("_resolve_dependencies")

func _unhandled_input(event: InputEvent) -> void:
	if not _intro_dismissed:
		if event.is_action_pressed("interact") or event.is_pressed() and (event is InputEventKey and (event as InputEventKey).keycode == KEY_SPACE or (event as InputEventKey).keycode == KEY_E):
			_intro_dismissed = true
			if _intro_panel != null:
				_intro_panel.visible = false
			get_viewport().set_input_as_handled()
			return

	if _coordinator == null or not is_instance_valid(_coordinator):
		return
	if _coordinator.is_game_over() and event.is_action_pressed("interact") and get_tree() != null:
		get_tree().reload_current_scene()

func _process(delta: float) -> void:
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

	if _notification_timer > 0.0:
		_notification_timer -= delta
		if _notification_timer <= 0.0 and _notification_label != null:
			_notification_label.visible = false

	if _jumpscare_timer > 0.0:
		_jumpscare_timer -= delta
		if _jumpscare_rect != null:
			if _jumpscare_timer <= 0.0:
				_jumpscare_rect.visible = false
			else:
				_jumpscare_rect.visible = true
				var flash_toggle: bool = int(_jumpscare_timer * 15.0) % 2 == 0
				_jumpscare_rect.color = Color(0.9, 0.05, 0.05, 0.85) if flash_toggle else Color(0.05, 0.05, 0.05, 0.9)

func show_notification(message: String, duration: float = 3.5) -> void:
	if _notification_label == null:
		return
	_notification_label.text = message
	_notification_label.visible = true
	_notification_timer = duration

func trigger_jumpscare_flash() -> void:
	_jumpscare_timer = 0.8
	if _jumpscare_rect != null:
		_jumpscare_rect.visible = true

func _resolve_dependencies() -> void:
	if get_tree() == null:
		return
	_coordinator = get_tree().get_first_node_in_group("game_coordinator") as GameCoordinator
	_player = get_tree().get_first_node_in_group("player") as PlayerController
	var electrical: ElectricalSystem = get_tree().get_first_node_in_group("electrical_system") as ElectricalSystem
	var ghost: GhostMonster = get_tree().get_first_node_in_group("ghost") as GhostMonster
	if electrical != null and not electrical.breaker_state_changed.is_connected(_on_breaker_state_changed):
		electrical.breaker_state_changed.connect(_on_breaker_state_changed)
	if ghost != null:
		if not ghost.ghost_moved.is_connected(_on_ghost_moved):
			ghost.ghost_moved.connect(_on_ghost_moved)
		if not ghost.ghost_chase_started.is_connected(_on_ghost_chase_started):
			ghost.ghost_chase_started.connect(_on_ghost_chase_started)

func _on_breaker_state_changed(state: GameTypes.BreakerState) -> void:
	if state == GameTypes.BreakerState.OPERATIONAL:
		show_notification("It has awoken", 4.0)

func _on_ghost_moved(_from: GameTypes.RoomId, _to: GameTypes.RoomId, _mode: GameTypes.GhostMode) -> void:
	show_notification("Something has moved through the shadows...", 3.0)

func _on_ghost_chase_started() -> void:
	show_notification("HE HAS FOUND YOU", 3.0)

func _build_interface() -> void:
	var root := Control.new()
	root.name = "Interface"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Intro Story Overlay
	_intro_panel = Control.new()
	_intro_panel.name = "IntroOverlay"
	_intro_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var intro_bg := ColorRect.new()
	intro_bg.color = Color(0.01, 0.01, 0.015, 0.96)
	intro_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_intro_panel.add_child(intro_bg)

	var center_container := CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_intro_panel.add_child(center_container)

	var intro_box := VBoxContainer.new()
	intro_box.custom_minimum_size = Vector2(760.0, 440.0)
	intro_box.add_theme_constant_override("separation", 24)
	center_container.add_child(intro_box)

	var title_lbl := Label.new()
	title_lbl.text = "THE LAST PORTRAIT"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 38)
	title_lbl.add_theme_color_override("font_color", Color(0.96, 0.88, 0.72))
	intro_box.add_child(title_lbl)

	var story_lbl := Label.new()
	story_lbl.text = "Tomorrow, new rental tenants move into your old family home.\n\nTonight is your final chance to clear out the last four packed moving boxes and your family's heirloom portrait before handing over the keys.\n\nManage your electrical grid, keep your belongings organized, and finish packing before the night is through."
	story_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_lbl.add_theme_font_size_override("font_size", 20)
	story_lbl.add_theme_color_override("font_color", Color(0.82, 0.82, 0.85))
	intro_box.add_child(story_lbl)

	var prompt_lbl := Label.new()
	prompt_lbl.text = "Press E or SPACE to Begin"
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.add_theme_font_size_override("font_size", 22)
	prompt_lbl.add_theme_color_override("font_color", Color(0.95, 0.78, 0.42))
	intro_box.add_child(prompt_lbl)
	root.add_child(_intro_panel)

	# Transient Notification Banner
	var notif_center := CenterContainer.new()
	notif_center.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	notif_center.custom_minimum_size = Vector2(1280.0, 80.0)
	root.add_child(notif_center)

	_notification_label = Label.new()
	_notification_label.name = "NotificationLabel"
	_notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_notification_label.add_theme_font_size_override("font_size", 26)
	_notification_label.add_theme_color_override("font_color", Color(0.98, 0.45, 0.45))
	_notification_label.visible = false
	notif_center.add_child(_notification_label)

	# Objective Panel
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
	var controls_label := Label.new()
	controls_label.name = "ControlsHint"
	controls_label.text = "WASD Move   •   Shift Sprint   •   E / Click Interact   •   Esc Cursor"
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	controls_label.add_theme_font_size_override("font_size", 14)
	controls_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.74, 0.72))
	controls_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	controls_label.position = Vector2(-590.0, -36.0)
	controls_label.size = Vector2(560.0, 24.0)
	root.add_child(controls_label)

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

	# Jumpscare Strobe Flash Overlay
	_jumpscare_rect = ColorRect.new()
	_jumpscare_rect.name = "JumpscareRect"
	_jumpscare_rect.color = Color(0.9, 0.05, 0.05, 0.85)
	_jumpscare_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_jumpscare_rect.visible = false
	root.add_child(_jumpscare_rect)

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
	_ending_label.add_theme_font_size_override("font_size", 30)
	_ending_label.add_theme_color_override("font_color", Color(0.92, 0.78, 0.62))
	_ending_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(_ending_label)
