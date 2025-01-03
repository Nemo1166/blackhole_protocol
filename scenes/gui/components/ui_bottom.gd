extends CanvasLayer

@onready var housing_texture: TextureRect = %HousingTexture
@onready var housing: Label = %Housing

@onready var sidepanel_content: MarginContainer = %Content

func _ready() -> void:
	side_panel.set_position($SP_collapsed.position)
	side_panel.set_size($SP_collapsed.size)
	%CloseSPButton.hide()

func _enter_tree() -> void:
	EventBus.subscribe("show_facility", show_facility_info)

func show_housing(index: int = -1) -> void:
	var data = Global.get_housing_data(index)
	housing_texture.texture = data["texture"]
	housing.text = data["name"]

signal side_panel_closed

@onready var side_panel: PanelContainer = $SidePanel

const TWEEN_TIME := 0.4

func close_side_panel():
	UITweens.set_tween(side_panel, "size", $SP_collapsed.size, TWEEN_TIME)
	UITweens.set_tween(side_panel, "position", $SP_collapsed.position, TWEEN_TIME)
	%CloseSPButton.hide()
	show_housing()
	sidepanel_content.clear()
	Global.close_all_dialog()

func open_side_panel(loc: Vector2i):
	UITweens.set_tween(side_panel, "size", $SP_opened.size, TWEEN_TIME)
	UITweens.set_tween(side_panel, "position", $SP_opened.position, TWEEN_TIME)
	%CloseSPButton.show()
	sidepanel_content.show_content(loc)
	Global.close_all_dialog()

func update_placeholder(flag: bool):
	sidepanel_content.update_placeholder(flag)

func _on_close_sp_button_pressed() -> void:
	side_panel_closed.emit()
	close_side_panel()

#region panel

func show_facility_info(args: Array):
	var facility = args[0]
	Global.close_dialog("设施信息")
	
	var dialog_panel: DialogPanel = Global.DIALOG_PANEL.instantiate()
	add_child(dialog_panel)
	dialog_panel.set_title("设施信息")
	dialog_panel.set_panel_by_ref($FacilityInfo)
	
	const FACILITY_VIEW = preload("res://scenes/gui/components/facility_view.tscn")
	var view = FACILITY_VIEW.instantiate()
	dialog_panel.set_content(view)
	view.set_facility_info(facility)
	

func _on_build_outpost() -> void:
	if Global.has_dialog("建造据点"):
		return
	var dialog_panel: DialogPanel = Global.DIALOG_PANEL.instantiate()
	add_child(dialog_panel)
	dialog_panel.set_title("建造据点")
	dialog_panel.set_panel_by_ref($BuildOutpost)


func _on_build_facility(outpost_id: int) -> void:
	if Global.has_dialog("建造设施"):
		return
	var dialog_panel: DialogPanel = Global.DIALOG_PANEL.instantiate()
	add_child(dialog_panel)
	dialog_panel.set_title("建造设施")
	dialog_panel.set_panel_by_ref($BuildOutpost)
	var selector = preload("res://scenes/gui/components/facility_selector.tscn").instantiate()
	dialog_panel.set_content(selector)
	selector.pass_oid(outpost_id)
	selector.update_desc()

func show_outpost_list(list: Array[OutpostDM.Outpost]):
	Global.close_dialog("营地一览")
	var dialog = Global.DIALOG_PANEL.instantiate()
	add_child(dialog)
	dialog.set_title("营地一览")
	dialog.set_panel_by_ref($Dialog)
	const OUTPOST_LIST = preload("res://scenes/gui/components/dialog/outpost_list.tscn")
	var view = OUTPOST_LIST.instantiate()
	view.set_view(list)
	dialog.set_content(view)
	
