class_name Recipe extends Resource

@export var id: int = 0
@export var name: String = ""
@export var type: Type = Type.Other
@export var description: String = ""
@export var ingredients: Dictionary = {}
@export var results: Dictionary = {}
@export var time_in_hour: int = 0 # in hours

enum Type {
	Mining,
	Crafting_L,
	Crafting_H,
	Crafting_P,
	Other,
	NPC
}