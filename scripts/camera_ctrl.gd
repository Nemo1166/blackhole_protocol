extends Camera2D

var camera_speed = 150.0

var camera_limit = Rect2(0, 0, 1280, 720)

var camera_dragging = false

const CAMERA_MARGIN = 100

var _prev_mouse_pos: Vector2
var _camera_movement: Vector2


func _physics_process(delta: float) -> void:
	if _is_zooming:
		zoom = zoom.lerp(_target_zoom * Vector2.ONE, delta * ZOOM_SPEED)
		_is_zooming = not is_equal_approx(_target_zoom, zoom.x)

	if camera_dragging:
		_camera_movement = (_prev_mouse_pos - get_local_mouse_position()) * zoom
	else:
		_camera_movement = Vector2.ZERO
	position += _camera_movement * delta * camera_speed
	_prev_mouse_pos = get_local_mouse_position()

	# 边缘滚动
	var _viewport: Rect2 = get_viewport_rect()
	var _m = get_local_mouse_position() + _viewport.size * 0.5
	if _viewport.size.x - _m.x <= CAMERA_MARGIN:
		_camera_movement.x += camera_speed * delta
	if _viewport.size.y - _m.y <= CAMERA_MARGIN:
		_camera_movement.y += camera_speed * delta
	if _m.x <= CAMERA_MARGIN:
		_camera_movement.x -= camera_speed * delta
	if _m.y <= CAMERA_MARGIN:
		_camera_movement.y -= camera_speed * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			camera_dragging = event.pressed
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_out()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_in()
	process_wasd(event)
	if event.is_action_pressed("reset_camera"):
		reset_camera()


# zoom
var _target_zoom: float = zoom.x
var _is_zooming = false
const ZOOM_SPEED = 5.0
const ZOOM_INCREMENT = 0.1

var camera_zoom_min = 0.4
var camera_zoom_max = 1.5

func _zoom_in():
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, camera_zoom_min)
	_is_zooming = true

func _zoom_out():
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, camera_zoom_max)
	_is_zooming = true


func process_wasd(event: InputEvent):
	const DELTA = 1.0/60
	if event.is_action_pressed("camera_up"):
		_camera_movement.y -= camera_speed * DELTA
	if event.is_action_pressed("camera_down"):
		_camera_movement.y += camera_speed * DELTA
	if event.is_action_pressed("camera_left"):
		_camera_movement.x -= camera_speed * DELTA
	if event.is_action_pressed("camera_right"):
		_camera_movement.x += camera_speed * DELTA


func focus_on(pos: Vector2):
	position = pos

func reset_camera():
	position = Vector2.ZERO
	zoom = Vector2.ONE
	_target_zoom = 1.0
	_is_zooming = false
	camera_dragging = false
	_camera_movement = Vector2.ZERO
	_prev_mouse_pos = Vector2.ZERO
