@icon("res://assets/image/icon/warehouse.svg")
class_name Warehouse extends Node

@export var title: String = ""
@export var capacity: int = 1000
var storage: float = 0
var inventory: Dictionary = {}

signal item_changed(item: Item, amount: int)


func _ready() -> void:
	item_changed.connect(self.update_storage)
	item_changed.connect(self.get_status)


func add_item(item: Item, amount: int) -> void:
	if not inventory.has(item):
		inventory[item] = amount
	else:
		inventory[item] += amount
	item_changed.emit(item, amount)

func remove_item(item: Item, amount: int) -> void:
	if inventory.has(item):
		inventory[item] -= amount
		item_changed.emit(item, -amount)
		#if inventory[item] <= 0:
			#inventory.erase(item)
		


func get_item_amount(item: Item) -> int:
	if inventory.has(item):
		return inventory[item]
	else:
		return 0


func get_avail_space(item: Item) -> int:
	var avail_space: float = capacity - storage
	return int(avail_space / item.weight)


func update_storage(_item: Item, _amount: int) -> void:
	storage = 0
	for item: Item in inventory.keys():
		if inventory[item] == 0:
			inventory.erase(item)
		else:
			storage += item.weight * inventory[item]


func get_status(_item, _amount) -> void:
	print("Storage: " + str(storage) + "/" + str(capacity))
	for item in inventory.keys():
		print(item.name + ": " + str(inventory[item]))
