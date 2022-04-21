extends KinematicBody2D

const Projectile := preload("res://src/projectile/projectile.gd")
const ProjectileScene := preload("res://src/projectile/projectile.tscn")


const PLATFORM_COLLISION_BIT := 3
export(int) var movement_speed: int
export(int) var jump_height: int setget set_jump_height
export(float) var jump_time: float = 1.0 setget set_jump_time
export(float) var fall_gravity_multiplier: float = 1.0
export(float) var strong_charge: float
var jump_velocity: float
var gravity: float
var velocity := Vector2.ZERO
var fallthrough_platform: Node = null
var attack_charge := 0.0
var charge_audio_triggered := false
onready var platform_raycast := $PlatformRayCast as RayCast2D
onready var projectile_pos := $ProjectilePosition as Position2D
onready var attack_charge_audio := $AttackChargeAudio as AudioStreamPlayer
onready var attack_cooldown := $AttackCooldown as Timer


func _process(delta: float) -> void:
	var can_attack := attack_cooldown.is_stopped()
	if can_attack and Input.is_action_pressed("attack"):
		attack_charge += delta
		if attack_charge >= strong_charge and not charge_audio_triggered:
			attack_charge_audio.play()
			charge_audio_triggered = true
	if can_attack and Input.is_action_just_released("attack"):
		var projectile := ProjectileScene.instance() as Projectile
		projectile.init(projectile_pos.global_position,
				(get_global_mouse_position() - projectile_pos.global_position).normalized(),
				attack_charge >= strong_charge)
		get_parent().add_child(projectile)
		attack_charge = 0.0
		attack_cooldown.start()
		charge_audio_triggered = false


func _physics_process(delta: float) -> void:
	velocity.x = Input.get_axis("move_left", "move_right") * movement_speed
	
	var gravity_multiplier := fall_gravity_multiplier if velocity.y > 0.0 else 1.0
	velocity.y += gravity * gravity_multiplier * delta
	if is_on_floor():
		if Input.is_action_just_pressed("move_jump"):
			set_collision_mask_bit(PLATFORM_COLLISION_BIT, false)
			velocity.y -= jump_velocity
		elif Input.is_action_just_pressed("move_fall"):
			fallthrough_platform = platform_raycast.get_collider() as Node
			if fallthrough_platform:
				add_collision_exception_with(fallthrough_platform)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if velocity.y > 0.0:
		set_collision_mask_bit(PLATFORM_COLLISION_BIT, true)
	if is_on_floor() and fallthrough_platform:
		remove_collision_exception_with(fallthrough_platform)
		fallthrough_platform = null


func set_jump_height(new_value: int) -> void:
	jump_height = new_value
	_set_physics_values()


func set_jump_time(new_value: float) -> void:
	jump_time = new_value
	_set_physics_values()


func _set_physics_values() -> void:
	jump_velocity = 2.0 * jump_height / jump_time if jump_time else 1.0
	gravity = 2.0 * jump_height / pow(jump_time if jump_time else 1.0, 2)
