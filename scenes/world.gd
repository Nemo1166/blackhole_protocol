class_name GameWorld extends Node2D

@onready var time_mgr: TimeMgr = $TimeMgr
@onready var res_mgr: ResourceMgr = $ResourceMgr

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game = self
	Global.load_resources()
	print(Global.items)
	$RIIC.reg_depot()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
