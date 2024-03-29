extends Node3D

@export var camera: Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_to_cursor()

func _move_to_cursor():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
	var raycast_result := space.intersect_ray(ray_query)

	if raycast_result.has("position"):
		position = raycast_result.position
		position.y = 0

	if raycast_result.has("collider"):
		var collider = raycast_result.collider

		if collider.has_method("highlight"):
			collider.call("highlight")
		
		if collider.has_method("interact") and Input.is_action_just_pressed("interact"):
			collider.call("interact")
