class_name GameWorld extends Node2D

@onready var time_mgr: TimeMgr = $TimeMgr
@onready var res_mgr: ResourceMgr = $ResourceMgr

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game = self
	Global.load_resources()
	print(Global.items)
	$RIIC.reg_depot()
	#AudioMgr.play_bgm(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print('Pulse menu.')
		const PULSE_MENU = preload("res://scenes/gui/components/pulse_menu.tscn")
		var pulse_menu = PULSE_MENU.instantiate()
		add_child(pulse_menu)
