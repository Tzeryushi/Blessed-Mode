class_name BaseEnemy
extends CharacterBody2D

@export_category("General Attributes")
@export var mode_color : Globals.MODECOLOR
@export var health : int = 10 : set = set_health, get = get_health
@export var body_damage : int = 1
@export var bullet_spawn_distance : float = 40.0
@export var fire_distance_threshold : float = 600.0
@export var shot_cooldown : float = 1.0
@export var score_value : int = 1

@export_category("Movement Attributes")
@export var acceleration : float = 2.0
@export var max_movement_speed : float = 500.0

@export_category("References")
@export var enemy_sprite : AnimatedSprite2D
@export var shot_timer : Timer
@export var bullet_scene : PackedScene
@export var navigation_agent : NavigationAgent2D

@export var explosion_scene : PackedScene
@export var explosion_color : Color = Color(1,1,1,1)

var player_ref : Player
var is_defeated : bool = false

signal health_changed(value:int)
signal defeated(enemy:BaseEnemy)

func _ready() -> void:
	shot_timer.wait_time = shot_cooldown
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	call_deferred("reference_setup")

func _physics_process(_delta) -> void:
	look_and_fire()
	set_movement_values(_delta)
	move_and_slide()

func look_and_fire() -> void:
	if player_ref:
		look_at(player_ref.global_position)
		if (player_ref.global_position-global_position).length() <= fire_distance_threshold:
			if shot_timer.is_stopped(): #probably icky, but w/e
				shoot(player_ref.global_position-global_position)
		set_movement_target(player_ref.global_position)

func set_movement_values(_delta:float) -> void:
	pass

func set_movement_target(_position:Vector2) -> void:
	navigation_agent.target_position = _position

func shoot(_direction_to_shoot:Vector2) -> void:
	var bullet : BaseBullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.spawn(global_position+(_direction_to_shoot.normalized()*bullet_spawn_distance), _direction_to_shoot)
	shot_timer.start()

func take_damage(_damage:int, _attacking_color:Globals.MODECOLOR=mode_color) -> void:
	var altered_damage = Globals.multiply_by_mode(_damage, _attacking_color, get_mode_color())
	health = get_health()-altered_damage
	TextPopper.root_pop_text("[center]-"+str(altered_damage), global_position, 1.0, 1.0, 40, 10, explosion_color)
	if get_health() <= 0:
		destruct()

func reference_setup() -> void:
	#requires us to wait a frame upon creation, beware putting essentials in here
	await get_tree().physics_frame
	var tree = get_tree()
	if tree.has_group("player"):
		player_ref = tree.get_first_node_in_group("player")
		player_ref.tree_exiting.connect(clear_body_ref)

func destruct() -> void:
	#print("Destruct called on enemy ", self)
	if !is_defeated:
		Events.combo_up.emit()
		play_explosion(global_position)
		defeated.emit(self)
		is_defeated = true
	queue_free()

func play_explosion(_position:Vector2) -> void:
	var explosion : ParticleAnimation = explosion_scene.instantiate()
	explosion.global_position = _position
	explosion.set_color(explosion_color)
	get_parent().add_child(explosion)
	explosion.play()

func clear_body_ref() -> void:
	player_ref = null

func get_score_value() -> int:
	return score_value
func get_health() -> int:
	return health
func set_health(value:int) -> void:
	health = value
	health_changed.emit(health)
func get_mode_color() -> Globals.MODECOLOR:
	return mode_color
