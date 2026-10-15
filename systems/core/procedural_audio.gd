class_name ProceduralAudio
extends Node3D

var _unlocked: bool = false
var _ambient_player: AudioStreamPlayer = null
var _cue_player: AudioStreamPlayer = null
var _ghost_player: AudioStreamPlayer3D = null
var _ghost: GhostMonster = null

func _ready() -> void:
	_build_players()
	call_deferred("_connect_gameplay")

func _process(_delta: float) -> void:
	if _ghost != null and is_instance_valid(_ghost) and _ghost_player != null:
		_ghost_player.global_position = _ghost.global_position

func _build_players() -> void:
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.name = "AmbientDrone"
	_ambient_player.volume_db = -27.0
	_ambient_player.stream = _make_wave(46.0, 2.0, 0.13, true, 0.18)
	add_child(_ambient_player)
	_cue_player = AudioStreamPlayer.new()
	_cue_player.name = "InteractionCues"
	_cue_player.volume_db = -11.0
	add_child(_cue_player)
	_ghost_player = AudioStreamPlayer3D.new()
	_ghost_player.name = "GhostCues"
	_ghost_player.volume_db = -5.0
	_ghost_player.max_distance = 24.0
	_ghost_player.unit_size = 4.0
	add_child(_ghost_player)

func _connect_gameplay() -> void:
	if get_tree() == null:
		return
	var player: PlayerController = get_tree().get_first_node_in_group("player") as PlayerController
	_ghost = get_tree().get_first_node_in_group("ghost") as GhostMonster
	var breaker: BreakerPanel = get_tree().get_first_node_in_group("breaker_panel") as BreakerPanel
	var coordinator: GameCoordinator = get_tree().get_first_node_in_group("game_coordinator") as GameCoordinator
	if player != null:
		if not player.interaction_performed.is_connected(_unlock_audio):
			player.interaction_performed.connect(_unlock_audio)
		if not player.item_packed.is_connected(_on_item_packed):
			player.item_packed.connect(_on_item_packed)
		if not player.player_died.is_connected(_on_player_died):
			player.player_died.connect(_on_player_died)
	if breaker != null and not breaker.breaker_interacted.is_connected(_on_breaker):
		breaker.breaker_interacted.connect(_on_breaker)
	if _ghost != null:
		if not _ghost.ghost_entered_painting.is_connected(_on_ghost_entered_painting):
			_ghost.ghost_entered_painting.connect(_on_ghost_entered_painting)
		if not _ghost.ghost_exited_painting.is_connected(_on_ghost_exited_painting):
			_ghost.ghost_exited_painting.connect(_on_ghost_exited_painting)
		if not _ghost.ghost_chase_started.is_connected(_on_ghost_chase):
			_ghost.ghost_chase_started.connect(_on_ghost_chase)
	if coordinator != null:
		if not coordinator.climax_began.is_connected(_on_climax):
			coordinator.climax_began.connect(_on_climax)
		if not coordinator.game_finished.is_connected(_on_game_finished):
			coordinator.game_finished.connect(_on_game_finished)

func _unlock_audio() -> void:
	if _unlocked:
		return
	_unlocked = true
	_ambient_player.play()
	_play_cue(220.0, 0.09, 0.18)

func _on_breaker(_state: GameTypes.BreakerState) -> void:
	_play_cue(72.0, 0.42, 0.5)

func _on_item_packed(_item_type: GameTypes.CarriedItemType) -> void:
	_play_cue(118.0, 0.2, 0.38)

func _on_ghost_entered_painting(_painting_id: StringName) -> void:
	_play_ghost_cue(165.0, 0.48, 0.34, 0.7)

func _on_ghost_exited_painting(_painting_id: StringName) -> void:
	_play_ghost_cue(84.0, 0.6, 0.42, 0.9)

func _on_ghost_chase() -> void:
	_play_ghost_cue(54.0, 0.85, 0.5, 0.45)

func _on_climax() -> void:
	_play_cue(48.0, 1.05, 0.65)

func _on_player_died() -> void:
	_play_cue(39.0, 1.2, 0.8)

func _on_game_finished(won: bool, _message: String) -> void:
	_play_cue(330.0 if won else 42.0, 1.15, 0.55)

func _play_cue(frequency: float, duration: float, amplitude: float) -> void:
	if not _unlocked or _cue_player == null:
		return
	_cue_player.stream = _make_wave(frequency, duration, amplitude, false, 0.32)
	_cue_player.play()

func _play_ghost_cue(frequency: float, duration: float, amplitude: float, noise_mix: float) -> void:
	if not _unlocked or _ghost_player == null:
		return
	_ghost_player.stream = _make_wave(frequency, duration, amplitude, false, noise_mix)
	_ghost_player.play()

func _make_wave(frequency: float, duration: float, amplitude: float, looping: bool, noise_mix: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var sample_count: int = maxi(1, int(duration * sample_rate))
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var random := RandomNumberGenerator.new()
	random.seed = 440
	for sample_index: int in range(sample_count):
		var time_value: float = float(sample_index) / float(sample_rate)
		var envelope: float = 1.0 if looping else minf(1.0, float(sample_count - sample_index) / maxf(1.0, float(sample_count) * 0.18))
		var tone: float = sin(TAU * frequency * time_value) * (1.0 - noise_mix)
		var noise: float = random.randf_range(-1.0, 1.0) * noise_mix
		var value: int = clampi(int((tone + noise) * amplitude * envelope * 32767.0), -32768, 32767)
		bytes.encode_s16(sample_index * 2, value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	if looping:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = sample_count
	return stream
