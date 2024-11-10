extends Control

@onready var t_base: Label = %TimeBasic
@onready var t_ext: Label = %TimeExt
@onready var time_scale: Label = %TimeScale
@onready var panel_container: PanelContainer = $PanelContainer

var panel_keep_show = false


func _ready() -> void:
	panel_container.modulate.a = 0


func update_all(time: DateTime, t_scale: float):
	on_date_changed(time)
	on_time_changed(time)
	on_time_scale_changed(t_scale)


func on_time_changed(time: DateTime) -> void:
	t_base.text = '%d 月 %d 日, %d : %02d' % [
		time.month, time.day, time.hour, (time.minute / 10) * 10,
	]


func on_date_changed(time: DateTime) -> void:
	t_ext.text = '%d 年 %d 月 %d 日' % [
		time.year, time.month, time.day
	]


func on_time_scale_changed(t_scale: float) -> void:
	time_scale.text = '(%.1fx)' % t_scale


func _on_mouse_entered() -> void:
	UITweens.fade_in(panel_container, 0.2, 0)


func _on_mouse_exited() -> void:
	if not panel_keep_show:
		UITweens.fade_out(panel_container, 0.2, 0)
