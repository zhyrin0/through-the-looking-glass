extends Position2D


export(int) var speed: int
export(float) var decay_time: float
var reset_position: Vector2
var direction := Vector2.ZERO
var can_animate := true
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var tween := $Tween as Tween


func _init() -> void:
	reset_position = position


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func reset() -> void:
	position = reset_position
	can_animate = true


func play_animation(anim: String) -> void:
	if can_animate:
		animation_player.play(anim)


func break_off() -> void:
	can_animate = false
	animation_player.stop()
	direction = position.normalized()
	var tmp_global_pos := global_position
	# note: Level > Player > Shards
	var new_parent := get_parent().get_parent().get_parent()
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = tmp_global_pos
	tween.interpolate_property(self, "modulate", null, Color(1.0, 1.0, 1.0, 0.0),
		decay_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Tween_tween_all_completed() -> void:
	queue_free()
