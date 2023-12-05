class_name BaseBullet
extends Node2D

@export var damage : int = 1
@export var speed : float = 500.0
@export var acceleration : float = 5.0

@export var life_timer : Timer
@export var lifetime : float = 2.0

var direction : Vector2 = Vector2.ZERO
var has_hit : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	life_timer.wait_time = lifetime
	life_timer.start()
	
func spawn(_position:Vector2, _direction:Vector2) -> void:
	global_position = _position
	print(direction)
	direction = _direction.normalized()

func _physics_process(_delta) -> void:
	global_position += direction * speed * _delta
	#print(global_position)
	rotation = direction.angle()

func _on_life_timer_timeout():
	print("dead")
	queue_free()
