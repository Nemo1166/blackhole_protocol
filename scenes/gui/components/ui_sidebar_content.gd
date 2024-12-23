extends MarginContainer

@onready var place_holder: Label = $PlaceHolder
@onready var outpost_view: VBoxContainer = $VBoxContainer/OutpostView
@onready var area_info: VBoxContainer = $VBoxContainer/AreaInfo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_holder.show()
	outpost_view.hide()
	area_info.hide()

func show_content(loc: Vector2i):
	place_holder.hide()
	area_info.show()
	# get cell data
	var cell: MapData.Cell = Global.game.terra.get_cell_data(loc)
	%LocValue.text = str(cell.location)
	%ResW.text = "木材: %d" % cell.resources.wood
	%ResS.text = "石材: %d" % cell.resources.stone
	%ResF.text = "食物: %d" % cell.resources.food
	%ResM.text = "矿物: %d" % cell.resources.metal
	# get outpost data
	var outpost: OutpostDM.Outpost = Global.game.terra.get_outpost_data(loc)
	print(outpost)
	if outpost != null:
		# has outpost
		%BuildOutpostBtn.hide()
		outpost_view.show()
		%OpName.text = outpost.name
		%OpID.text = "#%d" % outpost.id
		%CurrencyUI.set_value(outpost.get_gold_amount())
		%Populations.text = "^%d" % int(log(outpost.population))
		var facilities = outpost.get_all_facilities()
		for fac: OutpostDM.BaseFacility in facilities:
			var b = Button.new()
			%Facilities.add_child(b)
			b.text = fac.name
	else:
		# has no outpost
		%BuildOutpostBtn.show()
		outpost_view.hide()

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
func _on_build_outpost_pressed() -> void:
	build_outpost.emit()
