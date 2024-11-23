class_name ItemSlot extends TextureRect


@export var item: Item = null
@export var amount: int = 0

@onready var amount_label: Label = %Amount
@onready var amount_container: PanelContainer = $PanelContainer
@onready var desc_panel: PanelContainer = $DescPanel
@onready var desc_title: Label = %DescTitle
@onready var desc: RichTextLabel = %Desc
@onready var desc_icon: TextureRect = $DescPanel/MarginContainer/VBoxContainer/HBoxContainer/TextureRect

var shader: ShaderMaterial = material


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	amount_container.hide()
	if item:
		self.texture = item.icon
		if amount > 0:
			amount_container.show()
			if amount > 999999:
				amount_label.text = "%dM" % (amount / 1000000)
			elif amount > 999:
				amount_label.text = "%dK" % (amount / 1000)
			else:
				amount_label.text = str(amount)


func _on_mouse_entered() -> void:
	desc_panel.show()
	desc_panel.position = get_global_mouse_position()
	desc_title.text = item.name
	desc.text = '%s\n[color=SILVER][i]%s[/i][/color]' % [item.desc_basic, item.desc_ext]
	desc_icon.texture = item.icon
	shader.set_shader_parameter("progress", 1)


func _on_mouse_exited() -> void:
	desc_panel.hide()
	shader.set_shader_parameter("progress", 0)
