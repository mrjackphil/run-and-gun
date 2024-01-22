extends Node3D

const CAMERA_ROTATION_SENSITIVITY = 100

@onready var yaw: Node3D = $Yaw

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				return

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			var camera_rotation = yaw.rotation.x - event.relative.y / CAMERA_ROTATION_SENSITIVITY
			rotation.y -= event.relative.x / CAMERA_ROTATION_SENSITIVITY
			yaw.rotation.x = clamp(camera_rotation, -1, 1)

