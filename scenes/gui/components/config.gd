extends Control

const MAX_FPS_LIST = [0, 30, 45, 60, 90, 120, 300]

@onready var vol_master: HScrollBar = $VolMaster/Value
@onready var vol_music: HScrollBar = $VolMusic/Value
@onready var vol_sfx: HScrollBar = $VolSFX/Value
@onready var vsync: CheckButton = $VisVsync/Value
@onready var max_fps: OptionButton = $VisMaxFPS/Value

@export var d : Dictionary = {1:1}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_all()


func init_max_fps() -> void:
	max_fps.clear()
	for fps in MAX_FPS_LIST:
		max_fps.add_item(str(fps))
	max_fps.selected = MAX_FPS_LIST.find(Engine.max_fps)

func reset_all():
	# volume
	vol_master.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	vol_music.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("bgm")))
	vol_sfx.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx")))
	# vsync
	vsync.button_pressed = DisplayServer.window_get_vsync_mode() == 1
	# max fps
	init_max_fps()
	hide()

func _on_vsync_toggled(toggled_on: bool) -> void:
	max_fps.disabled = toggled_on

@onready var vol_master_label: Label = $VolMaster/Label

func _on_vol_master_value_changed(value: float) -> void:
	if value > 0.5:
		vol_master_label.text = "volume-high"
	elif value > 0.01:
		vol_master_label.text = "volume-low"
	else:
		vol_master_label.text = "volume-mute"


func set_config() -> void:
	# volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(vol_master.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"), linear_to_db(vol_music.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear_to_db(vol_sfx.value))
	# vsync
	DisplayServer.window_set_vsync_mode(1 if vsync.pressed else 0)
	# max fps
	if not vsync.pressed:
		Engine.max_fps = MAX_FPS_LIST[max_fps.selected]
	Global.save_user_config()
	hide()
