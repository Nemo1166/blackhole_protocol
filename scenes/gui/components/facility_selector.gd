extends Control

var outpost : OutpostDM.Outpost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FacilityContainer/Farm.pressed.connect(build_facility.bind("farm"))
	$FacilityContainer/Mine.pressed.connect(build_facility.bind("mine"))
	$FacilityContainer/CraftL.pressed.connect(build_facility.bind("craftingL"))
	$FacilityContainer/CraftH.pressed.connect(build_facility.bind("craftingH"))
	$FacilityContainer/CraftP.pressed.connect(build_facility.bind("craftingP"))

func pass_oid(value: int):
	outpost = Global.game.terra.get_outpost_data_by_id(value)

func update_desc():
	$Label.text = "选择要建造在 %s 的设施:" % outpost.name

func build_facility(facility_name: StringName):
	match facility_name:
		"farm":
			if outpost.build(OutpostDM.Facilities.Farm.new()):
				print("Build Farm")
		"mine":
			if outpost.build(OutpostDM.Facilities.Mine.new()):
				Global.show_message_box("矿场建造完成", Global.MessageBoxLevel.Info, outpost.name)
			else:
				insufficient_gold()
		# "craftingL":
		# 	if outpost.build(OutpostDM.Facilities.CraftingL.new()):
		# 		print("Build CraftingL")
		# "craftingH":
		# 	if outpost.build_facility("CraftingH"):
		# 		print("Build CraftingH")
		# "craftingP":
		# 	if outpost.build_facility("CraftingP"):
		# 		print("Build CraftingP")
		_:
			print("Unknown facility: %s" % facility_name)
	EventBus.publish("update_outpost_view")
	get_parent().close_dialog.emit()

func insufficient_gold():
	Global.close_all_dialog()
	Global.show_message_box("金币不足", Global.MessageBoxLevel.Error, "建造失败")
