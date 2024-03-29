extends Node3D

const CAMERA_ROTATION_SENSITIVITY = 100

@onready var yaw: Node3D = $Yaw

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			rotation.y -= event.relative.x / CAMERA_ROTATION_SENSITIVITY

			# var camera_rotation = yaw.rotation.x - event.relative.y / CAMERA_ROTATION_SENSITIVITY
			# yaw.rotation.x = clamp(camera_rotation, -1, 1)


