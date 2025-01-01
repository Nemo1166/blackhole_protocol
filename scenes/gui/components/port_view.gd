extends VBoxContainer

var port: OutpostDM.Port = null

func _ready() -> void:
	update_view()

func link_port(object: OutpostDM.Port):
	if object == null:
		return

	port = object
	port.stat_changed.connect(update_stat_view)
	update_view()

func _exit_tree() -> void:
	if port != null:
		port.stat_changed.disconnect(update_stat_view)

func update_view():
	if port == null:
		return
	var item = port.get_item()
	if item != null:
		%ConfigView.show()
		%PortStat.show()
		$HBoxContainer2/Label.text = "库存："
		
		%ItemTexture.texture = item.icon
		%LabelStorage.text = str(port.storage)
		
		update_cfg_view()
		update_stat_view()
	else:
		clear_view()

func update_cfg_view():
	%ConfigView.update_view(port)

func update_stat_view():
	%LabelStorage.set_value(port.storage)

func clear_view():
	%ConfigView.hide()
	%PortStat.hide()
	$HBoxContainer2/Label.text = "未选择物品"
	%ItemTexture.texture = null

func open_item_selector():
	%PopupItemSelector.popup(Rect2i(get_global_mouse_position() - Vector2(%PopupItemSelector.size), %PopupItemSelector.size))
	%ItemSelector.list_items()

func _on_config_button_pressed() -> void:
	%PopupModeSelector.popup(Rect2i(get_global_mouse_position() - Vector2(120, 48), %PopupModeSelector.size))

func _on_item_view_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			open_item_selector()

func _on_item_selector_item_selected(item: Item) -> void:
	port.set_item(item)
	update_view()

func _on_mode_selector_mode_selected(mode: OutpostDM.TradeMode) -> void:
	port.set_mode(mode)
	update_cfg_view()

func _on_setting_amount_text_submitted(new_text: String) -> void:
	if new_text.is_valid_int():
		port.setting_amount = new_text.to_int()
		update_cfg_view()
