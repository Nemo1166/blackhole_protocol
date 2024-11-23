extends PanelContainer

@export var title: String = 'Title'
@onready var label_title: Label = %Title
@onready var ctrl_panel: MarginContainer = %CtrlPanel

signal side_panel_closed
signal side_panel_opened(built: BaseBuilding, loc: int)

var is_opened: bool = false
var loc_id: int

func on_panel_show(built: BaseBuilding, loc: int):
	clear_panel()
	if not is_opened:
		# print('viewport ', get_viewport().size)
		UITweens.set_tween(self, "position:x", position.x - size.x, 0.25)
		# print('sidebar moved to ', position)
		is_opened = true
	label_title.text = built.title
	if not built.is_built:
		var ctrl = preload("res://scenes/gui/components/side_panels/building.tscn").instantiate()
		ctrl.building_slot = built
		ctrl.loc_id = loc
		ctrl_panel.add_child(ctrl)
		ctrl.close_sidepanel.connect(_on_close_button_pressed)
		return
	else:
		print(built.ctrl_panel)
		if built.ctrl_panel != null:
			if built.has_method("gen_ctrl_panel"):
				var panel = built.gen_ctrl_panel()
				ctrl_panel.add_child(panel)
				return
		var label = Label.new()
		label.text = 'WIP: Please stay in tune.'
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		ctrl_panel.add_child(label)

func _on_close_button_pressed() -> void:
	# print('viewport ', get_viewport().size)
	side_panel_closed.emit()
	UITweens.set_tween(self, "position:x", position.x + size.x, 0.25)
	# print('sidebar moved to ', position)
	is_opened = false
	clear_panel()


func clear_panel():
	for child in ctrl_panel.get_children():
		child.queue_free()
