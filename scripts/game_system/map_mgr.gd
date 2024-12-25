class_name MapMgr extends Node

@export var area: Rect2i = Rect2i(0, 0, 10, 10)

var map_data: MapData.MapDataSet = MapData.MapDataSet.new()

var outpost_data: Array[OutpostDM.Outpost] = []

func _ready() -> void:
	initiate(area)

func initiate(mapArea: Rect2i) -> void:
	for i in range(mapArea.position.x, mapArea.size.x):
		for j in range(mapArea.position.y, mapArea.size.y):
			var cell = MapData.Cell.new(Vector2i(i, j), MapData.Visibility.Visible, 0)
			map_data.add_cell(cell)

#region query

## 获取指定位置的地块数据
func get_cell_data(location: Vector2i) -> MapData.Cell:
	return map_data.get_cell(location)

## 获取指定位置的所属方
func get_cell_housing(location: Vector2i) -> int:
	var cell = get_cell_data(location)
	if cell != null:
		return cell.housing
	return 0

## 获取指定位置的哨所数据
func get_outpost_data(location: Vector2i) -> OutpostDM.Outpost:
	for outpost in outpost_data:
		if outpost.location == location:
			return outpost
	return null

#region Map Data

func update_cell_housing(cell: Vector2i, housing: int) -> void:
	map_data.update_cell_housing(cell, housing)

func collect_cell_resources(loc: Vector2i, type: StringName, amount: int) -> int:
	var cell = get_cell_data(loc)
	if cell != null:
		var avail_amount = cell.collect_resources(type, amount)
		if avail_amount > 0:
			print("Collect %d %s from %s" % [avail_amount, type, loc])
			EventBus.publish("update_cell_resources", [loc, cell.resources])
			return avail_amount
	return 0

#region Outpost Data

var outpost_id := 0

## 建立哨所
func build_outpost(housing: int, location: Vector2i, op_name: String = "前进营地") -> OutpostDM.Outpost:
	var outpost = OutpostDM.Outpost.new(outpost_id, op_name, housing, location)
	outpost_data.append(outpost)
	outpost_id += 1
	return outpost

## 根据位置获取哨所数据
func get_outpost_data_by_location(location: Vector2i) -> OutpostDM.Outpost:
	for outpost in outpost_data:
		if outpost.location == location:
			return outpost
	return null

## 根据ID获取哨所数据
func get_outpost_data_by_id(id: int) -> OutpostDM.Outpost:
	for outpost in outpost_data:
		if outpost.id == id:
			return outpost
	return null

## 拆除哨所
func remove_outpost(id: int) -> void:
	for i in range(outpost_data.size()):
		if outpost_data[i].id == id:
			outpost_data.erase(i)
			break

func update_outposts(delta: float) -> void:
	for outpost in outpost_data:
		outpost.update(delta)