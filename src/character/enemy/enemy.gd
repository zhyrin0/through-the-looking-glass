extends "../character_base.gd"


signal request_path(p_self)
signal hit

const WAYPOINT_DEADZONE := 16.0
const WAYPOINT_EPSILON := WAYPOINT_DEADZONE / 2.0
const WAYPOINT_EPSILON_SQ := WAYPOINT_DEADZONE*WAYPOINT_DEADZONE / 2.0
export(NodePath) var player_path: NodePath
var waypoints := PoolVector2Array()
var lock_animation := false
onready var player := get_node_or_null(player_path) as Node2D
onready var jump_raycast := $JumpRayCast as RayCast2D
onready var movement_cooldown := $MovementCooldown as Timer
onready var attack_cooldown := $AttackCooldown as Timer


func init(p_player: Node2D, p_global_pos: Vector2) -> void:
	yield(self, "ready")
	
	global_position = p_global_pos
	player = p_player
	emit_signal("request_path", self)


func _ready() -> void:
	animation_player.play("idle")


func _process(_delta: float) -> void:
	if lock_animation:
		return
	var anim := animation_player.current_animation
	if velocity.y < 0.0 and anim != "jump":
		animation_player.play("jump")
	elif velocity.y > 0.0 and anim != "fall":
		animation_player.play("fall")
	elif velocity.x != 0.0 and anim != "run" and is_on_floor():
		animation_player.play("run")
	elif velocity.x == 0.0 and anim == "idle" and is_on_floor():
		animation_player.play("idle")


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
				lock_animation = true
				animation_player.play("attack_release")
				velocity.x = 0.0
				movement_cooldown.start()
				attack_cooldown.start()
		
		if is_on_floor() and to_waypoint.y < -WAYPOINT_EPSILON and jump_raycast.is_colliding():
			jump()
		if is_on_floor() and to_waypoint.y > WAYPOINT_EPSILON and fall_raycast.is_colliding():
			fall()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	reset_collision_rules()


func on_hit() -> void:
	emit_signal("hit")
	queue_free()


func attack() -> void:
	if not is_instance_valid(player):
		disable()
		return
	_attack(Projectile.Owner.ENEMY, player.global_position, false)


func disable() -> void:
	set_physics_process(false)
	movement_cooldown.stop()
	attack_cooldown.stop()


func set_path(path: PoolVector2Array) -> void:
	waypoints = path
	set_facing_direction()


func set_facing_direction() -> void:
	if not is_instance_valid(player):
		disable()
		return
	var target := player.global_position if waypoints.empty() else waypoints[0]
	var target_vector := target - global_position
	pivot.scale.x = sign(target_vector.x)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "attack_release":
		lock_animation = false


func _on_MovementCooldown_timeout() -> void:
	emit_signal("request_path", self)


func _on_AttackCooldown_timeout() -> void:
	if not is_instance_valid(player):
		disable()
		return
	if pivot.scale.x == sign(to_local(player.global_position).x):
		attack()
