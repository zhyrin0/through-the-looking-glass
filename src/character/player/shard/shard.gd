extends Position2D


export(int) var speed: int
export(float) var decay_time: float
var reset_position := Vector2.ZERO
var direction := Vector2.ZERO
var broken_off := false
var break_off_global_pos: Vector2
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var tween := $Tween as Tween


func _init() -> void:
	reset_position = position


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	break_off_global_pos += direction * speed * delta
	global_position = break_off_global_pos


func reset() -> void:
	set_physics_process(false)
	position = reset_position
	modulate = Color.white;
	broken_off = false


func play_animation(anim: String) -> void:
	if not broken_off:
		animation_player.play(anim)


func break_off() -> void:
	broken_off = true
	animation_player.stop()
	direction = position.normalized()
	break_off_global_pos = global_position
	set_physics_process(true)
	tween.interpolate_property(self, "modulate", null, Color(1.0, 1.0, 1.0, 0.0),
		decay_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Tween_tween_all_completed() -> void:
	set_physics_process(false)
