extends "../character_base.gd"


export(float) var strong_charge: float
var attack_charge := 0.0
var charge_audio_triggered := false
onready var charge_audio := $ChargeAudio as AudioStreamPlayer
onready var attack_cooldown := $AttackCooldown as Timer


func _process(delta: float) -> void:
	var can_attack := attack_cooldown.is_stopped()
	if can_attack:
		if Input.is_action_pressed("attack"):
			attack_charge += delta
			if attack_charge >= strong_charge and not charge_audio_triggered:
				charge_audio_triggered = true
				charge_audio.play()
		elif Input.is_action_just_released("attack"):
			_attack(Projectile.Owner.PLAYER, get_global_mouse_position(),
					attack_charge >= strong_charge)
			attack_cooldown.start()
			attack_charge = 0.0
			charge_audio_triggered = false
	
	pivot.scale.x = sign(get_local_mouse_position().x)


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
