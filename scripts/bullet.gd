extends Node3D
class_name Bullet

var timer := Timer.new()
@onready var area3d := $Area3D

var spawner: CharacterBody3D

const SPEED = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.autostart = true
	timer.connect("timeout", _on_timer_timeout)
	add_child(timer)

	area3d.connect("body_entered", _on_body_entered)
	area3d.connect("area_entered", _on_area_entered)

func _on_timer_timeout():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis.z * SPEED * delta

func _on_area_entered(_area):
	queue_free()

func _on_body_entered(body):
	if body == spawner:
		return

	queue_free()

	if body.has_method("die"):
		body.die()
