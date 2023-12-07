class_name BaseEnemy
extends CharacterBody2D

@export var health : int = 10 : set = set_health, get = get_health
@export var body_damage : int = 1

@export var mode_color : Globals.MODECOLOR

signal health_changed(value:int)

func _physics_process(_delta):
	move_and_slide()

func take_damage(_damage:int, _attacking_color:Globals.MODECOLOR=mode_color) -> void:
	var damage_to_take : int = _damage
	#augment damage based on modes
	match Globals.get_mode_color_effectiveness(_attacking_color, get_mode_color()):
			0: pass
			1: damage_to_take = damage_to_take * 2
			2: 
				@warning_ignore("integer_division")
				damage_to_take = max(int(damage_to_take/2), 1)
	#print(damage_to_take)
	health = get_health()-damage_to_take
	if get_health() <= 0:
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
