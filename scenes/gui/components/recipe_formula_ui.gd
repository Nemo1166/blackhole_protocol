class_name RecipeFormulaUI extends Control

@export var recipe: Recipe

@onready var ingrediants_container: GridContainer = %Ingrediants
@onready var results_container: GridContainer = %Results

var item_slot = preload("res://scenes/gui/components/item_slot.tscn")

signal recipe_selected(recipe: Recipe)

func _ready() -> void:
	update_ui()

func update_ui():
	var materials = recipe.ingredients
	var results = recipe.results
	%Duration.text = '%dh' % recipe.time_in_hour
	$Product.texture = results.keys()[0].icon
	%Desc.text = recipe.description
	for k in materials.keys():
		var item = k
		var amount = materials[k]
		add_item(ingrediants_container, item, amount)
	for k in results.keys():
		var item = k
		var amount = results[k]
		add_item(results_container, item, amount)

func add_item(container: Container, item: Item, amount: int):
	var slot = item_slot.instantiate()
	slot.item = item
	slot.amount = amount
	container.add_child(slot)


func _on_product_mouse_entered() -> void:
	$PanelContainer.show()
	$PanelContainer.set_position(get_global_mouse_position())


func _on_product_mouse_exited() -> void:
	$PanelContainer.hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		recipe_selected.emit(recipe)
