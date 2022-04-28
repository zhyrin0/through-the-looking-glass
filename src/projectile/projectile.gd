extends Sprite


enum Owner {
	PLAYER = 0,
	ENEMY = 1,
}

enum State {
	CLAY = 0,
	GLASS = 1,
}

export(int) var speed: int
var start_global_pos := Vector2.ZERO
var direction := Vector2.ZERO
var is_strong := false
var collided := false
var state: int = State.CLAY
onready var area := $Area2D as Area2D
onready var fly_particles := $FlyParticles as Particles2D
onready var shatter_particles := $ShatterParticles as Particles2D
onready var shatter_audio := $ShatterAudio as AudioStreamPlayer
onready var delete_timer := $DeleteTimer as Timer
onready var shader := material as ShaderMaterial


func init(p_state: int, p_owner: int, p_start_global_pos: Vector2, p_direction: Vector2, p_is_strong: bool) -> void:
	start_global_pos = p_start_global_pos
	direction = p_direction
	is_strong = p_is_strong
	yield(self, "ready")
	
	state = p_state
	shader.set_shader_param("transition", 0.0)
	shader.set_shader_param("to_state", 1 - p_state)
	if state == State.CLAY:
		speed *= 0.5
	fly_particles.visible = state == State.CLAY
	shatter_particles.visible = state == State.GLASS
	
	global_position = p_start_global_pos
	rotation = direction.angle()
	area.set_collision_mask_bit(1 - p_owner, true)
	var shoot_audio := $ShootAudio as AudioStreamPlayer
	shoot_audio.pitch_scale = rand_range(0.9, 1.1)


func _process(_delta: float) -> void:
	if is_strong:
		update()


func _physics_process(delta: float) -> void:
	var velocity := direction * speed * delta
	position += velocity


func _draw() -> void:
	var colors := [
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, delete_timer.time_left / delete_timer.wait_time),
	]
	draw_polyline_colors([to_local(start_global_pos), to_local(global_position)], colors)


func set_transition_initial_values(to_state: int, orb_screen_uv: Vector2) -> void:
	state = to_state
	fly_particles.visible = state == State.CLAY
	shatter_particles.visible = state == State.GLASS
	shader.set_shader_param("transition", 0.0)
	shader.set_shader_param("to_state", to_state)
	shader.set_shader_param("orb_screen_uv", orb_screen_uv)


func animate_transition(transition: float) -> void:
	shader.set_shader_param("transition", transition)


func _on_Area2D_body_entered(body: Node) -> void:
	if collided:
		return
	collided = true
	area.set_deferred("monitoring", false)
	if body.has_method("on_hit"):
		body.call("on_hit")
	self_modulate = Color.transparent
	fly_particles.emitting = false
	shatter_particles.emitting = true
	if state == State.GLASS:
		shatter_audio.play()
	else:
		queue_free()
	delete_timer.stop()
	set_process(false)
	set_physics_process(false)


func _on_ShatterAudio_finished() -> void:
	queue_free()


func _on_DeleteTimer_timeout() -> void:
	queue_free()
