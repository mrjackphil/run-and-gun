extends Interactable

@export var geometry_instance_3d: GeometryInstance3D

@export var height := 3

var timer: Timer = Timer.new()
var is_opened = false
var initial_position := position
var opened_position := position - Vector3(0, height, 0)

func _init():
	add_child(timer)
	timer.connect("timeout", unhighlight)

func highlight():
	geometry_instance_3d.material_overlay.set_shader_parameter("shadow_thickness", 2)
	timer.start(0.2)

func _process(delta):
	if is_opened and position != opened_position:
		position = lerp(position, opened_position, 0.2)
	elif position != initial_position: 
		position = lerp(position, initial_position, 0.2)

func interact():
	is_opened = not is_opened

func unhighlight():
	geometry_instance_3d.material_overlay.set_shader_parameter("shadow_thickness", 0)



	
