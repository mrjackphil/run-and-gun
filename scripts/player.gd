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

var run_velocity := Vector3.ZERO

var die_anims: Array[String] = [
	"humanoid/die1",
	"humanoid/die2",
	"humanoid/die3",
]

enum MovingState {
	IDLE,
	WALK,
	RUN,
	DODGE,
	DIE
}

var state := MovingState.IDLE

func _ready():
	add_child(shoot_timer)
	shoot_timer.connect("timeout", _set_moving_state.bind(true))

	GameManager.player = self

	# $TimeShift.connect("area_entered", _on_timeshift_enter)
	# $TimeShift.connect("area_exited", _on_timeshift_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == MovingState.DIE:
		return

	var input_movement = Vector3.ZERO
	var forward = basis.z.normalized()

	var speed = SPEED

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
	
	var _is_moving = input_movement.length() > 0

	if state != MovingState.DODGE and not _is_moving:
		state = MovingState.IDLE

	if _is_moving and state != MovingState.DODGE:
		if Input.is_action_pressed("run"):
			speed = RUN_SPEED
			state = MovingState.RUN
		else:
			state = MovingState.WALK

	if _is_moving and Input.is_action_just_pressed("dodge") or state == MovingState.DODGE:
		state = MovingState.DODGE
		speed = RUN_SPEED

	velocity = input_movement.normalized() * speed * delta

	# Hacky fix for the character not rotating when shooting
	if not is_shooting:
		return

	if velocity.length() > 0:
		var target_position = global_position - velocity

		var xform := player_root.global_transform
		xform = xform.looking_at(target_position)
		player_root.global_transform.basis = lerp(player_root.global_transform.basis, xform.basis, ROTATION_SPEED)

		# %Origin.rotation.y = player_root.rotation.y
		# player_root.look_at(target_position)

	_apply_animation()
	_slow_motion()

	move_and_slide()

func _apply_animation():
	match state:
		MovingState.IDLE: 
			anim_player.play("humanoid/idle")
		MovingState.WALK:
			anim_player.play("humanoid/walk")
		MovingState.RUN:
			anim_player.play("humanoid/run")
		MovingState.DODGE:
			anim_player.play("humanoid/roll")

func _unjump():
	state = MovingState.IDLE

func _input(event):
	if state == MovingState.DIE or state == MovingState.DODGE:
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

func _set_moving_state(_state: bool):
	if _state == false:
		shoot_timer.start(0.2)

	is_shooting = _state
	
func _get_moving_state():
	return is_shooting

func die():
	if state == MovingState.DIE or state == MovingState.DODGE:
		return

	state = MovingState.DIE
	anim_player.play("humanoid/dance")


var timeshift: Array[Bullet] = []

func _on_timeshift_enter(area: Area3D):
	if area.owner is Bullet:
		timeshift.append(area.owner)

func _on_timeshift_exited(area: Area3D):
	if area.owner is Bullet:
		timeshift.erase(area.owner)

	if timeshift.size() == 0:
		Engine.time_scale = 1
		pass
	
func _slow_motion():
	if timeshift.size() != 0:
		Engine.time_scale = lerp(Engine.time_scale, 0.2, 0.1)
