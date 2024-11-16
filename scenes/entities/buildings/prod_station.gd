class_name ProdStation extends BaseBuilding


@onready var factory: BaseFactory = $Factory

func set_plan(recipe: Recipe):
	factory.set_recipe(recipe)
	%ProdIcon.texture = recipe.results.keys()[0].icon

func remove_plan():
	%ProdIcon.texture = null
	factory.remove_recipe()


func gen_ctrl_panel():
	var panel: ProdStationCtrl = ctrl_panel.instantiate()
	panel.factory = factory
	return panel


func _on_factory_state_changed(state: BaseFactory.State) -> void:
	match state:
		BaseFactory.State.IDLE:
			set_prod_status('空闲中')
			set_progress(0)
		BaseFactory.State.WORKING:
			set_prod_status('工作中')
		BaseFactory.State.STOPPED:
			set_prod_status('暂停中')


func _on_factory_progress_changed(progress: float) -> void:
	set_progress(progress)
