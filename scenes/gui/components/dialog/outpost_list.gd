extends Control

const OUTPOST_ITEM = preload("res://scenes/gui/components/dialog/outpost_item.tscn")

var selected_item: OutpostDM.Outpost

func set_view(list: Array[OutpostDM.Outpost]):
	Global.clear_children(%OutpostListContainer)
	for o in list:
		var item = OUTPOST_ITEM.instantiate()
		item.set_view(o)
		%OutpostListContainer.add_child(item)
		item.outpost_selected.connect(_on_item_selected)

func _on_item_selected(outpost):
	selected_item = outpost
	%GoTo.disabled = false
	print("selected %s" % (outpost.name))
	for c in %OutpostListContainer.get_children():
		if c.this != outpost:
			c.deselect()

func _on_go_to_pressed() -> void:
	EventBus.publish("camera_focus_on", [selected_item.location])
