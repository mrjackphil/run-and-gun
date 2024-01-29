extends Node

var player: Player = null
var enemy := preload("res://scenes/enemy.tscn")

func _ready():
	_spawner_init()

func _input(event):
	if event.is_action_pressed("restart_game"):
		get_tree().reload_current_scene()

func _spawner_init():
	var t = Timer.new()

	add_child(t)
	t.start(5)
	t.connect("timeout", _spawner_spawn.bind(t))

func _spawner_spawn(t: Timer):
	if player.state == player.MovingState.DIE:
		return

	var enemy_count = get_tree().get_nodes_in_group("npc").size()

	if enemy_count >= 10:
		return

	var spawn_enemy := enemy.instantiate() as NPC
	spawn_enemy.position = player.position + Vector3(randi_range(-10, 10),0, randi_range(-10, 10))
	spawn_enemy.rotation.y = randf_range(-PI, PI)
	get_tree().current_scene.add_child(spawn_enemy)
	t.start(5)
