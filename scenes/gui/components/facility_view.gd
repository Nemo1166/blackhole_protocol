extends Control

@onready var facility_name: Label = $FacilityView/TitleContainer/FacilityName
@onready var outpost_id: Label = $FacilityView/TitleContainer/OutpostID
@onready var unit_view_container: VBoxContainer = %UnitViewContainer

var outpost: OutpostDM.Outpost
var this_facility: OutpostDM.BaseFacility

#func _enter_tree() -> void:
	#EventBus.subscribe("update_inventory", update_inventory)
#
#func _exit_tree() -> void:
	#EventBus.unsubscribe("update_inventory", update_inventory)

#func update_inventory(args: Array):
	#if args[0] == outpost.id:
		#update_warehouse_view(args[1])

func set_facility_info(facility: OutpostDM.BaseFacility):
	outpost = facility.outpost
	this_facility = facility
	outpost_id.text = str(outpost.id)
	update_facility_view(facility)
	#Global.clear_children(unit_view_container)
	if is_instance_of(facility, OutpostDM.Facilities.BaseWorkshop):
		init_units_view(facility.units)

func update_facility_view(facility: OutpostDM.BaseFacility):
	facility_name.text = "%s Lv.%d" % [facility.display_name, facility.level]

func init_units_view(units: Array[OutpostDM.ProductionUnit]):
	const UNIT_VIEW = preload("res://scenes/gui/components/unit_view.tscn")
	for unit in units:
		var view = UNIT_VIEW.instantiate()
		unit_view_container.add_child(view)
		view.connect_unit(unit)


func _on_destroy_facility() -> void:
	outpost.destroy(this_facility)
	EventBus.publish("update_outpost_view")
	Global.close_all_dialog()
