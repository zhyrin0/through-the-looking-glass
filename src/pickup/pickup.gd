extends Area2D


var can_pick_up := true


func _ready() -> void:
	var anim_player := $AnimationPlayer as AnimationPlayer
	anim_player.play("float")


func show() -> void:
	.show()
	set_deferred("monitoring", true)


func _on_Pickup_body_entered(body: Node) -> void:
	if not can_pick_up:
		return
	can_pick_up = false
	set_deferred("monitoring", false)
	body.heal()
	var audio := $PickupAudio as AudioStreamPlayer
	audio.play()
	hide()


func _on_PickupAudio_finished() -> void:
	queue_free()
