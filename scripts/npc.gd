extends CharacterBody3D
class_name NPC

# @export var anim_player: AnimationPlayer
@onready var anim_player := $"Root Scene/AnimationPlayer"

var dead := false

var die_anims: Array[String] = [
	"humanoid/die1",
	"humanoid/die2",
	"humanoid/die3",
]

@onready var bullet := preload("res://scenes/bullet.tscn")

var shoot_timer := Timer.new()

@onready var player := GameManager.player

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("humanoid/idle")

	add_child(shoot_timer)
	shoot_timer.start(randi_range(1, 5))
	shoot_timer.connect("timeout", _on_shoot_timer_timeout)
	# skeleton.physical_bones_start_simulation()

func _on_shoot_timer_timeout():
	if not player or player.dead or self.dead:
		return

	var b := bullet.instantiate()
	b.spawner = self
	b.position = position + Vector3(0, 0.5, 0)
	b.rotation = rotation
	shoot_timer.start(randf_range(0.2, 1))
	get_tree().current_scene.add_child(b)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		return

	if player and not player.dead:
		look_at(GameManager.player.global_transform.origin, Vector3.UP, true)

func die():
	if not dead:
		dead = true
		anim_player.play(die_anims.pick_random())
		collision_layer = 0
		