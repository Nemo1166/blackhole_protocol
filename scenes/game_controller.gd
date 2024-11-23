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
	%MainMenu.start_new_game.connect(start_new_game)



func start_new_game() -> void:
	var world = preload("res://scenes/world.tscn").instantiate()
	# print(typeof(world))
	world_2d.add_child(world)
	$GUI.hide()
