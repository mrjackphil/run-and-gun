extends Control

const PORT = 9988

@onready var _ip_edit: LineEdit = $GameStartContainer/LauncherContainer/ConnectContainer/PanelContainer/IPHostContainer/IPEdit

signal game_started

func _ready():
	multiplayer.server_relay = false


func _host_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
		
	multiplayer.multiplayer_peer = peer
	print("server listening on ", PORT)


func _connect_to_game(ip: String):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client")
		return
	
	multiplayer.multiplayer_peer = peer


func _on_host_button_pressed():
	_host_server()
	
	#GameManager.run()
	#get_tree().change_scene_to_file("res://scenes/world.tscn")
	emit_signal("game_started")


func _on_connect_button_pressed():
	var ip = _ip_edit.text
	if ip == "":
		ip = "localhost"
	
	_connect_to_game(ip)
	emit_signal("game_started")
	#get_tree().change_scene_to_file("res://scenes/world.tscn")
