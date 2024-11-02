extends CanvasLayer

@onready var show_fps: Label = %ShowFPS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var fps = 1.0 / delta
	show_fps.text = "FPS: %.2f (%.2f mspf)" % [fps, delta * 1000.0]
