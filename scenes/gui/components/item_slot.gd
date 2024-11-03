extends MarginContainer


@export var item: Item = null
@export var amount: int = 0

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label
@onready var panel_container: PanelContainer = $TextureRect/PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel_container.hide()
	if item:
		texture_rect.texture = item.icon
		if amount > 1:
			panel_container.show()
			if amount > 999999:
				label.text = "%dM" % (amount / 1000000)
			elif amount > 999:
				label.text = "%dK" % (amount / 1000)
			else:
				label.text = str(amount)
