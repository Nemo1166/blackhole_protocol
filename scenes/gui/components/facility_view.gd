extends Control

@onready var facility_name: Label = $FacilityView/TitleContainer/FacilityName
@onready var outpost_id: Label = $FacilityView/TitleContainer/OutpostID
@onready var unit_view_container: VBoxContainer = %UnitViewContainer

var oid := 0

func _enter_tree() -> void:
	EventBus.subscribe("update_inventory", update_inventory)

func _exit_tree() -> void:
	EventBus.unsubscribe("update_inventory", update_inventory)

func update_inventory(args: Array):
	if args[0] == oid:
		update_warehouse_view(args[1])

func set_facility_info(outpost: OutpostDM.Outpost, facility: OutpostDM.BaseFacility):
	oid = outpost.id
	outpost_id.text = str(oid)
	update_facility_view(facility)
	update_warehouse_view(outpost.inventory._inventory)
	init_units_view(facility.units)

func update_warehouse_view(inventory: Dictionary):
	%WarehouseViewer.update_view(inventory)

func update_facility_view(facility: OutpostDM.BaseFacility):
	facility_name.text = "%s Lv.%d" % [facility.display_name, facility.level]

func init_units_view(units: Array[OutpostDM.ProductionUnit]):
	Global.clear_children(unit_view_container)
	const UNIT_VIEW = preload("res://scenes/gui/components/unit_view.tscn")
	for unit in units:
		var view = UNIT_VIEW.instantiate()
		unit_view_container.add_child(view)
		view.connect_unit(unit)
		
	
