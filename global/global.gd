extends Node

var game_ctrl: GameController = null
var game: GameWorld
var game_seed: int = 0

var is_init = true

func _ready():
	load_user_config()

#region configurations

func load_user_config():
	var user_config := ConfigFile.new()
	var user_config_path = "user://settings.cfg"
	if user_config.load(user_config_path) == OK:
		# volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(user_config.get_value("audio", "master", 0.8)))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"), linear_to_db(user_config.get_value("audio", "bgm", 0.8)))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear_to_db(user_config.get_value("audio", "sfx", 0.8)))
		# vsync
		DisplayServer.window_set_vsync_mode(1 if user_config.get_value("video", "vsync", true) else 0)
		# max fps
		Engine.max_fps = user_config.get_value("video", "max_fps", 60)
		print("User config loaded")
	else:
		print("User config not found")
		return null

func save_user_config():
	var user_config := ConfigFile.new()
	var user_config_path = "user://settings.cfg"
	# volume
	user_config.set_value("audio", "master", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	user_config.set_value("audio", "bgm", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("bgm"))))
	user_config.set_value("audio", "sfx", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx"))))
	# vsync
	user_config.set_value("video", "vsync", DisplayServer.window_get_vsync_mode() == 1)
	# max fps
	user_config.set_value("video", "max_fps", Engine.max_fps)
	# save
	user_config.save(user_config_path)
	print("User config saved to ", user_config_path)


#region common prefabs

const ITEM_DESC_PANEL = preload("res://scenes/gui/components/item_desc_panel.tscn")
const DIALOG_PANEL = preload("res://scenes/gui/components/dialog_panel.tscn")
const MESSAGE_BOX = preload("res://scenes/gui/components/message_box.tscn")

#region common functions

func set_seed(value: int = 0):
	if value == 0:
		game_seed = randi_range(1, 99_9999_9999)
	else:
		game_seed = value
	seed(game_seed)

func close_all_dialog():
	for node in get_tree().get_nodes_in_group("dialog_panel"):
		node.queue_free()

func has_dialog(title: String) -> bool:
	for node in get_tree().get_nodes_in_group("dialog_panel"):
		if node.title.text == title:
			return true
	return false

enum MessageBoxLevel {
	Info,
	Warning,
	Error,
	Check
}

func show_message_box(content: String, level: MessageBoxLevel = MessageBoxLevel.Info, title: String = "Message"):
	var box = MESSAGE_BOX.instantiate()
	get_tree().get_root().add_child(box)
	box.set_content(content)
	box.set_icon(level)
	box.set_title(title)
	box.show()

#region Game data

var items: Dictionary = {}
var recipes: Dictionary = {}
var res_group: Array[ResourceGroup] = [
	load("res://data/items.tres"),
	load("res://data/recipes.tres")
]

func load_resources():
	var i = res_group[0].load_all()
	for item in i:
		items[item.id] = item
	
	var r = res_group[1].load_all()
	for recipe in r:
		recipes[recipe.id] = recipe

func get_item(item_name: String) -> Item:
	for item in items.values():
		if item.name == item_name:
			return item
	return null