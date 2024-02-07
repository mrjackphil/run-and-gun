extends Node3D

@onready var _menu: Control = $Menu
@onready var _levels: Node3D = $Levels

func _on_menu_game_started():
	_menu.hide()
	if multiplayer.is_server():
		change_level.call_deferred(load("res://scenes/world.tscn"))


func change_level(scene: PackedScene):
	_levels.add_child(scene.instantiate())
