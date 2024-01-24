extends CharacterBody3D
class_name Player

@export var SPEED := 150.0
@export var RUN_SPEED := 400.0
const ROTATION_SPEED := 0.1

@export var camera_root: Node3D
@export var cursor : Node3D

@onready var anim_tree : AnimationTree = $"Root Scene/AnimationTree"
@onready var anim_player : AnimationPlayer = $"Root Scene/AnimationPlayer"
@onready var player_root : Node3D = $"Root Scene/RootNode"

@onready var bullet := preload("res://scenes/bullet.tscn")

var is_shooting = true : set = _set_moving_state, get = _get_moving_state
var shoot_timer = Timer.new()

var dead := false

var die_anims: Array[String] = [
	"humanoid/die1",
	"humanoid/die2",
	"humanoid/die3",
]

# Called when the no

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(shoot_timer)
	shoot_timer.connect("timeout", _set_moving_state.bind(true))

	GameManager.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		return

	var input_movement = Vector3.ZERO
	var forward = basis.z.normalized()

	var speed = SPEED

	if Input.is_action_pressed("run"):
		speed = RUN_SPEED

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

	velocity = input_movement.normalized() * speed * delta

	# Hacky fix for the character not rotating when shooting
	if not is_shooting:
		return

	if velocity.length() > 0:
		if speed == RUN_SPEED:
			anim_player.play("humanoid/run")
		else:
			anim_player.play("humanoid/walk")

		var target_position = global_position - velocity

		var xform := player_root.global_transform
		xform = xform.looking_at(target_position)
		player_root.global_transform.basis = lerp(player_root.global_transform.basis, xform.basis, ROTATION_SPEED)
		# player_root.look_at(target_position)
	else:
		anim_player.play("humanoid/idle")
	
	move_and_slide()

func _input(event):
	if dead:
		return

	if event.is_action_pressed("shoot"):
		anim_player.play("humanoid/shoot")
		is_shooting = false

		player_root.look_at(cursor.position)
		player_root.rotation.y += PI

		var b := bullet.instantiate()
		b.spawner = self
		b.position = position + Vector3(0, 0.5, 0)
		b.rotation = player_root.rotation
		get_tree().current_scene.add_child(b)

func _set_moving_state(state: bool):
	if state == false:
		shoot_timer.start(0.2)

	is_shooting = state
	
func _get_moving_state():
	return is_shooting

func die():
	if dead:
		return

	dead = true
	anim_player.play("humanoid/dance")