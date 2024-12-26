extends PanelContainer

@onready var desc: Label = %Desc
@onready var ingrediants_container: GridContainer = %Ingrediants
@onready var duration: Label = %Duration
@onready var results_container: GridContainer = %Results

const item_slot = preload("res://scenes/gui/components/item_slot.tscn")

func set_tooltip(recipe: Recipe):
	if recipe == null:
		return
	var materials = recipe.ingredients
	var results = recipe.results
	%Title.text = recipe.name
	%Duration.text = '%dh' % recipe.time_in_hour
	%Desc.text = recipe.description
	for k in materials.keys():
		var item = k
		var amount = materials[k]
		add_item(%Ingrediants, item, amount)
	for k in results.keys():
		var item = k
		var amount = results[k]
		add_item(%Results, item, amount)

func add_item(container: Container, item: Item, amount: int):
	var slot = item_slot.instantiate()
	slot.item = item
	slot.amount = amount
	container.add_child(slot)
