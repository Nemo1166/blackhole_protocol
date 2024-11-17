class_name ResourceMgr extends Node


var locations: Array[Warehouse] = []


func register_location(location: Warehouse) -> void:
	locations.append(location)


func unregister_location(location: Warehouse) -> void:
	locations.erase(location)


func get_location_by_title(title: String) -> Warehouse:
	for location in locations:
		if location.title == title:
			return location
	return null

