@icon("res://assets/image/icon/warehouse.svg")
class_name Warehouse extends Node

@export var title: String = ""
@export var capacity: int = 1000
var storage: float = 0
var inventory: Dictionary = {}

signal item_changed(item: Item, amount: int)


func _ready() -> void:
	item_changed.connect(self.update_storage)


func add_item(item: Item, amount: int) -> void:
	if not inventory.has(item):
		inventory[item] = amount
	else:
		inventory[item] += amount
	item_changed.emit(item, inventory[item])

func remove_item(item: Item, amount: int) -> void:
	if inventory.has(item):
		inventory[item] -= amount
		if inventory[item] <= 0:
			inventory.erase(item)
		item_changed.emit(item, inventory[item])


func get_item_amount(item: Item) -> int:
	if inventory.has(item):
		return inventory[item]
	else:
		return 0


func get_avail_space(item: Item) -> int:
	var avail_space: float = capacity - storage
	return int(avail_space / item.weight)


func update_storage() -> void:
	storage = 0
	for item: Item in inventory.keys():
		if inventory[item] == 0:
			inventory.erase(item)
		else:
			storage += item.weight * inventory[item]
