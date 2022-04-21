extends Node2D


onready var projectile_pos := $ProjectilePosition as Position2D
onready var projectile_dir := $ProjectilePosition/ProjectileDirection as Line2D


func _process(_delta: float) -> void:
	projectile_dir.rotation = (get_global_mouse_position() - projectile_pos.global_position).angle()
