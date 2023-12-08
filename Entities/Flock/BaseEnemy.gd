class_name BaseEnemy
extends CharacterBody2D

@export_category("General Attributes")
@export var mode_color : Globals.MODECOLOR
@export var health : int = 10 : set = set_health, get = get_health
@export var body_damage : int = 1
@export var bullet_spawn_distance : float = 40.0
@export var fire_distance_threshold : float = 600.0
@export var shot_cooldown : float = 1.0

@export_category("References")
@export var enemy_sprite : AnimatedSprite2D
@export var shot_timer : Timer
@export var bullet_scene : PackedScene

var player_ref : Player

signal health_changed(value:int)

func _ready() -> void:
	shot_timer.wait_time = shot_cooldown
	reference_setup()

func _physics_process(_delta) -> void:
	look_and_fire()
	move_and_slide()

func look_and_fire() -> void:
	if player_ref:
		look_at(player_ref.global_position)
		if (player_ref.global_position-global_position).length() <= fire_distance_threshold:
			if shot_timer.is_stopped(): #probably icky, but w/e
				shoot(player_ref.global_position-global_position)

func set_movement_values() -> void:
	pass

func shoot(_direction_to_shoot:Vector2) -> void:
	var bullet : BaseBullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.spawn(global_position+(_direction_to_shoot.normalized()*bullet_spawn_distance), _direction_to_shoot)
	shot_timer.start()

func take_damage(_damage:int, _attacking_color:Globals.MODECOLOR=mode_color) -> void:
	health = get_health()-Globals.multiply_by_mode(_damage, _attacking_color, get_mode_color())
	if get_health() <= 0:
		destruct()

func reference_setup() -> void:
	#requires us to wait a frame upon creation, beware putting essentials in here
	await get_tree().process_frame
	var tree = get_tree()
	if tree.has_group("player"):
		player_ref = tree.get_first_node_in_group("player")

func destruct() -> void:
	queue_free()

func get_health() -> int:
	return health
func set_health(value:int) -> void:
	health = value
	health_changed.emit(health)
func get_mode_color() -> Globals.MODECOLOR:
	return mode_color
