extends Node

const GameWorld := preload("res://src/world/world.gd")
const GAmeWorldScene := preload("res://src/world/world.tscn")


onready var main_menu := $MainMenu as Control
onready var game := $Game as Node



func _on_Play_pressed() -> void:
	main_menu.hide()
	var game_world := GAmeWorldScene.instance() as GameWorld
	game_world.connect("tree_exiting", self, "_on_GameWorld_tree_exiting")
	game.add_child(game_world)


func _on_GameWorld_tree_exiting() -> void:
	main_menu.show()


func _on_Quit_pressed() -> void:
	get_tree().quit()
