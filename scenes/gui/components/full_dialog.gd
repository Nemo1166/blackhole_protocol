class_name FullscreenDialog extends PanelContainer


@export var title: String = 'Dialog Title'
@export var body: Control

@onready var margin_container: MarginContainer = $MarginContainer
@onready var label: Label = %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = title
	if body:
		body.instantiate()
		margin_container.add_child(body)




func _on_exit_button_button_up() -> void:
	queue_free()
