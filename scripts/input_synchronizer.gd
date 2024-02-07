extends MultiplayerSynchronizer
class_name InputSynchronizer

signal shooting(val)

@export var player: Player

@export var is_running: bool = false
@export var is_dodging: bool = false
@export var is_shooting := false :
	set(val):
		is_shooting = val
		emit_signal("shooting", val)

@export var input_movement: Vector3 = Vector3.ZERO


func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


func _process(delta):
	input_movement = Vector3.ZERO
	var forward = player.basis.z.normalized()

	if Input.is_action_pressed("move_left"):
		input_movement = input_movement + forward.cross(Vector3.UP)
	if Input.is_action_pressed("move_right"):
		input_movement = input_movement - forward.cross(Vector3.UP)
	if Input.is_action_pressed("move_up"):
		input_movement = input_movement - forward
	if Input.is_action_pressed("move_down"):
		input_movement = input_movement + forward
	
	is_running = Input.is_action_pressed("run")
	is_dodging = Input.is_action_just_pressed("dodge")


func _input(event):
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	is_shooting = event.is_action_pressed("shoot")
