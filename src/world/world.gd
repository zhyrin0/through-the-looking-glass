extends Node2D


onready var tween := $GlassTransition as Tween


func _on_Player_orb_used(to_state: int, orb_screen_uv: Vector2, transition_time: float) -> void:
	for transitioner in get_tree().get_nodes_in_group("transitioning"):
		transitioner.set_transition_initial_values(to_state, orb_screen_uv)
		tween.interpolate_method(transitioner, "animate_transition", 0.0, 1.0,
				transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
