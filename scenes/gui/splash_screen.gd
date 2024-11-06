extends Control

@onready var solid_bg: ColorRect = $Bg/SolidBG
@onready var bg: MarginContainer = %Bg
@onready var login_prompt: Label = $LoginPrompt

signal login
var blink_login_prompt = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _time = Time.get_datetime_dict_from_system().hour
	hide_all()
	Global.set_tween(%Bg, "modulate:a", 1, 0.5)
	await get_tree().create_timer(0.8).timeout
	Global.set_tween(%PRTS, "modulate:a", 1, 0.5)
	await get_tree().create_timer(0.8).timeout
	Global.set_tween(%PRTS, "position:y", %PRTS.position.y - 40, 1)
	await get_tree().create_timer(1.3).timeout
	blink_login_prompt = true

var is_login:=false
var timer: float = 0
func _process(delta: float) -> void:
	if not is_login:
		if Input.is_anything_pressed():
			is_login = true
			blink_login_prompt = false
			_on_login()
		if blink_login_prompt:
			timer += delta
			login_prompt.modulate.a = 0.5*(sin(timer*2)+1)


func hide_all():
	var children = get_children()
	for child in children:
		child.modulate.a = 0


func _on_login() -> void:
	Global.set_tween(login_prompt, "modulate:a", 1, 0.5)
	Global.set_tween(login_prompt, "text", "Authenticating...", 0.5)
	await get_tree().create_timer(1.5).timeout
	Global.set_tween(login_prompt, "text", "Authentication success, access granted.", 0.5)
	await get_tree().create_timer(2).timeout
	login.emit()
	Global.set_tween(%CurrUser, "modulate:a", 1, 0.5)
	await get_tree().create_timer(0.5).timeout
	Global.set_tween(login_prompt, "text", "Welcome back, Doctor.", 0.5)
	bg.queue_free()
	await get_tree().create_timer(4).timeout
	Global.set_tween(login_prompt, "modulate:a", 0, 0.5)
	await get_tree().create_timer(0.5).timeout
	login_prompt.queue_free()
