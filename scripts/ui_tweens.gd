extends Node2D


func tween_delay(duration: float) -> void:
	await get_tree().create_timer(duration).timeout


func hide_all_children(node: Node) -> void:
	for child in node.get_children():
		child.hide()


func set_tween(node, property, to, duration, delay: float=0, transition: Tween.TransitionType=Tween.TRANS_CUBIC) -> void:
	if delay > 0:
		await tween_delay(delay)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, property, to, duration).set_trans(transition)


func fade_in(node: Node, duration: float, delay: float = 0.0) -> void:
	await tween_delay(delay)
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_CUBIC)


func fade_out(node: Node, duration: float, delay: float = 0.0, is_delete: bool = false) -> void:
	await tween_delay(delay)
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_CUBIC)
	if is_delete:
		await get_tree().create_timer(duration).timeout
		node.queue_free()


func change_text(node: Label, text: String, duration: float, delay: float = 0.0) -> void:
	await set_tween(node, "text", text, duration, delay)
