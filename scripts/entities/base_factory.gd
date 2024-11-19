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
signal sufficiency_changed(is_sufficient: bool)
signal plan_set(recipe: Recipe)
signal plan_removed


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not is_configured:
		pass
	else:
		produce()
		if output_inventory.size() > 0:
			drop_inventory(output_inventory)


func link_warehouse(idx: int) -> void:
	io_warehouse = Global.game.res_mgr.get_depot(idx)

var start_time: DateTime
var work_progress: float = 0

func produce() -> void:
	# get curr time
	var curr_time: DateTime = Global.game.time_mgr.date_time
	# if idle then start
	if not is_working:
		if has_enough_ingredients():
			sufficiency_changed.emit(true)
			state_to(State.WORKING)
			start_time = curr_time.copy()
		else:
			sufficiency_changed.emit(false)
			collect_ingredients()
	else:
		# proceed producing progresss
		var working_time = curr_time.diff(start_time).get_minutes(false) * efficincy
		work_progress = (float(working_time) / prod_time) * 100
		#print(start_time)
		#var progress = 50
		if work_progress > 100:
			# complete
			gen_product()
			
			work_progress = 0
			state_to(State.IDLE)
			progress_changed.emit(work_progress)
		else:
			progress_changed.emit(work_progress)

func set_recipe(recipe: Recipe) -> void:
	curr_recipe = recipe
	is_configured = true
	prod_time = recipe.time_in_hour * 60
	plan_set.emit(recipe)

func remove_recipe() -> void:
	curr_recipe = null
	is_configured = false
	state_to(State.IDLE)
	plan_removed.emit()

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


func drop_inventory(depot: Dictionary) -> void:
	if depot.size() == 0:
		return
	for item in depot.keys():
		var avail_space = io_warehouse.get_avail_space(item)
		if avail_space < depot[item]:
			io_warehouse.add_item(item, avail_space)
			depot[item] -= avail_space
		else:
			io_warehouse.add_item(item, depot[item])
			depot.erase(item)


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


func gen_product() -> void:
	for item in curr_recipe.ingredients.keys():
		input_inventory[item] -= curr_recipe.ingredients[item]
	for item in curr_recipe.results.keys():
		if not output_inventory.has(item):
			output_inventory[item] = 0
		output_inventory[item] += curr_recipe.results[item]
