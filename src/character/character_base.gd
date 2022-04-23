extends KinematicBody2D

const Projectile := preload("res://src/projectile/projectile.gd")
const ProjectileScene := preload("res://src/projectile/projectile.tscn")


const PLATFORM_COLLISION_BIT := 3
export(int) var movement_speed: int
export(int) var jump_height: int setget set_jump_height
export(float) var jump_time: float = 1.0 setget set_jump_time
export(float) var fall_gravity_multiplier: float = 1.0
var jump_velocity: float
var gravity: float
var velocity := Vector2.ZERO
var fallthrough_platform: Node = null
onready var fall_raycast := $FallRayCast as RayCast2D
onready var pivot := $Pivot as Node2D
onready var projectile_pos := $Pivot/ProjectilePosition as Position2D


func jump() -> void:
	set_collision_mask_bit(PLATFORM_COLLISION_BIT, false)
	velocity.y -= jump_velocity


func fall() -> void:
	fallthrough_platform = fall_raycast.get_collider()
	if fallthrough_platform:
		add_collision_exception_with(fallthrough_platform)


func reset_collision_rules() -> void:
	if velocity.y > 0.0:
		set_collision_mask_bit(PLATFORM_COLLISION_BIT, true)
	if is_on_floor() and fallthrough_platform:
		remove_collision_exception_with(fallthrough_platform)
		fallthrough_platform = null


func hit() -> void:
	assert(false, "Virtual method.")


func _attack(p_owner: int, target_pos: Vector2, is_strong: bool) -> void:
	var projectile := ProjectileScene.instance() as Projectile
	projectile.init(p_owner, projectile_pos.global_position,
			(target_pos - projectile_pos.global_position).normalized(), is_strong)
	get_parent().add_child(projectile)


func set_jump_height(new_value: int) -> void:
	jump_height = new_value
	_set_physics_values()


func set_jump_time(new_value: float) -> void:
	jump_time = new_value
	_set_physics_values()


func _set_physics_values() -> void:
	jump_velocity = 2.0 * jump_height / jump_time if jump_time else 1.0
	gravity = 2.0 * jump_height / pow(jump_time if jump_time else 1.0, 2)
