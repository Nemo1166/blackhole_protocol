extends CanvasLayer


var time_status: bool
func _ready() -> void:
	time_status = Global.game.time_mgr.is_paused
	Global.game.time_mgr.is_paused = true
	AudioMgr.toggle_bgm_effect(true)


func _exit_tree() -> void:
	Global.game.time_mgr.is_paused = time_status


func _on_resume_pressed() -> void:
	AudioMgr.toggle_bgm_effect(false)
	self.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		self.queue_free()
