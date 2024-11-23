extends Node
class_name TimeMgr


signal date_changed(date: DateTime)
signal time_changed(time: DateTime)
signal time_scale_changed(t_scale: float)

@export var date_time: DateTime
@export var time_scale: int = 6 # 6 minutes (in game) per second (real time)

const AVAIL_TIME_SCALE: Array = [0.5, 1, 2, 4, 12, 60]
var current_time_scale_idx: int = 1

var is_paused: bool = false

enum DayState {DAY, TWILIGHT, NIGHT, DAWN}
var curr_state: DayState = DayState.DAY
@export var day_time: DateTime
@export var twilight_time: DateTime
@export var night_time: DateTime
@export var dawn_time: DateTime
signal day_state_changed(state: DayState)



func _ready() -> void:
	date_time.connect("date_changed", self._on_date_changed)
	date_time.connect("time_changed", self._on_time_changed)
	process_day_state()

func _process(delta: float) -> void:
	handle_input()
	if is_paused: return

	date_time.minute_increase(delta * time_scale * AVAIL_TIME_SCALE[current_time_scale_idx])
	process_day_state()


func process_day_state() -> void:
	# dawn -> day -> twilight -> night
	# 5 -> 6 -> 18 -> 20
	var curr_minutes = date_time.get_minutes(true)
	# day -> twilight
	if curr_minutes >= dawn_time.get_minutes(true) and curr_minutes < day_time.get_minutes(true):
		if curr_state != DayState.DAWN:
			curr_state = DayState.DAWN
			day_state_changed.emit(curr_state)
	# twilight -> night
	elif curr_minutes >= day_time.get_minutes(true) and curr_minutes < twilight_time.get_minutes(true):
		if curr_state != DayState.DAY:
			curr_state = DayState.DAY
			day_state_changed.emit(curr_state)
	# night -> dawn
	elif curr_minutes >= twilight_time.get_minutes(true) and curr_minutes < night_time.get_minutes(true):
		if curr_state != DayState.TWILIGHT:
			curr_state = DayState.TWILIGHT
			day_state_changed.emit(curr_state)
	# dawn -> day
	elif curr_minutes >= night_time.get_minutes(true) or curr_minutes < dawn_time.get_minutes(true):
		if curr_state != DayState.NIGHT:
			curr_state = DayState.NIGHT
			day_state_changed.emit(curr_state)


func handle_input() -> void:
	if Input.is_action_just_pressed("pause"):
		is_paused = !is_paused
		# if is_paused:
		# 	time_scale = 0
		# else:
		# 	time_scale = AVAIL_TIME_SCALE[current_time_scale_idx]
	if Input.is_action_just_pressed("speed_up"):
		if current_time_scale_idx < AVAIL_TIME_SCALE.size() - 1:
			current_time_scale_idx += 1
			time_scale_changed.emit(AVAIL_TIME_SCALE[current_time_scale_idx])
		pass
	if Input.is_action_just_pressed("speed_down"):
		if current_time_scale_idx > 0:
			current_time_scale_idx -= 1
			time_scale_changed.emit(AVAIL_TIME_SCALE[current_time_scale_idx])
		pass


func _on_date_changed() -> void:
	date_changed.emit(date_time)

func _on_time_changed() -> void:
	time_changed.emit(date_time)


#func _on_day_state_changed(state: TimeMgr.DayState) -> void:
	##const state_str = ["DAY", "TWILIGHT", "NIGHT", "DAWN"]
	##print('State changed to %s' % state_str[state])
	#pass # Replace with function body.
