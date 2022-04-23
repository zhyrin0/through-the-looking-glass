extends KinematicBody2D

const Projectile := preload("res://src/projectile/projectile.gd")
const ProjectileScene := preload("res://src/projectile/projectile.tscn")
const Debug := preload("debug.gd")


signal request_path(p_self)

const PLATFORM_COLLISION_BIT := 3
const WAYPOINT_DEADZONE := 25
const WAYPOINT_EPSILON := WAYPOINT_DEADZONE / 2.0
const WAYPOINT_EPSILON_SQ := WAYPOINT_DEADZONE*WAYPOINT_DEADZONE / 2.0
export(int) var movement_speed: int
export(int) var jump_height: int setget set_jump_height
export(float) var jump_time: float = 1.0 setget set_jump_time
export(float) var fall_gravity_modifier: float = 1.0
export(NodePath) var player_path: NodePath
var jump_velocity: float
var gravity: float
var velocity := Vector2.ZERO
var fallthrough_platform: Node = null
var waypoints := PoolVector2Array()
onready var player := get_node_or_null(player_path) as Node2D
onready var jump_raycast := $JumpRayCast as RayCast2D
onready var fall_raycast := $FallRayCast as RayCast2D
onready var direction_pivot := $DirectionPivot as Node2D
onready var projectile_pos := $DirectionPivot/ProjectilePosition as Node2D
onready var movement_cooldown := $MovementCooldown as Timer
onready var attack_cooldown := $AttackCooldown as Timer
onready var debug := $Debug as Debug


func _ready() -> void:
	emit_signal("request_path", self)


func _physics_process(delta: float) -> void:
	var gravity_multiplier := fall_gravity_modifier if velocity.y > 0.0 else 1.0
	velocity.y += gravity * gravity_multiplier * delta
	
	if movement_cooldown.is_stopped() and not waypoints.empty():
		var to_waypoint := waypoints[0] - global_position
		
		velocity.x = movement_speed * sign(to_waypoint.x)
		var distance_sq := to_waypoint.length_squared()
		if distance_sq <= WAYPOINT_EPSILON_SQ:
			waypoints.remove(0)
			debug.waypoints.remove(0)
			set_facing_direction()
			if waypoints.empty():
				velocity.x = 0.0
				movement_cooldown.start()
				var projectile := ProjectileScene.instance() as Projectile
				projectile.init(projectile_pos.global_position,
						(player.global_position - projectile_pos.global_position).normalized(),
						true)
				get_parent().add_child(projectile)
				attack_cooldown.start()
		
		if is_on_floor() and to_waypoint.y < -WAYPOINT_EPSILON and jump_raycast.is_colliding():
			set_collision_mask_bit(PLATFORM_COLLISION_BIT, false)
			velocity.y -= jump_velocity
		if is_on_floor() and to_waypoint.y > WAYPOINT_EPSILON and fall_raycast.is_colliding():
			fallthrough_platform = fall_raycast.get_collider() as Node
			if fallthrough_platform:
				add_collision_exception_with(fallthrough_platform)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	if velocity.y > 0.0:
		set_collision_mask_bit(PLATFORM_COLLISION_BIT, true)
	if is_on_floor() and fallthrough_platform:
		remove_collision_exception_with(fallthrough_platform)
		fallthrough_platform = null


func set_path(path: PoolVector2Array) -> void:
	waypoints = path
	debug.waypoints = waypoints


func set_facing_direction() -> void:
	var goal := player.global_position if waypoints.empty() else waypoints[0]
	var to := goal - global_position
	direction_pivot.scale.x = sign(to.x)
	debug.scale.x = sign(to.x)


func set_jump_height(new_value: int) -> void:
	jump_height = new_value
	_set_physics_values()


func set_jump_time(new_value: float) -> void:
	jump_time = new_value
	_set_physics_values()


func _set_physics_values() -> void:
	jump_velocity = 2.0 * jump_height / jump_time if jump_time else 1.0
	gravity = 2.0 * jump_height / pow(jump_time if jump_time else 1.0, 2)


func _on_MovementCooldown_timeout() -> void:
	emit_signal("request_path", self)


func _on_AttackCooldown_timeout() -> void:
	if not sign(global_position.direction_to(player.global_position).x) == direction_pivot.scale.x:
		return
	var projectile := ProjectileScene.instance() as Projectile
	projectile.init(projectile_pos.global_position,
			(player.global_position - projectile_pos.global_position).normalized(),
			false)
	get_parent().add_child(projectile)
