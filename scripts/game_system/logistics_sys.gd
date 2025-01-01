class_name LogisticsSys extends Resource

var outposts: Array[OutpostDM.Outpost] = []

const DAILY_TRANSFER = 1000

#region 数据链接

func link_outpost_data(ref: Array[OutpostDM.Outpost]):
	outposts = ref

func update() -> void:
	for outpost in outposts:
		var ports = outpost.trade_station.ports
		for port: OutpostDM.Port in ports:
			if port.get_item() != null:
				var item := port.get_item()
				if port.get_mode() == OutpostDM.TradeMode.Request:
					if port.setting_amount != 0:
						if port.storage < port.setting_amount:
							# 有限制
							var amount_needed = port.setting_amount - port.storage
							var suppliers = find_suppliers(item)
							for supplier in suppliers:
								amount_needed -= transfer_to(supplier, outpost, item, amount_needed)
								if amount_needed <= 0:
									break
					else:
						# 无限制
						var amount_needed = DAILY_TRANSFER
						var suppliers = find_suppliers(item)
						for supplier in suppliers:
							amount_needed -= transfer_to(supplier, outpost, item, amount_needed)
							if amount_needed <= 0:
								break
					
			

#region 出入库方法

# func pick_from(outpost: OutpostDM.Outpost, item: Item, amount: int) -> int:
# 	return outpost.export_items(item, amount)

# func drop_to(outpost: OutpostDM.Outpost, item: Item, amount: int) -> int:
# 	return outpost.import_items(item, amount)

func transfer_to(from: OutpostDM.Outpost, to: OutpostDM.Outpost, item: Item, amount: int) -> int:
	var avail_amount = from.export_items(item, amount)
	if avail_amount > 0:
		to.import_items(item, avail_amount)
	return avail_amount

#region 搜索方法

func is_supplying(outpost: OutpostDM.Outpost, item: Item) -> bool:
	for port in outpost.trade_station.ports:
		if port.get_item() == item:
			return true
	return false

func find_suppliers(item: Item) -> Array:
	var supplier_list = []
	for outpost in outposts:
		if is_supplying(outpost, item):
			supplier_list.append(outpost)
	return supplier_list

#region 计算方法

func _estimate_distance(from: Vector2i, to: Vector2i) -> float:
	return from.distance_to(to)

func find_nearest_outpost(location: Vector2i, searching_list: Array[OutpostDM.Outpost]) -> OutpostDM.Outpost:
	var nearest_outpost = null
	var min_distance = 999999.0
	for outpost in searching_list:
		var distance = _estimate_distance(location, outpost.location)
		if distance < min_distance:
			min_distance = distance
			nearest_outpost = outpost
	return nearest_outpost
