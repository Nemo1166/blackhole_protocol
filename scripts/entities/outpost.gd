class_name Outpost extends Node

var title: String = ""
var description: String = ""
var position: Vector2 = Vector2.ZERO
var icon: Texture = null
var buildings: Array = []
var population: int = 0
var max_population: int = 0
var storage: int = 0
var max_storage: int = 0
var storage_items: Dictionary = {}

func _init(_title, _description, _position, _icon, _buildings, _population, _max_population, _max_storage) -> void:
	title = _title
	description = _description
	position = _position
	icon = _icon
	buildings = _buildings
	population = _population
	max_population = _max_population
	max_storage = _max_storage