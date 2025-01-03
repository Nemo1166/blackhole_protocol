class_name OutpostDM extends RefCounted

#region Facilities
const PROD_COEF := 10
const REQ_COEF := 2

class Facilities:
	class BaseWorkshop extends BaseFacility:
		@export var units: Array[ProductionUnit] = []
		@export_storage var progress: float = 0.0
		@export var productivity: float = 1.0
		@export var acceptable_recipe: Recipe.Type = Recipe.Type.Other

		func _init():
			name = "BaseWorkshop"
		
		func update(delta: float):
			for unit in units:
				unit.update(delta)
			manage_inventory()
		
		func add_unit(unit: ProductionUnit) -> ProductionUnit:
			unit.priority_changed.connect(allocate_productivity)
			unit.location = outpost.location
			unit.acceptable_recipe = acceptable_recipe
			units.append(unit)
			return unit

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
				if unit.plan == null:
					continue
				# check material
				if unit.prod_state == ProductionUnit.ProdState.INSUFFICIENT_MATERIAL:
					for item in unit.plan.ingredients.keys():
						if outpost.get_item_amount(item) >= unit.plan.ingredients[item]:
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
		
		func get_cost(facility_level: int) -> int:
			match facility_level:
				1: return 100 # new
				2: return 120  # upgrade
				3: return 180 # upgrade
			return -1

	class Mine extends BaseWorkshop:
		func _init():
			name = "Mine"
			display_name = "采集场"
			acceptable_recipe = Recipe.Type.Mining
		
		func get_cost(facility_level: int) -> int:
			match facility_level:
				1: return 150 # new
				2: return 200  # upgrade
				3: return 320 # upgrade
			return -1
	
	class Crafting extends BaseWorkshop:
		func _init():
			name = "Crafting"
			display_name = "制造站"
			acceptable_recipe = Recipe.Type.Crafting_L
		
		func get_cost(facility_level: int) -> int:
			match facility_level:
				1: return 200 # new
				2: return 240  # upgrade
				3: return 320 # upgrade
			return -1

#region DataClass

class Outpost extends Resource:
	@export var id: int
	@export var name: String
	@export var owner: int

	@export var location: Vector2i
	@export_storage var population: int
	@export_storage var inventory: Inventory = Inventory.new()

	@export var _facilities: Array[BaseFacility] = []
	@export_storage var max_facility: int = 3
	@export_storage var trade_station: TradeStation = TradeStation.new()

	func _init(id: int, name: String, owner: int, location: Vector2i):
		self.id = id
		self.name = name
		self.owner = owner
		self.location = location
		population = 10
		inventory.item_changed.connect(update_ports)

		trade_station.outpost = self
		trade_station.add_conveyor()
		trade_station.add_conveyor()

	#region Manage Facilities

	func build(facility: BaseFacility, is_free: bool = false) -> bool:
		if not can_build_facility():
			print("Outpost is full")
			return false
		if is_free:
			_add_facility(facility)
			return true
		if not has_enough_gold(facility.get_cost(1)):
			print("Not enough gold")
			return false
		inventory.remove_item(Global.items[4], facility.get_cost(1))
		_add_facility(facility)
		return true
	
	func _add_facility(facility: BaseFacility):
		facility.outpost = self
		_facilities.append(facility)
		if facility is Facilities.BaseWorkshop:
			facility.add_unit(ProductionUnit.new())
	
	func destroy(facility: BaseFacility):
		if _facilities.has(facility):
			# return 80% of the cost
			inventory.add_item(Global.items[4], int(facility.get_cost(facility.level) * 0.8))
			_facilities.erase(facility)
		else:
			print("Facility not found")
	
	func can_build_facility() -> bool:
		return _facilities.size() < max_facility
	
	func has_enough_gold(cost: int) -> bool:
		return get_gold_amount() >= cost

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
			print("Deliver item: %s, amount: %d from %s to %s" % [item.name, amount, from, to])
			EventBus.publish("update_inventory", [self.id, inventory._inventory])
		else:
			print("Not enough item to deliver")
	
	func export_items(item: Item, amount: int) -> int:
		var avail_amount = inventory.get_item_amount(item)
		var actual_amount = min(avail_amount, amount)
		inventory.remove_item(item, actual_amount)
		return actual_amount
	
	func import_items(item: Item, amount: int):
		inventory.add_item(item, amount)
	
	func update_ports(item: Item):
		for port in trade_station.ports:
			if port.get_item() == item:
				port.storage = get_item_amount(item)
				break
		
class Inventory extends Resource:
	@export_storage var _inventory: Dictionary = {} # item: amount

	signal item_changed(item: Item)

	func add_item(item: Item, amount: int):
		if not _inventory.has(item):
			_inventory[item] = amount
		else:
			_inventory[item] += amount
		item_changed.emit(item)
	
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
			item_changed.emit(item)
		else:
			print("Not enough item to remove")

class BaseFacility extends Resource:
	@export var name: StringName = ""
	@export var display_name: String = ""
	@export var level: int = 1
	@export_storage var outpost: Outpost

	func _init():
		pass
	
	## override
	func update(_delta: float):
		print("Facility update")
	
	func get_cost(level: int) -> int:
		return 0

class ProductionUnit extends Resource:
	@export var name: StringName = ""
	@export var cost: int = 0
	@export var level: int = 1
	@export var priority: int = 0:
		set(value):
			if value != priority:
				priority = value
				emit_signal("priority_changed")
	
	@export_storage var location: Vector2i = Vector2i(0, 0)
	@export_storage var acceptable_recipe: Recipe.Type = Recipe.Type.Other
	@export_storage var progress: float = 0.0
	@export_storage var efficiency: float = 1.0
	@export_storage var internal_inventory: Inventory = Inventory.new()
	@export var plan: Recipe = null

	signal work_state_changed(work_state: WorkState)
	@export var work_state: WorkState = WorkState.IDLE:
		set(value):
			if value != work_state:
				work_state = value
				work_state_changed.emit(value)
	
	signal prod_state_changed(prod_state: ProdState)
	@export var prod_state: ProdState = ProdState.NORMAL:
		set(value):
			if value != prod_state:
				prod_state = value
				prod_state_changed.emit(value) 
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
				progress += delta * efficiency / cached_time_in_minutes * 100
				# print("Progress: %f" % progress)
				if progress >= 100:
					progress = 0
					generate_production()
			ProdState.INSUFFICIENT_MATERIAL:
				check_material()

	func generate_production():
		if plan == null:
			print("No plan to generate production")
			return
		if plan.type == Recipe.Type.Mining:
			var result: Item = plan.results.keys()[0]
			# get available amount from map
			var avail_amount = Global.game.terra.collect_cell_resources(
									location, result.name, plan.results[result])
			if avail_amount > 0:
				internal_inventory.add_item(result, avail_amount)
				# print("Production generated: %s, amount: %d" % [result.name, avail_amount])
			else:
				# no available resource in map
				print("No available resource %s in map" % result.name)
				return
		else:
			# add result to internal inventory
			for item in plan.results.keys():
				internal_inventory.add_item(item, plan.results[item])
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
		
	#region plan
	func set_plan(recipe: Recipe):
		if recipe == plan:
			return
		plan = recipe
		progress = 0
		work_state = WorkState.PRODUCING
		cached_time_in_minutes = recipe.time_in_hour * 60
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
	
#region delivery

class TradeStation extends BaseFacility:
	@export var ports: Array[Port] = []
	@export var max_port: int = 3
	@export var conveyors: Array[SquadDM.Conveyor] = []
	@export var max_conveyor: int = 6

	func _init():
		name = "TradeStation"
		add_port()
		add_port()
		add_port()
	
	func add_port():
		if ports.size() < max_port:
			var port = Port.new()
			# port.id = ports.size()
			ports.append(port)
			return port
		return null
	
	func remove_port(port: Port):
		if ports.has(port):
			ports.erase(port)

	func add_conveyor():
		var conveyor = SquadDM.Conveyor.new(outpost.location)
		conveyors.append(conveyor)
		return conveyor
	

enum TradeMode {
	Request,
	Supply,
	Storage
}

class Port extends Resource:
	# @export var id: int = 0
	@export var _mode: TradeMode = TradeMode.Storage
	@export var _item: Item = null
	@export_storage var storage: int = 0:
		set(value):
			if value != storage:
				storage = value
				stat_changed.emit()
	
	@export var setting_amount: int = 0 # 需求：最大需求；供给：最小保留
	@export_storage var reserved_amount: int = 0

	signal stat_changed

	func set_item(item: Item):
		self._item = item
		self._mode = TradeMode.Storage
	
	func get_item() -> Item:
		return _item

	func set_mode(mode: TradeMode):
		self._mode = mode
		setting_amount = 0
	
	func get_mode() -> TradeMode:
		return _mode

	func clear():
		_item = null
		_mode = TradeMode.Storage
		storage = 0
		setting_amount = 0
