extends "level_base.gd"


onready var eyes := $Eyes as Area2D
onready var anim_player := $Eyes/AnimationPlayer as AnimationPlayer
onready var win := $Win as Sprite


func _ready() -> void:
	anim_player.play("float")


func _on_EnterArea_body_entered(_body: Node) -> void:
	left_barrier.set_collision_layer_bit(BARRIER_COLLISION_BIT, true)
	var enter_area := $EnterArea as Area2D
	enter_area.set_deferred("monitoring", false)
	enter_area.set_deferred("monitorable", false)
	emit_signal("entered", self)
	eyes.set_deferred("monitoring", true)
	yield(get_tree().create_timer(wave_cooldown.wait_time), "timeout")
	
	start()


func _on_Eyes_area_entered(area: Area2D) -> void:
	win.show()
	eyes.queue_free()
