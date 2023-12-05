class_name BaseEnemy
extends CharacterBody2D

@export var health : float = 1.0
@export var body_damage : float = 1.0

signal health_changed(value:int)

func _physics_process(delta):
	move_and_slide()

func take_damage(damage:int) -> void:
	set_health(health - damage)
	if health <= 0:
		destruct()

func destruct() -> void:
	queue_free()

func get_health() -> int:
	return health
func set_health(value:int) -> void:
	health = value
	health_changed.emit(health)
