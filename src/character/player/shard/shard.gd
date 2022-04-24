extends Position2D


export(int) var speed: int
export(float) var decay_time: float
var direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func break_off() -> void:
	var tmp_global_pos := global_position
	# note: Level > Player > Shards
	var new_parent := get_parent().get_parent().get_parent()
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = tmp_global_pos
	direction = position.normalized()
	var tween := $Tween as Tween
	tween.interpolate_property(self, "modulate", null, Color(1.0, 1.0, 1.0, 0.0),
		decay_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Tween_tween_all_completed() -> void:
	queue_free()
