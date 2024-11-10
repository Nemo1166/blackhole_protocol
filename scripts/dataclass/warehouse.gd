class_name Warehouse extends Node

var title: String = ""
var capacity: int = 0
var storage: float = 0
var inventory: Dictionary = {}

signal item_changed(item: Item, amount: int)

func _init(_title, _capacity) -> void:
	title = _title
	capacity = _capacity
	inventory = {}
	storage = 0


func add_item(item: Item, amount: int) -> int:
	var total_weight = amount * item.weight
	var avail_weight = capacity - storage

	# 计算允许存入的最大数量
	var max_amount = avail_weight / item.weight

	# 如果容量不足，则只存入最大允许数量
	if total_weight > avail_weight:
		amount = int(max_amount)  # 调整数量为最大可存入数量
		if amount <= 0:
			print("仓库空间不足，无法存入任何数量的 ", item.name)
			return 0
		print("仓库空间不足，仅存入 ", amount, " 个 ", item.name)

	# 更新库存
	if inventory.has(item):
		inventory[item] += amount
	else:
		inventory[item] = amount

	# 更新已用空间
	storage += amount * item.weight
	print("已存入物品:", item.name, " 数量:", amount)
	item_changed.emit(item, amount)
	return amount  # 返回实际存入的数量


func remove_item(item: Item, amount: int) -> bool:
	if inventory.has(item) and inventory[item] >= amount:
		# 计算取出物品的空间
		var total_weight = amount * item.weight
		
		# 更新库存
		inventory[item] -= amount
		if inventory[item] <= 0:
			inventory.erase(item)

		# 更新已用空间
		storage -= total_weight
		print("已取出物品:", item.name, "数量:", amount)
		item_changed.emit(item, -amount)
		return amount
	return 0


func has_item(item: Item) -> int:
	if inventory.has(item):
		return inventory[item]
	return 0


func has_space(item: Item, amount: int) -> bool:
	var total_weight = amount * item.weight
	var avail_weight = capacity - storage
	return total_weight <= avail_weight