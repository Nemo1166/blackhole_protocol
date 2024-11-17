class_name BaseFactory extends Node


@export var title: String = ""
@export var curr_recipe: Recipe

var is_configured: bool = false
var is_working: bool = false

var prod_time: float = 0
var efficincy: float = 1.0
# var buff

var io_warehouse: Warehouse
var input_inventory: Dictionary = {}
var output_inventory: Dictionary = {}

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


# 库存管理

# func pickup_item(item: Item, amount: int) -> void:
# 	if not input_inventory.has(item):
# 		input_inventory[item] = 0
# 	var avail_amount = io_warehouse.get_item_amount(item)
# 	if avail_amount < amount:
# 		# not enough
# 		input_inventory[item] += avail_amount
# 		io_warehouse.remove_item(item, avail_amount)
# 	else:
# 		# enough
# 		input_inventory[item] += amount
# 		io_warehouse.remove_item(item, amount)

func pickup_item(item: Item, amount: int) -> void:
	if not input_inventory.has(item):
		input_inventory[item] = 0
	var avail_amount = io_warehouse.get_item_amount(item)
	var amount_to_pickup = min(amount, avail_amount)
	io_warehouse.remove_item(item, amount_to_pickup)
	input_inventory[item] += amount_to_pickup


func drop_all() -> void:
	if input_inventory.size() == 0:
		return
	for item in input_inventory.keys():
		var avail_space = io_warehouse.get_avail_space(item)
		if avail_space < input_inventory[item]:
			io_warehouse.add_item(item, avail_space)
			input_inventory[item] -= avail_space
		else:
			io_warehouse.add_item(item, input_inventory[item])
			input_inventory.erase(item)


func collect_ingredients() -> void:
	const AMOUNT_MULTIPLIER: int = 2
	if not is_configured:
		return
	for item in curr_recipe.ingredients.keys():
		var amount_needed = curr_recipe.ingredients[item] * AMOUNT_MULTIPLIER
		if not input_inventory.has(item):
			input_inventory[item] = 0
		if input_inventory[item] < amount_needed:
			pickup_item(item, amount_needed - input_inventory[item])


func has_enough_ingredients() -> bool:
	if not is_configured:
		return false
	for item in curr_recipe.ingredients.keys():
		if not input_inventory.has(item):
			return false
		if input_inventory[item] < curr_recipe.ingredients[item]:
			return false
	return true
