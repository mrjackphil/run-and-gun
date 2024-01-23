extends Node3D

var timer := Timer.new()

const SPEED = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.autostart = true
	timer.connect("timeout", _on_timer_timeout)
	add_child(timer)

func _on_timer_timeout():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis.z * SPEED * delta
