extends CharacterBody3D

@export var SPEED = 10.0

@export var camera_root: Node3D
@export var cursor : Node3D

@onready var anim_tree : AnimationTree = $"Root Scene/AnimationTree"
@onready var anim_player : AnimationPlayer = $"Root Scene/AnimationPlayer"
@onready var player_root : Node = $"Root Scene/RootNode"

@onready var bullet := preload("res://scenes/bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_movement = Vector3.ZERO
	var forward = basis.z.normalized()

	if camera_root:
		forward = camera_root.basis.z.normalized()

	if Input.is_action_pressed("move_left"):
		input_movement = input_movement + forward.cross(Vector3.UP)
	if Input.is_action_pressed("move_right"):
		input_movement = input_movement - forward.cross(Vector3.UP)
	if Input.is_action_pressed("move_up"):
		input_movement = input_movement - forward
	if Input.is_action_pressed("move_down"):
		input_movement = input_movement + forward

	velocity = input_movement * SPEED * delta

	if velocity.length() > 0:
		anim_player.play("humanoid/walk")
		player_root.look_at(player_root.global_transform.origin - velocity)
	else:
		anim_player.play("humanoid/idle")
	
	move_and_slide()

func _input(event):
	if event.is_action_pressed("shoot"):
		player_root.look_at(cursor.position)
		player_root.rotation.y += PI

		var b := bullet.instantiate()
		b.position = position + Vector3(0, 0.5, 0)
		b.rotation = player_root.rotation
		get_tree().root.add_child(b)
