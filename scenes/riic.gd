extends Node2D

@onready var elevator: GridContainer = $UI/GridContainer
@onready var camera: Camera2D = $Camera2D
@onready var side_panel: PanelContainer = $UI/PanelContainer
@onready var warehouse: Warehouse = $Warehouse

enum L {
	BOARD,
	UPPER,
	LOWER
}

var current_layer: L = 0
var prev_camera_pos: Vector2 = Vector2(576,328)
var prev_camera_zoom: Vector2 = Vector2(0.8, 0.8)
var is_zoomin: bool = false

var loc_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_signal_connection()
	for layer in %Layers.get_children():
		layer.child_order_changed.connect(update_signal_connection)


func reg_depot():
	Global.game.res_mgr.register_depot(warehouse)
	loc_id = Global.game.res_mgr.get_depot_idx(warehouse)

func update_signal_connection():
	for layer in %Layers.get_children():
		var entities = layer.get_children()
		if entities.size() > 0:
			for e in entities:
				if not e.building_selected.is_connected(on_building_selected):
					e.building_selected.connect(on_building_selected)

func on_building_selected(built: BaseBuilding):
	# print(built.position)
	elevator.hide()
	if not is_zoomin:
		prev_camera_pos = camera.position
		prev_camera_zoom = camera.zoom
		is_zoomin = true
	camera.position.y = built.position.y + 120
	camera.position.x = built.position.x + 280
	#camera.zoom = Vector2(1.5, 1.5)
	UITweens.set_tween(camera, 'zoom', Vector2(1.5, 1.5), 0.2)
	side_panel.side_panel_opened.emit(built, loc_id)
	print('camera moved to ', camera.position)


func camera_reset():
	camera.position = prev_camera_pos
	#camera.zoom = prev_camera_zoom
	UITweens.set_tween(camera, 'zoom', prev_camera_zoom, 0.2)
	#print('camera pos ', camera.position)
	is_zoomin = false


func _on_button_pressed() -> void:
	camera_reset()
	elevator.show()


func _on_panel_container_side_panel_closed() -> void:
	camera_reset()
	elevator.show()


func _on_button_2_pressed() -> void:
	warehouse.add_item(Global.items[2], 10)


func debug_update_inventory(_item: Item, _amount: int):
	var entities = %debug_invent.get_children()
	if entities.size() > 0:
		for e in entities:
			e.queue_free()
	if warehouse.inventory.size() != 0:
		for item in warehouse.inventory:
			if warehouse.inventory[item] == 0:
				continue
			var ITEM_SLOT = preload("res://scenes/gui/components/item_slot.tscn").instantiate()
			ITEM_SLOT.item = item
			ITEM_SLOT.amount = warehouse.inventory[item]
			%debug_invent.add_child(ITEM_SLOT)
			


func _on_button_3_pressed() -> void:
	AudioMgr.play_random_bgm()
