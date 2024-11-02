class_name DateTime extends Resource

const N_MONTH: int = 4
const N_DAY: int = 28

const MINUTE_PER_TICK: int = 1

signal date_changed
signal time_changed

@export_range(0, 59) var minute: int = 0
@export_range(0, 23) var hour: int = 0
@export_range(1, N_DAY) var day: int = 1
@export_range(1, N_MONTH) var month: int = 1
@export_range(0, 9999) var year: int = 1098


var delta_time := 0.0

func minute_increase(delta: float) -> void:
	delta_time += delta
	if delta_time <= MINUTE_PER_TICK: return
	
	time_changed.emit()
	var delta_minute := int(delta_time)
	delta_time -= delta_minute

	minute += delta_minute
	hour += minute / 60
	minute %= 60

	if hour >= 24:
		date_changed.emit()
		day += hour / 24 
		hour %= 24
		if day > N_DAY:
			month += day / N_DAY
			day %= N_DAY
			if month > N_MONTH:
				year += month / N_MONTH
				month %= N_MONTH


func diff(other: DateTime) -> DateTime:
	var t_diff := DateTime.new()
	t_diff.year = year - other.year
	t_diff.month = month - other.month
	t_diff.day = day - other.day
	t_diff.hour = hour - other.hour
	t_diff.minute = minute - other.minute
	return t_diff

func get_minutes(ignore_day: bool = true) -> int:
	if ignore_day:
		# print(minute + hour * 60)
		return minute + hour * 60
	else:
		return minute + hour * 60 + day * 24 * 60 + month * N_DAY * 24 * 60 + year * N_MONTH * N_DAY * 24 * 60
