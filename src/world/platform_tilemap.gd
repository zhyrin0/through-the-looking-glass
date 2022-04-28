extends TileMap


onready var shader := material as ShaderMaterial


func set_transition_initial_values(to_state: int, orb_screen_uv: Vector2) -> void:
	shader.set_shader_param("transition", 0.0)
	shader.set_shader_param("to_state", to_state)
	shader.set_shader_param("orb_screen_uv", orb_screen_uv)


func animate_transition(transition: float) -> void:
	shader.set_shader_param("transition", transition)
