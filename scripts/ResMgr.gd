class_name ResourceMgr extends Node


var depots: Array[Warehouse] = []


func register_depot(depot: Warehouse) -> void:
	depots.append(depot)


func unregister_depot(depot: Warehouse) -> void:
	depots.erase(depot)


func get_depot_idx(depot: Warehouse) -> int:
	return depots.find(depot)


func get_depot(idx: int) -> Warehouse:
	return depots[idx]