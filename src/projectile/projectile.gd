extends KinematicBody2D


const PLATFORM_COLLISION_BIT := 3
export(int) var speed: int
var start_global_pos := Vector2.ZERO
var direction := Vector2.ZERO
var is_strong := false
onready var shatter_audio := $ShatterAudio as AudioStreamPlayer
onready var delete_timer := $DeleteTimer as Timer


func init(p_start_global_pos: Vector2, p_direction: Vector2, p_is_strong: bool) -> void:
	start_global_pos = p_start_global_pos
	direction = p_direction
	is_strong = p_is_strong
	yield(self, "ready")
	
	global_position = p_start_global_pos
	rotation = direction.angle()
	set_collision_mask_bit(PLATFORM_COLLISION_BIT, not is_strong)
	var shoot_audio := $ShootAudio as AudioStreamPlayer
	shoot_audio.pitch_scale = rand_range(0.9, 1.1)


func _process(_delta: float) -> void:
	if is_strong:
		update()


func _physics_process(delta: float) -> void:
	var velocity := direction * speed * delta
	if move_and_collide(velocity):
		collision_layer = 0
		set_process(false)
		set_physics_process(false)
		visible = false
		shatter_audio.play()
		delete_timer.stop()


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
