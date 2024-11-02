extends DirectionalLight2D


@export var day_light: Color
@export var twilight_light: Color
@export var night_light: Color
@export var dawn_light: Color

@export var transition_duration: float = 30 # in minute
@export var time_system: TimeMgr

var curr_state: TimeMgr.DayState = TimeMgr.DayState.DAY

func _ready() -> void:
	# transition(TimeMgr.curr_state)
	pass


func transition(state: TimeMgr.DayState) -> void:
	if curr_state == state: return
	else:
		curr_state = state
		match state:
			TimeMgr.DayState.DAY:
				transition_to(day_light)
			TimeMgr.DayState.TWILIGHT:
				transition_to(twilight_light)
			TimeMgr.DayState.NIGHT:
				transition_to(night_light)
			TimeMgr.DayState.DAWN:
				transition_to(dawn_light)

func transition_to(target: Color) -> void:
	#print('begin transition')
	var trans_tween = get_tree().create_tween()
	trans_tween.tween_property(
		self, "color", target, 
		transition_duration / (time_system.time_scale * time_system.AVAIL_TIME_SCALE[time_system.current_time_scale_idx])
	)
