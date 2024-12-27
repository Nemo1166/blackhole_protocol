extends MarginContainer

@onready var place_holder: Label = $PlaceHolder
@onready var outpost_view: VBoxContainer = $VBoxContainer/OutpostView
@onready var area_info: VBoxContainer = $VBoxContainer/AreaInfo

var current_location: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_holder.show()
	outpost_view.hide()
	area_info.hide()

func _enter_tree() -> void:
	EventBus.subscribe("update_outpost_view", update_outpost_view)
	EventBus.subscribe("update_cell_resources", update_cell_resources)

func _exit_tree() -> void:
	EventBus.unsubscribe("update_outpost_view", update_outpost_view)
	EventBus.unsubscribe("update_cell_resources", update_cell_resources)

func update_cell_resources(args: Array):
	if current_location == args[0]:
		show_res(args[1])

func update_outpost_view(_args: Array):
	show_content(current_location)

var outpost: OutpostDM.Outpost = null
func show_content(loc: Vector2i):
	current_location = loc
	place_holder.hide()
	area_info.show()
	# get cell data
	var cell: MapData.Cell = Global.game.terra.get_cell_data(loc)
	%LocValue.text = str(cell.location)
	show_res(cell.resources)
	# get outpost data
	outpost = Global.game.terra.get_outpost_data(loc)
	if outpost != null:
		print(outpost.name)
		# has outpost
		outpost_view.show()
		## metadata
		%OpName.text = outpost.name
		%OpID.text = "#%d" % outpost.id
		%CurrencyUI.set_value(outpost.get_gold_amount())
		%Populations.text = "^%d" % int(log(outpost.population))
		## facility
		%FacCounter.text = "%d/%d" % [outpost._facilities.size(), outpost.max_facility]
		
		var facilities = outpost.get_all_facilities()
		%Facilities.update_facilities(facilities)
	else:
		# has no outpost
		outpost_view.hide()

func show_res(res: MapData.CellRes):
	%CellRes.text = "|木:%d|石:%d|铁:%d" % [res.wood, res.stone, res.iron]

func clear():
	place_holder.show()
	outpost_view.hide()
	area_info.hide()

func update_placeholder(reachable: bool):
	if reachable:
		place_holder.text = '选中区域以查看详情.'
	else:
		place_holder.text = '(区域未开放)'

signal build_outpost
func _on_build_outpost() -> void:
	build_outpost.emit()

signal build_facility
func _on_build_facility_pressed() -> void:
	if outpost.can_build_facility():
		build_facility.emit()
	else:
		%BuildFacility.text = "Insufficient space."
