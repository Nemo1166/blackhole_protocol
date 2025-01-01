class_name GameWorld extends Node2D

@onready var time_mgr: TimeMgr = $TimeMgr

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game = self
	Global.load_resources()
	Global.load_housing_data()
	print(Global.items)
