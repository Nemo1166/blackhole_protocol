class_name GameController extends Node

@export var world_2d: Node2D
@export var gui: Control

var curr_world_2d: Node2D
var curr_gui: Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_ctrl = self
	curr_gui = %MainMenu
	curr_world_2d = null


func save_settings():
	var cfg = ConfigFile.new()
	cfg.set_value("audio", "volume_master", 
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("master")))
	)
	cfg.set_value("audio", "volume_bgm", 
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("bgm")))
	)
	cfg.set_value("audio", "volume_sfx", 
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx")))
	)
	cfg.set_value("display", "window_mode", DisplayServer.window_get_mode())
	cfg.set_value("graphics", "vsync_mode", DisplayServer.window_get_vsync_mode())

	var err = cfg.save("user://settings.cfg")
	if err != OK:
		print("Error saving settings")


func load_settings() -> bool:
	var cfg = ConfigFile.new()
	var err = cfg.load("user://settings.cfg")
	if err != OK:
		print("Error loading settings")
		return false
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("master"),
		linear_to_db(cfg.get_value("audio", "volume_master", -10))
	)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"),
		linear_to_db(cfg.get_value("audio", "volume_bgm", -10))
	)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"),
		linear_to_db(cfg.get_value("audio", "volume_sfx", -10))
	)
	DisplayServer.window_set_mode(cfg.get_value("display", "window_mode", 0))
	DisplayServer.window_set_vsync_mode(cfg.get_value("graphics", "vsync_mode", 0))
	return true


func start_new_game() -> void:
	var world = preload("res://scenes/world.tscn").instantiate()
	# print(typeof(world))
	world_2d.add_child.call_deferred(world)
	gui.queue_free()
	#curr_gui.queue_free()
	
