extends Control

@onready var ingredients: HBoxContainer = %Ingredients
@onready var progress: ProgressBar = %Progress
@onready var results: HBoxContainer = %Results
@onready var work_state: Label = %WorkState
@onready var prod_state: Label = %ProdState


var unit: OutpostDM.ProductionUnit = null

func _ready() -> void:
	$PopupPanel.hide()

func _process(_delta: float) -> void:
	if unit != null:
		update_progress(unit.progress)

func _exit_tree() -> void:
	if unit != null:
		unit.work_state_changed.disconnect(update_work_state)
		unit.prod_state_changed.disconnect(update_prod_state)

func connect_unit(prod_unit: OutpostDM.ProductionUnit):
	self.unit = prod_unit
	update_view()
	unit.work_state_changed.connect(update_work_state)
	unit.prod_state_changed.connect(update_prod_state)

func update_view():
	update_recipe_view()
	update_progress(unit.progress)
	update_work_state(unit.work_state)
	update_prod_state(unit.prod_state)

func update_recipe_view():
	Global.clear_children(ingredients)
	Global.clear_children(results)
	if unit.plan == null:
		update_progress(0)
		return
	print(unit.plan.name)
	if unit.plan.type == Recipe.Type.Mining:
		var miner = create_miner()
		ingredients.add_child(miner)
	else:
		for ingredient in unit.plan.ingredients.keys():
			var slot: ItemSlot = Global.ITEM_SLOT.instantiate()
			slot.set_item(ingredient, unit.plan.ingredients[ingredient])
			ingredients.add_child(slot)

	for result in unit.plan.results.keys():
		var slot: ItemSlot = Global.ITEM_SLOT.instantiate()
		slot.set_item(result, unit.plan.results[result])
		results.add_child(slot)

func update_progress(value: float):
	progress.value = value

func update_work_state(s: OutpostDM.ProductionUnit.WorkState):
	match s:
		OutpostDM.ProductionUnit.WorkState.IDLE:
			work_state.text = "空闲中"
		OutpostDM.ProductionUnit.WorkState.PRODUCING:
			work_state.text = "工作中"
		OutpostDM.ProductionUnit.WorkState.STOPPED:
			work_state.text = "已停止"

func update_prod_state(s: OutpostDM.ProductionUnit.ProdState):
	match s:
		OutpostDM.ProductionUnit.ProdState.NORMAL:
			prod_state.text = ""
		OutpostDM.ProductionUnit.ProdState.INSUFFICIENT_MATERIAL:
			prod_state.text = "材料不足"

func create_miner():
	var texture_rect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	texture_rect.texture = load("res://assets/image/icon/头像_装置_采集实习站.png")
	return texture_rect

func open_recipe_selector():
	$PopupPanel.show()
	$PopupPanel.position = get_global_mouse_position()
	%RecipeViews.show_avail_recipe(unit.acceptable_recipe)


func _on_recipe_views_recipe_selected(recipe: Recipe) -> void:
	unit.set_plan(recipe)
	update_recipe_view()
	$PopupPanel.hide()


func _on_clear_plan() -> void:
	unit.clear_plan()
	$PopupPanel.hide()
	update_view()
