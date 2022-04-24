extends Node2D

const Enemy := preload("res://src/character/enemy/enemy.gd")
const EnemyScene := preload("res://src/character/enemy/enemy.tscn")
const Player := preload("res://src/character/player/player.gd")
const WaypointNavigation := preload("res://src/character/enemy/waypoint_navigation.gd")


signal finished

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
onready var spawn_cooldown := $SpawnCooldown as Timer
onready var wave_cooldown := $WaveCooldown as Timer


func _ready() -> void:
	set_spawn_cooldown()


func start() -> void:
	enemies_to_spawn = waves[current_wave]
	left_barrier.set_collision_layer_bit(BARRIER_COLLISION_BIT, true)
	right_barrier.set_collision_layer_bit(BARRIER_COLLISION_BIT, true)
	spawn_cooldown.start()


func finish() -> void:
	right_barrier.set_collision_layer_bit(BARRIER_COLLISION_BIT, false)
	emit_signal("finished")


func spawn() -> void:
	var enemy := EnemyScene.instance() as Enemy
	var spawnpoint := spawnpoints.get_child(randi() % spawnpoints.get_child_count()) as Node2D
	enemy.init(player, spawnpoint.global_position)
	enemy.connect("request_path", navigation, "on_Enemy_request_path")
	enemy.connect("hit", self, "_on_Enemy_hit")
	enemies.add_child(enemy)


func set_spawn_cooldown() -> void:
	spawn_cooldown.wait_time = rand_range(spawn_cooldown_range.x, spawn_cooldown_range.y)


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
		finish()
		return
	enemies_killed = 0
	enemies_to_spawn = waves[current_wave]
	spawn_cooldown.start()
