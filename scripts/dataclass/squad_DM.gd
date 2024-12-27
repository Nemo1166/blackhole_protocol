class_name SquadDM extends RefCounted

#region Squad Data

enum SquadType{
	Explorer, # 探险队
	Trader, # 商队
	Delivery, # 运输队
}

class Squad extends Resource:
	@export var id: int = 0
	@export var name: String = ""
	@export var location: Vector2i = Vector2i(0, 0)
	@export_storage var position: Vector2i = Vector2i(0, 0)
	@export var destination: Vector2i = Vector2i(0, 0)
	@export var housing: int = 0
	# @export var members: Array[Character] = []
	# @export var leader: Character = null
	@export var type: SquadType = SquadType.Explorer

	func _init(id: int, type: SquadType, housing: int, location: Vector2i):
		self.id = id
		self.type = type
		self.housing = housing
		self.location = location
		self.position = location
		self.destination = location

	func move_to(to: Vector2i):
		self.destination = to


class Character extends Resource:
	@export var id: int = 0
	@export var name: String = ""
	@export var level: int = 0

