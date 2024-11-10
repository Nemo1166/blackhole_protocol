extends CanvasLayer


@export var time_mgr: TimeMgr
@onready var time_ui: Control = %TimeUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_mgr.date_changed.connect(time_ui.on_date_changed)
	time_mgr.time_changed.connect(time_ui.on_time_changed)
	time_mgr.time_scale_changed.connect(time_ui.on_time_scale_changed)
	time_ui.update_all(time_mgr.date_time, time_mgr.AVAIL_TIME_SCALE[time_mgr.current_time_scale_idx])
