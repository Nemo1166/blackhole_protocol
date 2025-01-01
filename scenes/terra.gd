extends GameWorld

var _total_playtime_timer: PlaytimeTimer
var _this_playtime_timer: PlaytimeTimer

@onready var terra: MapMgr = $MapMgr
@onready var map: Node2D = $Map


@onready var ui = $UI

func _ready() -> void:
	Global.set_seed()
	super._ready()
	_total_playtime_timer = PlaytimeManager.try_add_timer("total")
	_this_playtime_timer = PlaytimeManager.try_add_timer("this")
	PlaytimeManager.start_all()
	
	await get_tree().create_timer(1).timeout
	AudioMgr.play_random_bgm()
	
	EventBus.subscribe("show_outpost_list", show_outpost_list)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		open_pause_menu()

func open_pause_menu():
	print('Pulse menu.')
	PlaytimeManager.pause_all()
	const PULSE_MENU = preload("res://scenes/gui/pulse_menu.tscn")
	var pulse_menu = PULSE_MENU.instantiate()
	add_child(pulse_menu)
	pulse_menu.set_play_stat(time_mgr.get_datetime_str(), int(_total_playtime_timer.total_time_sec))

func update_housing_info(index: int) -> void:
	ui.show_housing(index)

func _on_map_cell_deselected() -> void:
	ui.close_side_panel()


func _on_time_changed_delta(delta: int) -> void:
	terra.update(delta)

func show_outpost_list(_data):
	var list = terra.outpost_data
	ui.show_outpost_list(list)
