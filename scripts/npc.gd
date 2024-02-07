extends CharacterBody3D
class_name NPC

# @export var anim_player: AnimationPlayer
@onready var anim_player := $"Root Scene/AnimationPlayer"

var die_anims: Array[String] = [
	"humanoid/die1",
	"humanoid/die2",
	"humanoid/die3",
]

enum ENEMY_STATE {
	IDLE,
	WARN,
	ATTACK,
	DEAD
}

var state = ENEMY_STATE.IDLE

@onready var bullet := preload("res://scenes/bullet.tscn")

var shoot_timer := Timer.new()

@onready var player := GameManager.player

@onready var vision_area: Area3D = $VisionCone/Area3D
@onready var vision_raycast: RayCast3D = $VisionCone/RayCast3D
@onready var vision_timer: Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("humanoid/idle")

	add_child(shoot_timer)
	shoot_timer.start(randi_range(1, 5))
	shoot_timer.connect("timeout", _on_shoot_timer_timeout)
	# skeleton.physical_bones_start_simulation()

	vision_timer.connect("timeout", _check_vision_area)
	add_child(vision_timer)
	vision_timer.start(0.2)

func _on_shoot_timer_timeout():
	shoot_timer.start(randf_range(0.2, 1))
	if not player or player.state == player.MovingState.DIE or state != ENEMY_STATE.ATTACK:
		return

	var b := bullet.instantiate()
	b.spawner = self
	b.position = position + Vector3(0, 0.5, 0)
	b.rotation = rotation
	b.rotation.y += randf_range(-0.1, 0.1)
	get_tree().current_scene.add_child(b)

func _check_vision_area():
	var has_player = false
	for b in vision_area.get_overlapping_bodies():
		if b == player:
			_cast_raycast(b)
			has_player = true
			break
	
	if not has_player:
		state = ENEMY_STATE.IDLE
	
	vision_timer.start(0.2)

func _is_dead() -> bool:
	return state == ENEMY_STATE.DEAD

func _cast_raycast(body: PhysicsBody3D):
	if _is_dead():
		return

	vision_raycast.look_at(body.position + Vector3(0, 0.5, 0), Vector3.UP, true)
	vision_raycast.force_raycast_update()

	if vision_raycast.is_colliding() and vision_raycast.get_collider() == player:
		state = ENEMY_STATE.ATTACK
	else:
		state = ENEMY_STATE.IDLE
	
	vision_timer.start(0.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_dead() or not player or player.state == player.MovingState.DIE:
		return

	match state:
		ENEMY_STATE.WARN:
			_look_at_player()
		ENEMY_STATE.ATTACK:
			_look_at_player()
		
func _look_at_player():
	look_at(GameManager.player.global_transform.origin, Vector3.UP, true)

func die():
	if not _is_dead():
		state = ENEMY_STATE.DEAD
		anim_player.play(die_anims.pick_random())
		shoot_timer.stop()
		vision_timer.stop()
		collision_layer = 0
		
