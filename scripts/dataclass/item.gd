class_name Item extends Resource

enum ItemType {
	MINE,
	RESOURCE,
	MATERIAL,
	COMPONENT,
	PRODUCT,
	CURRENCY,
	OTHER
}

@export var id: int = 0
@export var name: StringName = ""
@export var desc_basic: String = ""
@export var desc_ext: String = ""
@export var icon: Texture = null
@export_range(1,6) var tier: int = 1
@export var type: ItemType = ItemType.OTHER
@export var weight: float = 0.0

@export var is_fuel: bool = false
## available burnt time (as hour)
@export var fuel_value: int = 0 
