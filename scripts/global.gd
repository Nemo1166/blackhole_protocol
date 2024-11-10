extends Node

var game_ctrl: GameController = null
var game: Node

var is_init = true

func load_user_config():
	var user_config = ConfigFile.new()
	var user_config_path = "user://config.cfg"
	if user_config.load(user_config_path) == OK:
		print("User config loaded")
		return user_config
	else:
		print("User config not found")
		return null

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
