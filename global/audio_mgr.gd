extends Node

@export var bgm_list: Array[AudioStream]
@export var sfx_list: Array[AudioStream]

@onready var bgm_player: AudioStreamPlayer = $BGMAudioStreamPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXAudioStreamPlayer

func _ready() -> void:
	update_volume()
	await get_tree().create_timer(1).timeout
	play_random_bgm()

var volume: Vector2 = Vector2(0, 0) # bgm, sfx

func update_volume() -> void:
	volume.x = AudioServer.get_bus_volume_db(AudioServer.get_bus_index('bgm'))
	volume.y = AudioServer.get_bus_volume_db(AudioServer.get_bus_index('sfx'))

#region player mgmt

func play_bgm(index: int) -> void:
	if bgm_player.playing:
		var tween_out: Tween = create_tween()
		tween_out.tween_property(bgm_player, "volume_db", -80, 2)
		await tween_out.finished
		bgm_player.stop()
	bgm_player.stream = bgm_list[index]
	bgm_player.volume_db = -80
	bgm_player.play()
	var tween_in: Tween = create_tween()
	tween_in.tween_property(bgm_player, "volume_db", volume.y, 1)

func play_random_bgm() -> void:
	play_bgm(randi_range(0, bgm_list.size() - 1))

func _on_bgm_finished() -> void:
	play_random_bgm()

func toggle_bgm_effect(flag: bool) -> void:
	var bgm_bus_idx = AudioServer.get_bus_index('bgm')
	for fx_index in range(AudioServer.get_bus_effect_count(bgm_bus_idx)):
		AudioServer.set_bus_effect_enabled(bgm_bus_idx, fx_index, flag)

func play_sfx(index: int) -> void:
	if sfx_player.playing:
		var new_sfx_player: AudioStreamPlayer = sfx_player.duplicate()
		new_sfx_player.stream = sfx_list[index]
		new_sfx_player.finished.connect(clear_sfx_player.bind(new_sfx_player))
		add_child(new_sfx_player)
		new_sfx_player.play()
	else:
		sfx_player.stream = sfx_list[index]
		sfx_player.play()

func clear_sfx_player(player: AudioStreamPlayer) -> void:
	player.queue_free()

#region playlist mgmt
