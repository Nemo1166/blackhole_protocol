extends MarginContainer

signal outpost_selected(outpost: OutpostDM.Outpost)

var is_selected: bool = false

var this: OutpostDM.Outpost

func _ready() -> void:
	$ColorRect.color = Color(Color.WHITE, 0)

func set_view(outpost: OutpostDM.Outpost):
	this = outpost
	%Title.text = outpost.name
	%ID.text = "#%d" % (outpost.id)
	var master = Global.get_housing_data(outpost.owner)
	%OwnerName.text = master['name']
	%OwnerTexture.texture = master['texture']
	%Location.text = str(outpost.location)

func deselect():
	is_selected = false
	$ColorRect.color = Color(Color.WHITE, 0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_selected = true
			outpost_selected.emit(this)
			$ColorRect.color = Color(Color.WHITE, 0.25)

func _on_mouse_entered() -> void:
	if not is_selected:
		$ColorRect.color = Color(Color.WHITE, 0.125)


func _on_mouse_exited() -> void:
	if not is_selected:
		$ColorRect.color = Color(Color.WHITE, 0)
