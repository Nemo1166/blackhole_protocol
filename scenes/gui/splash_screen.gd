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
	await UITweens.fade_in(%Bg, 1, 0)
	await UITweens.fade_in(%PRTS, 1, 0.8)
	await UITweens.set_tween(%PRTS, "position:y", %PRTS.position.y - 40, 1, 1)
	await UITweens.tween_delay(1.3)
	UITweens.fade_in($FingerPrint, 0.5)
	blink_login_prompt = true
	is_login = false
	

var is_login:=true
var timer: float = -PI/4
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
		if child is Control:
			child.modulate.a = 0


func _on_login() -> void:
	$TouchSFX.play()
	UITweens.fade_in(login_prompt, 0.5)
	UITweens.change_text(login_prompt, "Authenticating...", 0.5)
	UITweens.fade_out($FingerPrint, 0.5, 0, true)
	await UITweens.change_text(login_prompt, "Authentication success, access granted.", 0.5, 1.5)
	await UITweens.tween_delay(1)
	login.emit()
	UITweens.fade_out(bg, 0.5, 0, true)
	# Global.set_tween(%CurrUser, "modulate:a", 1, 0.5)
	UITweens.fade_in(%CurrUser, 0.5)
	await UITweens.change_text(login_prompt, "Welcome back, Doctor.", 0.5, 1.5)
	#await UITweens.fade_out(login_prompt, 0.5, 4, true)
	$TouchSFX.queue_free()
