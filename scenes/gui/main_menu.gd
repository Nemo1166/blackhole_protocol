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


func _on_button_pressed() -> void:
	%AwakeBtn.text = 'WIP: Please stay in tune.'


func _on_splash_screen_login() -> void:
	$Bg.modulate.a = 1
	print('login')
	Global.set_tween(%CmdContainer, "modulate:a", 1, 0.5)
