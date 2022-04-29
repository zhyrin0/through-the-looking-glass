extends Node2D

const Enemy := preload("res://src/character/enemy/enemy.gd")
const EnemyScene := preload("res://src/character/enemy/enemy.tscn")
const Player := preload("res://src/character/player/player.gd")
const WaypointNavigation := preload("res://src/character/enemy/waypoint_navigation.gd")


signal entered(p_self)
signal finished(p_self)

const BARRIER_COLLISION_BIT := 5
export(NodePath) var player_path: NodePath
export(PoolIntArray) var waves: PoolIntArray
export(Vector2) var spawn_cooldown_range: Vector2
var current_wave := 0
var enemies_to_spawn := 0
var enemies_killed := 0
onready var player := get_node_or_null(player_path) as Player
onready var left_barrier := $LeftBarrier as StaticBody2D
onready var right_barrier := $RightBarrier as StaticBody2D
onready var spawnpoints := $Spawnpoints as Node
onready var navigation := $WaypointNavigation as WaypointNavigation
onready var enemies := $Enemies as Node
onready var pickups := $Pickups as Node
onready var spawn_cooldown := $SpawnCooldown as Timer
onready var wave_cooldown := $WaveCooldown as Timer


func _ready() -> void:
	set_spawn_cooldown()
	for pickup in pickups.get_children():
		(pickup as Node2D).hide()
	var animation_player := $AnimationPlayer as AnimationPlayer
	animation_player.play("move_arrow")


func get_global_extents() -> Rect2:
	var upper_left := $Extents/UpperLeft as Node2D
	var lower_right := $Extents/LowerRight as Node2D
	return Rect2(upper_left.global_position, lower_right.position - upper_left.position)


func start() -> void:
	enemies_to_spawn = waves[current_wave]
	if enemies_to_spawn == 0:
		cleared()
		return
	spawn_cooldown.start()


func spawn() -> void:
	var enemy := EnemyScene.instance() as Enemy
	var spawnpoint := spawnpoints.get_child(randi() % spawnpoints.get_child_count()) as Node2D
	enemy.init(player.state, player, spawnpoint.global_position)
	enemy.connect("request_path", navigation, "on_Enemy_request_path")
	enemy.connect("hit", self, "_on_Enemy_hit")
	enemies.add_child(enemy)


func cleared() -> void:
	for pickup in pickups.get_children():
		(pickup as Node2D).show()
	var continue_sprite := $Continue as Sprite
	continue_sprite.show()
	finish()


func finish() -> void:
	right_barrier.set_collision_layer_bit(BARRIER_COLLISION_BIT, false)
	emit_signal("finished", self)


func set_spawn_cooldown() -> void:
	spawn_cooldown.wait_time = rand_range(max(spawn_cooldown_range.x, 0.1), max(spawn_cooldown_range.y, 0.2))


func _on_EnterArea_body_entered(_body: Node) -> void:
	left_barrier.set_collision_layer_bit(BARRIER_COLLISION_BIT, true)
	var enter_area := $EnterArea as Area2D
	enter_area.set_deferred("monitoring", false)
	enter_area.set_deferred("monitorable", false)
	emit_signal("entered", self)
	yield(get_tree().create_timer(wave_cooldown.wait_time), "timeout")
	
	start()


func _on_Enemy_hit() -> void:
	player._on_Enemy_hit()
	enemies_killed += 1
	if enemies_killed == waves[current_wave]:
		wave_cooldown.start()


func _on_SpawnCooldown_timeout() -> void:
	spawn()
	set_spawn_cooldown()
	enemies_to_spawn -= 1
	if enemies_to_spawn == 0:
		spawn_cooldown.stop()


func _on_WaveCooldown_timeout() -> void:
	current_wave += 1
	if current_wave == waves.size():
		cleared()
		return
	enemies_killed = 0
	enemies_to_spawn = waves[current_wave]
	spawn_cooldown.start()
