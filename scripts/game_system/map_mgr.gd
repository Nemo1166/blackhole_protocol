class_name MapMgr extends Node

@export var area: Rect2i = Rect2i(0, 0, 10, 10)
@export var blocks: TileMapLayer
@export var squad_canvas: Node2D

var map_data: MapData.MapDataSet = MapData.MapDataSet.new()

var outpost_data: Array[OutpostDM.Outpost] = []
var logistics: LogisticsSys = LogisticsSys.new()

func _ready() -> void:
	initiate(area)
	initiate_outposts.call_deferred()
	logistics.link_outpost_data(outpost_data)

func update(delta: float):
	update_outposts(delta)

func _on_date_changed(_date: DateTime) -> void:
	logistics.update()

func initiate(mapArea: Rect2i) -> void:
	for i in range(mapArea.position.x, mapArea.size.x):
		for j in range(mapArea.position.y, mapArea.size.y):
			var cell = MapData.Cell.new(Vector2i(i, j), MapData.Visibility.Visible, 0)
			map_data.add_cell(cell)

func initiate_outposts() -> void:
	# Rhodes, (0,0)
	build_rhodes()
	# kazdel, (-1,7)
	var o = build_outpost(3, Vector2i(-1, 7), "卡兹戴尔")
	o.inventory.add_item(Global.items[4], 1000)
	o.build(OutpostDM.Facilities.Crafting.new())
	# yan, (-1,0)
	build_outpost(8, Vector2i(10, 3), "百灶")
	build_outpost(8, Vector2i(-1, 0), "龙门")
	# ursus, (-3,-1)
	build_outpost(1, Vector2i(-3, -1), "切尔诺伯格")
	
	$"../Map".draw_outposts(outpost_data)

func build_rhodes():
	var rhodes: OutpostDM.Outpost = build_outpost(20, Vector2i(0,0), "罗德岛")
	rhodes.inventory.add_item(Global.items[4], 1000)
	rhodes.build(OutpostDM.Facilities.Mine.new())
	var mine = rhodes.get_facility("Mine")
	var unit = mine.units[0]
	unit.set_plan(Global.get_recipe("开采铁矿"))
	unit = mine.add_unit(OutpostDM.ProductionUnit.new())
	unit.set_plan(Global.get_recipe("采集木材"))
	unit = mine.add_unit(OutpostDM.ProductionUnit.new())

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

#region navigation

## 获取指定位置的邻居
func get_neighbors(location: Vector2i) -> Array[Vector2i]:
	return HexGridTool.oddr_neighbors(location)

## 获取距离
func get_distance(from: Vector2i, to: Vector2i) -> float:
	return HexGridTool.oddr_distance(from, to)

## 获取路径
func find_path(_from: Vector2i, _to: Vector2i) -> Array[Vector2i]:
	return []

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

#region Squad Data

var squad_id := 0

var squads: Array[SquadDM.Squad] = []

## 创建队伍
func create_squad(location: Vector2i, type: SquadDM.SquadType) -> SquadDM.Squad:
	var squad = SquadDM.Squad.new(type, location)
	squads.append(squad)
	squad_id += 1
	return squad

## 根据ID获取队伍数据
func get_squad_data_by_id(id: int) -> SquadDM.Squad:
	for squad in squads:
		if squad.id == id:
			return squad
	return null

## 根据位置获取队伍数据
func get_squad_data_by_location(location: Vector2i) -> SquadDM.Squad:
	for squad in squads:
		if squad.location == location:
			return squad
	return null

## 移动队伍
func move_squad(sid: int, to: Vector2i) -> void:
	var squad = get_squad_data_by_id(sid)
	if squad != null:
		squad.move_to(to)

## 更新队伍
func update_squads(_delta: float) -> void:
	for squad in squads:
		pass

## 解散队伍
func dismiss_squad(id: int) -> void:
	for i in range(squads.size()):
		if squads[i].id == id:
			squads.erase(i)
			break

## 获取队伍列表
func get_squads() -> Array[SquadDM.Squad]:
	return squads

## 获取队伍数量
func get_squad_count(type: SquadDM.SquadType) -> int:
	var count = 0
	for squad in squads:
		if squad.type == type:
			count += 1
	return count

#region map conversion

func world_to_map(world: Vector2) -> Vector2i:
	return blocks.local_to_map(world)

func map_to_world(map: Vector2i) -> Vector2:
	return blocks.map_to_world(map)
