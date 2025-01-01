extends Node2D

@onready var blocks: TileMapLayer = $Blocks
@onready var selector: TileMapLayer = $Selector
@onready var mouse_pos: Label = $CanvasLayer/MousePos
@onready var territory: TileMapLayer = $territory

@onready var ui: CanvasLayer = $"../UI"

@export var cell_range: Rect2i

var _is_selected: bool = false
var selectable: bool:
	set(value):
		selectable = value
		if value:
			ui.update_placeholder(true)
			selector.material.set_shader_parameter("to", Color(1,1,0))
		else:
			ui.update_placeholder(false)
			selector.material.set_shader_parameter("to", Color(0.5,0.5,0.5))

var selected_cell: Vector2i

func _ready() -> void:
	# _debug_show_coord()
	cell_range = $"../MapMgr".area
	EventBus.subscribe("camera_focus_on", camera_focus_on)

# func _debug_show_coord():
# 	for i in range(20):
# 		for j in range(20):
# 			var l = Label.new()
# 			var a = HexGridTool._oddr_to_axial(Vector2i(i,j))
# 			var d = HexGridTool.oddr_distance(Vector2i(0,0), Vector2i(i,j))
# 			l.text = "%d, %d (%d)\n/%d,%d/" % [i,j,d, a.x,a.y]
# 			get_node("Control").add_child(l)
# 			l.position = blocks.map_to_local(Vector2i(i,j)) - Vector2(16,16)

var mouse_pos_in_map: Vector2i

func _process(_delta: float) -> void:
	# mouse position in tilemap
	mouse_pos_in_map = blocks.local_to_map(get_local_mouse_position())
	mouse_pos.text = str(mouse_pos_in_map)
	if not _is_selected:
		update_selector(mouse_pos_in_map)
		curr_housing = get_cell_housing(mouse_pos_in_map)
		if cell_range.has_point(mouse_pos_in_map):
			selectable = true
		else:
			selectable = false

func update_selector(pos: Vector2i):
	selector.clear()
	selector.set_cell(pos, 6, Vector2i(7,7))


signal cell_selected(pos: Vector2)

func _on_cell_selected(cell: Vector2i) -> void:
	_is_selected = true
	selected_cell = cell
	print("cell selected: ", cell)
	$Selected.clear()
	selector.clear()
	$Selected.set_cell(cell, 0, Vector2i(7, 15))
	curr_housing = get_cell_housing(mouse_pos_in_map)
	cell_selected.emit(blocks.map_to_local(cell+Vector2i(1,0)))
	ui.open_side_panel(selected_cell)

signal cell_deselected
func clear_selected() -> void:
	$Selected.clear()
	_is_selected = false
	curr_housing = -1

func camera_focus_on(data: Array):
	var loc = data[0]
	_on_cell_selected(loc)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not cell_range.has_point(mouse_pos_in_map):
				return
			_is_selected = true
			_on_cell_selected(mouse_pos_in_map)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cell_deselected.emit()

var curr_housing: int = 0:
	set(value):
		if value != curr_housing:
			curr_housing = value
			housing_changed.emit(value)
signal housing_changed(housing: int)

func get_cell_housing(cell: Vector2i) -> int:
	var data: TileData = territory.get_cell_tile_data(cell)
	if data:
		return data.get_custom_data("housing")
	else:
		return 11

func draw_outposts(list: Array[OutpostDM.Outpost]):
	$Outposts.clear()
	for o in list:
		var loc = o.location
		$Outposts.set_cell(loc, 1, Vector2i.ZERO, 1)
		print("draw in %s" % (str(loc)))
