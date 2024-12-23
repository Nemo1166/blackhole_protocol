class_name OutpostDM extends RefCounted

#region Facilities
const PROD_COEF := 10
const REQ_COEF := 2

class Facilities:
	class BaseWorkshop extends BaseFacility:
		@export var units: Array[ProductionUnit] = []
		@export_storage var progress: float = 0.0
		@export var productivity: float = 1.0

		func _init():
			name = "BaseWorkshop"
		
		func update(delta: float):
			for unit in units:
				unit.update(delta)
			manage_inventory()
		
		func add_unit(unit: ProductionUnit):
			unit.priority_changed.connect(allocate_productivity)
			units.append(unit)

		func remove_unit(unit: ProductionUnit):
			unit.priority_changed.disconnect(allocate_productivity)
			units.erase(unit)
		
		func allocate_productivity():
			var weights := {} # unit_idx: priority
			var total_weight := 0
			for i in range(units.size()):
				if units[i].work_state == ProductionUnit.WorkState.PRODUCING:
					weights[i] = units[i].priority
					total_weight += units[i].priority
			if total_weight == 0:
				return
			var unit_productivity := productivity / total_weight
			for i in weights.keys():
				units[i].efficiency = unit_productivity * weights[i]
		
		func manage_inventory():
			for unit in units:
				# check material
				if unit.prod_state == ProductionUnit.ProdState.INSUFFICIENT_MATERIAL:
					for item in unit.plan.ingredients.keys():
						if outpost.get_item_amount(item) > unit.plan.ingredients[item]:
							# request item from outpost
							outpost.deliver_item(outpost.inventory, unit.internal_inventory, item, unit.plan.ingredients[item])
				# check products
				for item in unit.plan.results.keys():
					if unit.internal_inventory.get_item_amount(item) > 0:
						# deliver item to outpost
						outpost.deliver_item(unit.internal_inventory, outpost.inventory, item, unit.internal_inventory.get_item_amount(item))
						

	class Farm extends BaseFacility:
		@export var plan: Recipe = Recipe.new()
		@export_storage var progress: float = 0.0

		func _init():
			name = "Farm"
		
		func update(delta: float):
			progress += delta
			if progress >= 10:
				progress = 0
				# outpost.inventory.add_item(Item.Food, 1)
				print("Farm produce food")

	class Mine extends BaseFacility:
		@export var plan: Array[StringName] = []
		@export_storage var progress: float = 0.0

		func _init():
			name = "Mine"
		
		func update(delta: float):
			progress += delta
			if progress >= 10:
				progress = 0
				# outpost.inventory.add_item(Item.Metal, 1)
				print("Mine produce metal")
	
	class Factory extends BaseFacility:
		@export var plan: Array[Recipe] = []
		@export_storage var progress: float = 0.0

		func _init():
			name = "Factory"
		
		func update(delta: float):
			progress += delta
			if progress >= 10:
				progress = 0
				# outpost.inventory.add_item(Item.Tool, 1)
				print("Factory produce tool")

#region DataClass

class Outpost extends Resource:
	@export var id: int
	@export var name: String
	@export var owner: int

	@export var location: Vector2i
	@export_storage var population: int
	@export_storage var inventory: Inventory = Inventory.new()

	@export var _facilities: Array[BaseFacility] = []

	func _init(id: int, name: String, owner: int, location: Vector2i):
		self.id = id
		self.name = name
		self.owner = owner
		self.location = location
		population = 10

	#region Manage Facilities

	func build(facility: BaseFacility):
		facility.outpost = self
		_facilities.append(facility)

	func update(delta: float):
		for facility in _facilities:
			facility.update(delta)
	
	func get_facility(fname: String) -> BaseFacility:
		for facility in _facilities:
			if facility.name == fname:
				return facility
		return null
	
	func get_all_facilities() -> Array[BaseFacility]:
		return _facilities
	
	#region Inventory Management
	func get_item_amount(item: Item) -> int:
		return inventory.get_item_amount(item)

	func get_gold_amount() -> int:
		return inventory.get_item_amount(Global.items[4])

	func deliver_item(from: Inventory, to: Inventory, item: Item, amount: int):
		if from.get_item_amount(item) >= amount:
			from.remove_item(item, amount)
			to.add_item(item, amount)
		else:
			print("Not enough item to deliver")
		
class Inventory extends Resource:
	@export_storage var _inventory: Dictionary = {} # item: amount

	func add_item(item: Item, amount: int):
		if not _inventory.has(item):
			_inventory[item] = amount
		else:
			_inventory[item] += amount
	
	func get_item_amount(item: Item) -> int:
		if _inventory.has(item):
			return _inventory[item]
		else:
			return 0
	
	func remove_item(item: Item, amount: int):
		if get_item_amount(item) >= amount:
			_inventory[item] -= amount
			if _inventory[item] <= 0:
				_inventory.erase(item)
		else:
			print("Not enough item to remove")

class BaseFacility extends Resource:
	@export var name: StringName = ""
	@export var cost: int = 0
	@export var level: int = 1
	@export_storage var outpost: Outpost

	func _init():
		pass
	
	## override
	func update(_delta: float):
		print("Facility update")

class ProductionUnit extends Resource:
	@export var name: StringName = ""
	@export var cost: int = 0
	@export var level: int = 1
	@export var priority: int = 0:
		set(value):
			if value != priority:
				priority = value
				emit_signal("priority_changed")
	
	@export_storage var progress: float = 0.0
	@export_storage var efficiency: float = 1.0
	@export_storage var internal_inventory: Inventory = Inventory.new()
	@export var plan: Recipe = null

	@export var work_state: WorkState = WorkState.IDLE
	@export var prod_state: ProdState = ProdState.NORMAL 
	var cached_time_in_minutes: float = 0.0

	signal priority_changed
	enum WorkState {
		IDLE,
		PRODUCING,
		STOPPED
	}
	enum ProdState {
		NORMAL,
		INSUFFICIENT_MATERIAL,
		TOO_MANY_PRODUCT,
	}

	func _init():
		pass
	
	## override
	func update(delta: float):
		if work_state == WorkState.PRODUCING:
			proceed_production(delta)
	
	func proceed_production(delta: float):
		# delta in minute
		if plan == null:
			print("No plan to proceed")
			work_state = WorkState.IDLE
			return
		if cached_time_in_minutes == 0.0:
			cached_time_in_minutes = plan.time_in_hour * 60
		match prod_state:
			ProdState.NORMAL:
				progress += delta * efficiency / cached_time_in_minutes
				if progress >= 100:
					progress = 0
					generate_production()
			ProdState.INSUFFICIENT_MATERIAL:
				check_material()
			ProdState.TOO_MANY_PRODUCT:
				check_space()

	func generate_production():
		if plan == null:
			print("No plan to generate production")
			return
		# add result to internal inventory
		for item in plan.results.keys():
			internal_inventory.add_item(item, plan.results[item])
		# check space
		check_space()
		if prod_state == ProdState.NORMAL:
			prod_state = ProdState.INSUFFICIENT_MATERIAL

	func check_material():
		for item in plan.ingredients.keys():
			if internal_inventory.get_item_amount(item) < plan.ingredients[item]:
				prod_state = ProdState.INSUFFICIENT_MATERIAL
				return
		consume_material()
		prod_state = ProdState.NORMAL
	
	func consume_material():
		for item in plan.ingredients.keys():
			internal_inventory.remove_item(item, plan.ingredients[item])
	
	func check_space():
		for item in plan.results.keys():
			if internal_inventory.get_item_amount(item) > PROD_COEF * plan.results[item]:
				prod_state = ProdState.TOO_MANY_PRODUCT
				return
		prod_state = ProdState.NORMAL
		
	#region plan
	func set_plan(recipe: Recipe):
		plan = recipe
		progress = 0
		work_state = WorkState.PRODUCING
		check_material()

	func clear_plan():
		plan = null
		progress = 0
		work_state = WorkState.IDLE
		prod_state = ProdState.NORMAL
	
	#region production
	func start():
		work_state = WorkState.PRODUCING
	
	func stop():
		work_state = WorkState.STOPPED
	
