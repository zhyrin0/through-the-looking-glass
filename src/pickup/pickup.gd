extends Area2D


func _ready() -> void:
	var anim_player := $AnimationPlayer as AnimationPlayer
	anim_player.play("float")



func show() -> void:
	.show()
	set_deferred("monitoring", true)


func _on_Pickup_body_entered(body: Node) -> void:
	body.heal()
	queue_free()
