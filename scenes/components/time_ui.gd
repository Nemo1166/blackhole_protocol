extends Control

@onready var t_label: Label = %TimeShow
@onready var time_scale: Label = %TimeScale


func _on_time_mgr_time_changed(time: DateTime) -> void:
	t_label.text = '%d 年 %d 月 %d 日    %d : %d' % [
		time.year,
		time.month,
		time.day,
		time.hour,
		time.minute,
	]


func _on_time_mgr_time_scale_changed(t_scale: float) -> void:
	time_scale.text = '(%.1fx)' % t_scale
