class_name SquadDM extends RefCounted

#region Squad Data

enum SquadType{
	Explorer, # 探险队
	Delivery, # 运输队
}

enum ConveyorState {
	Idle,
	Sending,
	Returning,
}

class Conveyor extends Squad:
	@export var capacity: int = 0
	@export_storage var carrying_item: Item = null
	@export var carrying_amount: int = 0

	@export var state: ConveyorState = ConveyorState.Idle

	func _init(location: Vector2i):
		super._init(SquadType.Delivery, location)
		self.capacity = 100

	func load(item: Item, amount: int):
		self.carrying_item = item
		self.carrying_amount = amount
	
	func unload():
		self.carrying_item = null
		self.carrying_amount = 0
		return [self.carrying_item, self.carrying_amount]

	func is_empty() -> bool:
		return self.carrying_item == null
	
	func get_avail_capacity() -> int:
		return self.capacity - self.carrying_amount

	func get_carrying_item() -> Item:
		return self.carrying_item
	
	func get_carrying_amount() -> int:
		return self.carrying_amount


class Explorer extends Squad:
	pass


class Squad extends Resource:
	# @export var id: int = 0
	@export var name: String = ""
	@export var location: Vector2i = Vector2i(0, 0)
	@export_storage var position: Vector2 = Vector2(0, 0)
	@export var destination: Vector2i = Vector2i(0, 0)
	# @export var members: Array[Character] = []
	# @export var leader: Character = null
	@export var type: SquadType = SquadType.Explorer

	func _init(type: SquadType, location: Vector2i):
		# self.id = id
		self.type = type
		self.location = location
		self.position = location
		self.destination = location

	func move_to(to: Vector2i):
		self.destination = to


class Character extends Resource:
	@export var id: int = 0
	@export var name: String = ""
	@export var level: int = 0
