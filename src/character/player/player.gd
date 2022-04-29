extends "../character_base.gd"

const Shard := preload("shard/shard.gd")


signal orb_used(to_state, orb_screen_uv, transition_time)
signal died

enum AttackState {
	NOT_ATTACKING,
	STARTING,
	CHARGING,
	RELEASING,
}

export(int) var max_health: int
export(float) var strong_charge: float
var attack_charge := 0.0
var use_strong_attack := false
var charge_audio_triggered := false
var score := 0
var lock_animation := false
onready var health := max_health
onready var shards := $Pivot/Shards as Node
onready var charge_audio := $ChargeAudio as AudioStreamPlayer
onready var attack_cooldown := $AttackCooldown as Timer
onready var transition_cooldown := $TransitionCooldown as Timer


func _ready() -> void:
	animation_player.play("idle")
	play_shard_animation("idle")


func _process(delta: float) -> void:
	var attack_state := attack_logic(delta)
	pivot.scale.x = sign(get_local_mouse_position().x)
	play_animation(attack_state)
	if transition_cooldown.is_stopped() and Input.is_action_just_pressed("use"):
		use_orb()


func _physics_process(delta: float) -> void:
	velocity.x = Input.get_axis("move_left", "move_right") * movement_speed
	
	var gravity_multiplier := fall_gravity_multiplier if velocity.y > 0.0 else 1.0
	velocity.y += gravity * gravity_multiplier * delta
	if is_on_floor():
		if Input.is_action_just_pressed("move_jump"):
			jump()
		elif Input.is_action_just_pressed("move_fall"):
			fall()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	reset_collision_rules()


func attack_logic(delta: float) -> int:
	var result: int = AttackState.NOT_ATTACKING
	var can_attack := attack_cooldown.is_stopped()
	if can_attack:
		if Input.is_action_pressed("attack"):
			result = AttackState.STARTING if attack_charge == 0.0 else AttackState.CHARGING
			attack_charge += delta
			if attack_charge >= strong_charge and not charge_audio_triggered:
				charge_audio_triggered = true
				charge_audio.play()
		elif Input.is_action_just_released("attack"):
			result = AttackState.RELEASING
			attack_cooldown.start()
			use_strong_attack = attack_charge >= strong_charge
			attack_charge = 0.0
			charge_audio_triggered = false
	return result


func play_animation(attack_state: int) -> void:
	match attack_state:
		AttackState.STARTING:
			animation_player.play("attack_charge")
			play_shard_animation("attack_charge")
			lock_animation = true
		AttackState.RELEASING:
			animation_player.play("attack_release")
			play_shard_animation("attack_release")
	
	if lock_animation:
		return
	var anim := animation_player.current_animation
	if velocity.y < 0.0 and anim != "jump" and not is_on_floor():
		animation_player.play("jump")
		play_shard_animation("jump")
	elif velocity.y > 0.0 and anim != "fall" and not is_on_floor():
		animation_player.play("fall")
		play_shard_animation("fall")
	elif velocity.x != 0.0 and anim != "run" and is_on_floor():
		animation_player.play("run")
		play_shard_animation("run")
	elif velocity.x == 0.0 and anim != "idle" and is_on_floor():
		animation_player.play("idle")
		play_shard_animation("idle")


func play_shard_animation(anim: String) -> void:
	Algorithm.for_each(shards.get_children(), funcref(self, "_play_shard_animation"), [anim])


func _play_shard_animation(shard: Shard, args: Array) -> void:
	var anim := args[0] as String
	shard.play_animation(anim)


func use_orb() -> void:
	var orb_pos := projectile_pos.get_global_transform_with_canvas().origin
	var viewport_size := get_viewport_rect().size
	var orb_uv := Vector2(clamp(orb_pos.x, 0.0, viewport_size.x), clamp(orb_pos.y, 0.0, viewport_size.y))
	orb_uv /= viewport_size
	emit_signal("orb_used", 1 - state, orb_uv, transition_cooldown.wait_time)
	state = 1 - state
	transition_cooldown.start()


func on_hit() -> void:
	if state == State.CLAY:
		return
	health -= 1
	var shard: Shard = Algorithm.find_if(shards.get_children(), funcref(self, "_is_unbroken_shard"))
	if shard:
		shard.break_off()
	if health == 0:
		emit_signal("died")
		queue_free()


func _is_unbroken_shard(shard: Shard, _args: Array) -> bool:
	return not shard.broken_off


func attack() -> void:
	_attack(Projectile.Owner.PLAYER, get_global_mouse_position(), use_strong_attack)


func heal() -> void:
	health = max_health
	for shard in shards.get_children():
		shard.reset(animation_player.current_animation, animation_player.current_animation_position)


func _on_Enemy_hit() -> void:
	score += 1


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "attack_release":
		lock_animation = false
