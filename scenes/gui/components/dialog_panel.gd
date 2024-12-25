class_name DialogPanel extends CanvasLayer

@onready var title: Label = %Title
@onready var icon: TextureRect = %HeroIcon
@onready var content: MarginContainer = %Content
@onready var panel: PanelContainer = %Panel

func _ready() -> void:
	pass

func _on_close_button_pressed() -> void:
	self.queue_free()

func set_title(text: String):
	title.text = text

func set_icon(texture: Texture):
	icon.texture = texture

func set_panel_by_rect(rect: Rect2):
	panel.position = rect.position
	panel.size = rect.size

func set_panel_by_ref(ref: ReferenceRect):
	panel.position = ref.position
	panel.size = ref.size

func set_content(node: Control):
	for c in %Content.get_children():
		c.queue_free()
	%Content.add_child(node)
