extends CanvasLayer

@onready var play_stat: Label = %PlayStat
@onready var config: VBoxContainer = $Config

@onready var left_subtitle: Label = %Subtitle
@onready var left_title: Label = %Title


var time_status: bool
func _ready() -> void:
	time_status = Global.game.time_mgr.is_paused
	Global.game.time_mgr.is_paused = true
	AudioMgr.toggle_bgm_effect(true)
	config.hide()
	clear_left_title()

func set_play_stat(terra_time: String, play_time_sec: int) -> void:
	play_stat.text = "Seed: %010d\n%s\nPlaytime: %02d:%02d:%02d" % [
		Global.game_seed, 
		terra_time, 
		play_time_sec / 3600, play_time_sec % 3600 / 60, play_time_sec % 60]

func _exit_tree() -> void:
	Global.game.time_mgr.is_paused = time_status

func _on_resume_pressed() -> void:
	AudioMgr.toggle_bgm_effect(false)
	PlaytimeManager.resume_all()
	self.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		self.queue_free()


func _on_settings_btn_pressed() -> void:
	left_title.text = "设置"
	left_subtitle.text = "Configuration"
	
	close_other_panel()
	config.show()

func clear_left_title():
	%Title.text = ""
	%Subtitle.text = ""

func close_other_panel():
	config.hide()
