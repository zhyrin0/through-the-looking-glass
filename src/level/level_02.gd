extends "level_base.gd"


onready var orb_text_sprite := $OrbOfLookingGlass as Sprite


func spawn() -> void:
	var enemy := EnemyScene.instance() as Enemy
	var spawnpoint := spawnpoints.get_child(randi() % spawnpoints.get_child_count()) as Node2D
	enemy.init(player.state, player, spawnpoint.global_position)
	enemy.connect("request_path", navigation, "on_Enemy_request_path")
	enemy.connect("hit", self, "_on_Enemy_hit")
	enemy.connect("hit_while_invulnerable", self, "_on_Enemy_hit_while_invulnerable")
	enemies.add_child(enemy)


func _on_Enemy_hit_while_invulnerable() -> void:
	orb_text_sprite.visible = true
	player.can_use_orb = true
