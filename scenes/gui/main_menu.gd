extends Control

@onready var cmd_container: VBoxContainer = %CmdContainer

var show_cmd: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children = get_children()
	for child in children:
		if not child == %SplashScreen:
			child.modulate.a = 0


var is_quitting := false
func _on_exit_btn_button_up() -> void:
	if is_quitting:
		get_tree().quit()
	else:
		%ExitBtn.text = 'Sure?'
		is_quitting = true


func _on_exit_btn_mouse_exited() -> void:
	%ExitBtn.text = 'Exit'
	is_quitting = false


func _on_awake() -> void:
	%AwakeBtn.text = "正在尝试建立神经连接"
	%AwakeBtn.disabled = true
	WorkerThreadPool.add_task(func():
		Global.game_ctrl.start_new_game())
	


func _on_splash_screen_login() -> void:
	$bg.modulate.a = 1
	print('login')
	UITweens.set_tween(%CmdContainer, "modulate:a", 1, 0.5)
