class_name HexGridTool extends RefCounted

#region Computations

static func _axial_sub(a: Vector2i, b: Vector2i) -> Vector2i:
	return Vector2i(a.x - b.x, a.y - b.y)

#region Coord Conversion

static func _oddr_to_axial(odd: Vector2i) -> Vector2i:
	var q = odd.x - int((odd.y - (odd.y & 1)) / 2.0)
	var r = odd.y
	return Vector2i(q, r)

static func _axial_to_oddr(axial: Vector2i) -> Vector2i:
	var x = axial.x + int((axial.y - (axial.y & 1)) / 2.0)
	var y = axial.y
	return Vector2i(x, y)

#region Distance

static func _axial_distance(a: Vector2i, b: Vector2i) -> int:
	var vec = _axial_sub(a, b)
	return int((abs(vec.x) + abs(vec.y) + abs(vec.x + vec.y)) / 2)

static func oddr_distance(a: Vector2i, b: Vector2i) -> int:
	var a_axial = _oddr_to_axial(a)
	var b_axial = _oddr_to_axial(b)
	return _axial_distance(a_axial, b_axial)

#region Neighbors

const DIRECTIONS = [
	# Even row
	[Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)],
	# Odd row
	[Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(1, 1)]
]

static func oddr_neighbors(odd: Vector2i) -> Array:
	var parity = odd.y & 1
	var neighbors = []
	for dir in DIRECTIONS[parity]:
		neighbors.append(odd + dir)
	return neighbors

