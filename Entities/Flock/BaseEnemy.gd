class_name BaseEnemy
extends CharacterBody2D

@export var health : float = 1.0 : set = set_health, get = get_health
@export var body_damage : float = 1.0

@export var mode_color : Globals.MODECOLOR

signal health_changed(value:int)

func _physics_process(delta):
	move_and_slide()

func take_damage(damage:int) -> void:
	set_health(get_health() - damage)
	if health <= 0:
		destruct()

func destruct() -> void:
	queue_free()

func get_health() -> int:
	return health
func set_health(value:int) -> void:
	health = value
	health_changed.emit(health)
func get_mode_color() -> Globals.MODECOLOR:
	return mode_color
