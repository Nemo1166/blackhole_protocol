class_name ItemSlot extends TextureRect


@export var item: Item = null
@export var amount: int = 0

@onready var amount_label: Label = %Amount
@onready var amount_container: PanelContainer = $PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	amount_container.hide()
	if item:
		self.texture = item.icon
		if amount > 0:
			amount_container.show()
			if amount > 999999:
				@warning_ignore("integer_division")
				amount_label.text = "%dM" % (amount / 1000000)
			elif amount > 999:
				@warning_ignore("integer_division")
				amount_label.text = "%dK" % (amount / 1000)
			else:
				amount_label.text = str(amount)

func set_item(item: Item, amount: int = 1):
	self.item = item
	self.amount = amount

func _make_custom_tooltip(_for_text: String) -> Object:
	if item == null:
		return null
	var panel: ItemDescPanel = Global.ITEM_DESC_PANEL.instantiate()
	panel.set_tooltip(item)
	return panel
