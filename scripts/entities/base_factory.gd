class_name BaseFactory extends Node


@export var title: String = ""
@export var curr_recipe: Recipe

var is_configured: bool = false
var is_working: bool = false

var prod_time: float = 0
var efficincy: float = 1.0
# var buff

var io_warehouse: Warehouse

enum State {
	IDLE,
	WORKING,
	STOPPED,
}

var curr_state: State = State.IDLE
signal state_changed(state: State)
signal progress_changed(progress: float)


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not is_configured:
		pass
	else:
		produce()


var start_time: DateTime
var work_progress: float = 0

func produce() -> void:
	# get curr time
	var curr_time: DateTime = Global.game.time_mgr.date_time
	# if idle then start
	if not is_working:
		state_to(State.WORKING)
		start_time = curr_time.copy()
	else:
		# update progress
		var working_time = curr_time.diff(start_time).get_minutes(false) * efficincy
		work_progress = (float(working_time) / prod_time) * 100
		#print(start_time)
		#var progress = 50
		if work_progress > 100:
			work_progress = 0
			state_to(State.IDLE)
			progress_changed.emit(work_progress)
			# complete
		else:
			progress_changed.emit(work_progress)

func set_recipe(recipe: Recipe) -> void:
	curr_recipe = recipe
	is_configured = true
	prod_time = recipe.time_in_hour * 60

func remove_recipe() -> void:
	curr_recipe = null
	is_configured = false
	state_to(State.IDLE)

func state_to(state: State) -> void:
	curr_state = state
	state_changed.emit(state)
	match state:
		State.WORKING:
			is_working = true
		State.IDLE:
			is_working = false
		State.STOPPED:
			is_working = false
