class_name ProdStationCtrl extends VBoxContainer


@export var factory: BaseFactory
var formula_ui = preload("res://scenes/gui/components/recipe_formula_ui.tscn")


func _ready() -> void:
	if not factory.is_configured:
		show_avail_recipes()
		%CancelPlan.hide()
	else:
		%CancelPlan.show()

func _process(_delta: float) -> void:
	pass

func on_select_recipe(recipe: Recipe):
	factory.set_recipe(recipe)
	var product: Item = recipe.results.keys()[0]
	%CurrProduct.texture = product.icon
	%ProductName.text = product.name
	$GridContainer.hide()
	$ProdInfo.show()
	%CancelPlan.show()


func show_avail_recipes():
	$ProdInfo.hide()
	$GridContainer.show()
	# clear
	var existed_recipes = $GridContainer.get_children()
	if existed_recipes.size() > 0:
		for r in existed_recipes:
			r.queue_free()
	# put
	for id in Global.recipes.keys():
		var formula: RecipeFormulaUI = formula_ui.instantiate()
		
		formula.recipe = Global.recipes[id]
		#formula.update_ui()
		formula.recipe_selected.connect(on_select_recipe)
		$GridContainer.add_child(formula)


func _on_product_ui_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		show_avail_recipes()


func _on_cancel_plan_pressed() -> void:
	%CurrProduct.texture = null
	%ProductName.text = '未选择产品'
	%CancelPlan.hide()
	factory.remove_recipe()
