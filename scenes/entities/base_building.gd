class_name BaseBuilding extends Node2D


@export var title: String = ''
@export var level: int
@export var ent_id: Vector3i
@export var ctrl_panel: PackedScene
@export var is_built: bool = false
@export var can_destroy: bool = true

@onready var label_title: Label = %Title
@onready var label_level: Label = %Level
@onready var prod_status: Label = %ProdStatus
@onready var self_status: Label = %SelfStatus
@onready var progress_bar: ProgressBar = %ProgressBar


signal building_selected(built: BaseBuilding)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_title.text = title
	if level != 0:
		label_level.text = "Lv. %d" % level
	if not is_built:
		prod_status.hide()
		self_status.hide()


func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_text_scroll_up"):
		#print(title + " selected by mouse!")
		#building_selected.emit(self)
	pass

func handle_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print(title + " selected by mouse!")
			building_selected.emit(self)

func set_progress(progress: float):
	progress_bar.value = progress

func set_prod_status(stat: String=''):
	prod_status.text = stat

func set_self_status(stat: String=''):
	self_status.text = stat
