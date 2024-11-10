extends VBoxContainer

var building_slot: BaseBuilding

enum SlotType {
	Large,
	Mid,
	Small
}

var slot_type: SlotType

signal close_sidepanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func put_building(scene: Node):
	var parent = building_slot.get_parent()
	var pos = building_slot.position
	parent.add_child(scene)
	scene.position = pos
	building_slot.queue_free()

func build_prod():
	var new = preload("res://scenes/entities/buildings/prod_station.tscn").instantiate()
	put_building(new)
	close_sidepanel.emit()
