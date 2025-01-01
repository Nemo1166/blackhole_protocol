class_name HexNavigator extends RefCounted

class HexAstar2D extends AStar2D:
	func _compute_cost(from_id: int, to_id: int) -> float:
		var from := Vector2i(get_point_position(from_id))
		var to := Vector2i(get_point_position(to_id))
		return HexGridTool.oddr_distance(from, to)
	
	func _estimate_cost(from_id: int, to_id: int) -> float:
		var from := Vector2i(get_point_position(from_id))
		var to := Vector2i(get_point_position(to_id))
		return HexGridTool.oddr_distance(from, to)
	
	func build_grid(area: Rect2i):
		var points: Array[Vector2i] = []
		var id = 0
		# generate points
		for i in range(area.position.x, area.position.x + area.size.x):
			for j in range(area.position.y, area.position.y + area.size.y):
				# var cell = MapData.Cell.new(Vector2i(i, j), MapData.Visibility.Visible, 0)
				# map_data.add_cell(cell)
				var point := Vector2i(i, j)
				add_point(id, point)
				points.append(point)
				id += 1
		# generate edges
		for point in points:
			var neighbors = HexGridTool.oddr_neighbors(point)
			for neighbour in neighbors:
				if points.find(neighbour) != -1:
					connect_points(points.find(point), points.find(neighbour))
		
