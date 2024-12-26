class_name MapData extends RefCounted

class MapDataSet extends Resource:
	@export_category("Map Data")
	@export var cells: Array = []

	func _init():
		self.cells = []

	func add_cell(cell: Cell):
		self.cells.append(cell)

	func get_cell(location: Vector2i) -> Cell:
		for cell in self.cells:
			if cell.location == location:
				return cell
		return null

	func update_cell_housing(location: Vector2i, housing: int):
		for cell in self.cells:
			if cell.location == location:
				cell.housing = housing
				return

#region Cell Data

class Cell extends Resource:
	@export_category("Cell Data")
	@export var location: Vector2i = Vector2i(0, 0)
	@export var visible: Visibility = Visibility.Visible
	@export var housing: int = 0

	@export_category("Resources")
	@export var resources: CellRes

	func _init(
				location: Vector2i, 
				visible: Visibility,
				housing: int, 
				resources: Vector4 = Vector4(1, 1, 0.8, 0.5)):
		self.location = location
		self.visible = visible
		self.housing = housing
		self.resources = CellRes.new(resources.x, resources.y, resources.z, resources.w)

	func collect_resources(type: StringName, amount: int) -> int:
		match type:
			"wood":
				if resources.wood >= amount:
					resources.wood -= amount
					return amount
				else:
					var collected = resources.wood
					resources.wood = 0
					return collected
			"stone":
				if resources.stone >= amount:
					resources.stone -= amount
					return amount
				else:
					var collected = resources.stone
					resources.stone = 0
					return collected
			"food":
				if resources.food >= amount:
					resources.food -= amount
					return amount
				else:
					var collected = resources.food
					resources.food = 0
					return collected
			"iron":
				if resources.iron >= amount:
					resources.iron -= amount
					return amount
				else:
					var collected = resources.iron
					resources.iron = 0
					return collected
		return 0

class CellRes extends Resource:
	@export var wood: int = 0
	@export var stone: int = 0
	@export var food: int = 0
	@export var iron: int = 0
	@export var water: float = 1

	func _init(wood_coef: float = 1, stone_coef: float = 1, food_coef: float = 0.8, iron_coef: float = 0.5):
		self.wood = int(randi_range(10000, 15000) * wood_coef)
		self.stone = int(randi_range(1000, 2000) * stone_coef)
		self.food = int(randi_range(1000, 2000) * food_coef)
		self.iron = int(randi_range(1000, 2000) * iron_coef)
		self.water = randf() * 0.5 + 0.5

enum Visibility {
	Visible,
	Fog,
	Hidden,
}
