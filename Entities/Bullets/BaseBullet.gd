class_name BaseBullet
extends Node2D

@export var trail : Line2D

@export_category("Bullet Attributes")
@export var damage : int = 1
@export var speed : float = 700.0
@export var top_speed : float = 700.0
@export var acceleration : float = 5.0

@export_category("Timer Attributes")
@export var life_timer : Timer
@export var lifetime : float = 2.0

var direction : Vector2 = Vector2.ZERO
var has_hit : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	life_timer.wait_time = lifetime
	life_timer.start()
func _physics_process(_delta) -> void:
	speed = minf(speed + (acceleration), top_speed)
	global_position += direction * speed * _delta
	rotation = direction.angle()
	
func spawn(_position:Vector2, _direction:Vector2) -> void:
	global_position = _position
	direction = _direction.normalized()
	rotation = direction.angle()

func destroy() -> void:
	queue_free()

func _on_life_timer_timeout():
	destroy()

func _on_body_entered(body) -> void:
	if body.is_in_group("enemy") and body is BaseEnemy:
		body.take_damage(damage)
	destroy()
