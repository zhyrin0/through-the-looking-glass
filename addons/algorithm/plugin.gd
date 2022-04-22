tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Algorithm", "res://addons/algorithm/algorithm.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("Algorithm")
