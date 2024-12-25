extends Control

@onready var ingredients: HBoxContainer = %Ingredients
@onready var progress: ProgressBar = %Progress
@onready var results: HBoxContainer = %Results
@onready var state: Label = %State

var unit: OutpostDM.ProductionUnit = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if unit != null:
		update_progress()

func _exit_tree() -> void:
	if unit != null:
		unit.work_state_changed.disconnect(update_status)

func connect_unit(prod_unit: OutpostDM.ProductionUnit):
	self.unit = prod_unit
	update_view()
	unit.work_state_changed.connect(update_status)

func update_view():
	update_recipe_view()
	update_progress()
	update_status(unit.work_state)

func update_recipe_view():
	Global.clear_children(ingredients)
	Global.clear_children(results)
	if unit.plan == null:
		return

	print(unit.plan.name)
	for ingredient in unit.plan.ingredients.keys():
		var slot: ItemSlot = Global.ITEM_SLOT.instantiate()
		slot.set_item(ingredient, unit.plan.ingredients[ingredient])
		ingredients.add_child(slot)

	for result in unit.plan.results.keys():
		var slot: ItemSlot = Global.ITEM_SLOT.instantiate()
		slot.set_item(result, unit.plan.results[result])
		results.add_child(slot)

func update_progress():
	progress.value = unit.progress

func update_status(s: OutpostDM.ProductionUnit.WorkState):
	match s:
		OutpostDM.ProductionUnit.WorkState.IDLE:
			state.text = "空闲中"
		OutpostDM.ProductionUnit.WorkState.PRODUCING:
			state.text = "工作中"
		OutpostDM.ProductionUnit.WorkState.STOPPED:
			state.text = "已停止"
