extends Node

@export var bullet_node: Node3D

func _ready():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	
	add_player(multiplayer.get_unique_id())


func _exit_tree():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	var player = preload("res://scenes/player.tscn").instantiate()
	player.playerID = id
	player.name = str(id)
	add_child(player, true)
	print("added player with id ", id)


func del_player(id: int):
	if not has_node(str(id)):
		return
	
	get_node(str(id)).queue_free()
	print("removed player with id ", id)
