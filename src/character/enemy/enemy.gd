extends "../character_base.gd"


signal request_path(p_self)

const WAYPOINT_DEADZONE := 16.0
const WAYPOINT_EPSILON := WAYPOINT_DEADZONE / 2.0
const WAYPOINT_EPSILON_SQ := WAYPOINT_DEADZONE*WAYPOINT_DEADZONE / 2.0
export(NodePath) var player_path: NodePath
var waypoints := PoolVector2Array()
onready var player := get_node_or_null(player_path) as Node2D
onready var jump_raycast := $JumpRayCast as RayCast2D
onready var movement_cooldown := $MovementCooldown as Timer
onready var attack_cooldown := $AttackCooldown as Timer


func _ready() -> void:
	emit_signal("request_path", self)


func _physics_process(delta: float) -> void:
	var gravity_multiplier := fall_gravity_multiplier if velocity.y > 0.0 else 1.0
	velocity.y += gravity * gravity_multiplier * delta
	
	if not waypoints.empty():
		var to_waypoint := waypoints[0] - global_position
		
		velocity.x = sign(to_waypoint.x) * movement_speed
		var distance_sq := to_waypoint.length_squared()
		if distance_sq <= WAYPOINT_EPSILON_SQ:
			waypoints.remove(0)
			set_facing_direction()
			if waypoints.empty():
				attack()
				velocity.x = 0.0
				movement_cooldown.start()
				attack_cooldown.start()
		
		if is_on_floor() and to_waypoint.y < -WAYPOINT_EPSILON and jump_raycast.is_colliding():
			jump()
		if is_on_floor() and to_waypoint.y > WAYPOINT_EPSILON and fall_raycast.is_colliding():
			fall()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	reset_collision_rules()


func attack() -> void:
	_attack(Projectile.Owner.ENEMY, player.global_position, false)


func set_path(path: PoolVector2Array) -> void:
	waypoints = path


func set_facing_direction() -> void:
	var target := player.global_position if waypoints.empty() else waypoints[0]
	var target_vector := target - global_position
	pivot.scale.x = sign(target_vector.x)


func _on_MovementCooldown_timeout() -> void:
	emit_signal("request_path", self)


func _on_AttackCooldown_timeout() -> void:
	if pivot.scale.x == sign(to_local(player.global_position).x):
		attack()
