extends KinematicBody2D


enum Owner {
	PLAYER = 0,
	ENEMY = 1,
}

export(int) var speed: int
var start_global_pos := Vector2.ZERO
var direction := Vector2.ZERO
var is_strong := false
onready var shatter_audio := $ShatterAudio as AudioStreamPlayer
onready var delete_timer := $DeleteTimer as Timer


func init(p_owner: int, p_start_global_pos: Vector2, p_direction: Vector2, p_is_strong: bool) -> void:
	start_global_pos = p_start_global_pos
	direction = p_direction
	is_strong = p_is_strong
	yield(self, "ready")
	
	global_position = p_start_global_pos
	rotation = direction.angle()
	set_collision_mask_bit(1 - p_owner, true)
	var shoot_audio := $ShootAudio as AudioStreamPlayer
	shoot_audio.pitch_scale = rand_range(0.9, 1.1)


func _process(_delta: float) -> void:
	if is_strong:
		update()


func _physics_process(delta: float) -> void:
	var velocity := direction * speed * delta
	if move_and_collide(velocity):
		# hack: While the projectile is not deleted (playing shatter audio)
		# it interferes with character movement, so it's teleported away.
		global_position = Vector2(-1.0, -1.0) * 100.0
		collision_layer = 0
		visible = false
		shatter_audio.play()
		delete_timer.stop()
		set_process(false)
		set_physics_process(false)


func _draw() -> void:
	var colors := [
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, delete_timer.time_left / delete_timer.wait_time),
	]
	draw_polyline_colors([to_local(start_global_pos), to_local(global_position)], colors)


func _on_ShatterAudio_finished() -> void:
	queue_free()


func _on_DeleteTimer_timeout() -> void:
	queue_free()
