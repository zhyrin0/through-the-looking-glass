extends Node2D

const LevelBase := preload("res://src/level/level_base.gd")


onready var levels := $Levels as Node
onready var camera := $Player/Camera2D as Camera2D
onready var level_tween := $LevelTransition as Tween
onready var glass_tween := $GlassTransition as Tween


func _on_Player_orb_used(to_state: int, orb_screen_uv: Vector2, transition_time: float) -> void:
	for transitioner in get_tree().get_nodes_in_group("transitioning"):
		transitioner.set_transition_initial_values(to_state, orb_screen_uv)
		glass_tween.interpolate_method(transitioner, "animate_transition", 0.0, 1.0,
				transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	glass_tween.start()


func _on_Level_entered(level: LevelBase) -> void:
	level_tween.interpolate_property(camera, "limit_left",
			null, level.get_global_extents().position.x,
			1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	level_tween.start()


func _on_Level_finished(level: LevelBase) -> void:
	var new_index := level.get_index() + 1
	if levels.get_child_count() > new_index:
		var next := levels.get_child(new_index) as LevelBase
		level_tween.interpolate_property(camera, "limit_right",
				null, next.get_global_extents().end.x,
				1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		level_tween.start()


func _on_Player_died() -> void:
	var tmp_global_pos := camera.global_position
	camera.get_parent().remove_child(camera)
	add_child(camera)
	camera.global_position = tmp_global_pos
	yield(get_tree().create_timer(2.0), "timeout")
	
	queue_free()


func _on_Level11_game_finished() -> void:
	queue_free()
