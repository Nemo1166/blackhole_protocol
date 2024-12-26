class_name ProdStationCtrl extends VBoxContainer


@export var factory: BaseFactory
const ITEM_SLOT = preload("res://scenes/gui/components/item_slot.tscn")

func _ready() -> void:
	factory.progress_changed.connect(update_progress)
	factory.inventory_changed.connect(update_inventory)
	if not factory.is_configured:
		show_avail_recipes()
		%CancelPlan.hide()
		%ProdInfo.hide()
	else:
		%CancelPlan.show()
		show_curr_recipe(factory.curr_recipe)

func _process(_delta: float) -> void:
	pass

func on_select_recipe(recipe: Recipe):
	factory.set_recipe(recipe)
	show_curr_recipe(recipe)


func show_curr_recipe(recipe: Recipe):
	# logo
	var product: Item = recipe.results.keys()[0]
	%CurrProduct.texture = product.icon
	%ProductName.text = product.name
	$RecipeSelector.hide()
	%ProdInfo.show()
	%CancelPlan.show()
	init_prod_info(recipe)
	

func show_avail_recipes():
	# clear
	var existed_recipes = %RecipeGrid.get_children()
	if existed_recipes.size() > 0:
		for r in existed_recipes:
			r.queue_free()
	# put
	$RecipeSelector.show()

var toggle_flag = 0
func _on_product_ui_gui_input(event: InputEvent) -> void:
	if not factory.is_configured:
		show_avail_recipes()
		return
	if event is InputEventMouseButton and event.is_pressed():
		if not toggle_flag:
			show_avail_recipes()
			%ProdInfo.hide()
			toggle_flag = 1
		else:
			toggle_flag = 0
			$RecipeSelector.hide()
			%ProdInfo.show()


func _on_cancel_plan_pressed() -> void:
	%CurrProduct.texture = null
	%ProductName.text = '未选择产品'
	%CancelPlan.hide()
	%ProdInfo.hide()
	factory.remove_recipe()


func init_prod_info(recipe: Recipe) -> void:
	erase_prod_info()
	var ingredients = recipe.ingredients
	var results = recipe.results
	# var duration = recipe.time_in_hour
	for item in ingredients.keys():
		var amount = ingredients[item]
		var item_slot = ITEM_SLOT.instantiate()
		item_slot.item = item
		item_slot.amount = amount
		%Progress/Input.add_child(item_slot)
	for item in results.keys():
		var amount = results[item]
		var item_slot = ITEM_SLOT.instantiate()
		item_slot.item = item
		item_slot.amount = amount
		%Progress/Output.add_child(item_slot)
	
	pass


func erase_prod_info() -> void:
	var existed_slots = %Progress/Input.get_children()
	if existed_slots.size() > 0:
		for s in existed_slots:
			s.queue_free()
	existed_slots = %Progress/Output.get_children()
	if existed_slots.size() > 0:
		for s in existed_slots:
			s.queue_free()


func update_progress(progress: float) -> void:
	%Progress/ProgressBar.value = progress


func update_inventory() -> void:
	# erase inventory
	var grid = %InputInv/GridContainer
	var existed_slots = grid.get_children()
	if existed_slots.size() > 0:
		for s in existed_slots:
			s.queue_free()
	grid = %OutputInv/GridContainer
	existed_slots = grid.get_children()
	if existed_slots.size() > 0:
		for s in existed_slots:
			s.queue_free()
	# put inventory
	var input_inventory = factory.input_inventory
	if input_inventory.size() > 0:
		for item in input_inventory.keys():
			var amount = input_inventory[item]
			var item_slot = ITEM_SLOT.instantiate()
			item_slot.item = item
			item_slot.amount = amount
			%InputInv/GridContainer.add_child(item_slot)
	var output_inventory = factory.output_inventory
	if output_inventory.size() > 0:
		for item in output_inventory.keys():
			var amount = output_inventory[item]
			var item_slot = ITEM_SLOT.instantiate()
			item_slot.item = item
			item_slot.amount = amount
			%OutputInv/GridContainer.add_child(item_slot)
