class_name ProdStation extends BaseBuilding

var is_configured: bool = false
var prod_plan: Recipe
var prod_time: int
var efficincy: float = 1

func _process(_delta: float) -> void:
	if not is_configured:
		pass
	else:
		produce()

var is_working: bool = false
var start_time: DateTime
var work_progress: float
func produce():
	# get curr time
	var curr_time: DateTime = Global.game.time_mgr.date_time
	# if idle then start
	if not is_working:
		state_to_work(curr_time)
	else:
		# update progress
		var working_time = curr_time.diff(start_time).get_minutes(false)
		work_progress = (float(working_time) / prod_time) * 100
		#print(start_time)
		#var progress = 50
		if work_progress > 100:
			await UITweens.tween_delay(1)
			work_progress = 0
			state_to_idle()
			# complete
		else:
			set_progress(work_progress)


func set_plan(recipe: Recipe):
	prod_plan = recipe
	prod_time = recipe.time_in_hour * 60
	is_configured = true
	%ProdIcon.texture = recipe.results.keys()[0].icon

func remove_plan():
	prod_plan = null
	is_configured = false
	%ProdIcon.texture = null
	state_to_idle()


func gen_ctrl_panel():
	var panel: ProdStationCtrl = ctrl_panel.instantiate()
	panel.factory = $"."
	return panel


func state_to_idle():
	set_prod_status('空闲中')
	is_working = false
	progress_bar.value = 0

func state_to_work(curr_time: DateTime):
	set_prod_status('工作中')
	is_working = true
	start_time = curr_time.copy()
