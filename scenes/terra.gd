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
	
	build_rhodes()

func build_rhodes():
	var rhodes: OutpostDM.Outpost = terra.build_outpost(20, Vector2i(0,0), "罗德岛")
	rhodes.inventory.add_item(Global.items[4], 1000)
	rhodes.build(OutpostDM.Facilities.Mine.new())
	var mine = rhodes.get_facility("Mine")
	var unit = mine.units[0]
	unit.set_plan(Global.get_recipe("开采铁矿"))
	unit = mine.add_unit(OutpostDM.ProductionUnit.new())
	unit.set_plan(Global.get_recipe("采集木材"))
	unit = mine.add_unit(OutpostDM.ProductionUnit.new())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		open_pause_menu()

func open_pause_menu():
	print('Pulse menu.')
	PlaytimeManager.pause_all()
	const PULSE_MENU = preload("res://scenes/gui/components/pulse_menu.tscn")
	var pulse_menu = PULSE_MENU.instantiate()
	add_child(pulse_menu)
	pulse_menu.set_play_stat(time_mgr.get_datetime_str(), int(_total_playtime_timer.total_time_sec))

func update_housing_info(index: int) -> void:
	ui.show_housing(index)

func _on_map_cell_deselected() -> void:
	ui.close_side_panel()


func _on_time_changed_delta(delta: int) -> void:
	terra.update_outposts(delta)
