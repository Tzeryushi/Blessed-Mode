class_name ShipMode
extends Node

#shipmode attributes
@export_category("General Attributes")
@export var acceleration : float = 30.0
@export var decceleration : float = 10.0
@export var max_movement_speed : float = 600.0
@export var special_depletion_rate: float = 0.2

@export_category("Bullet Attributes")
@export var bullet_scene : PackedScene
@export var bullet_spawn_distance : float = 20.0
#@export var shot_cooldown : float = 0.3
@export var shot_timer : Timer

@export_category("Visuals")
@export var ship_sprites : SpriteFrames
@export var mode_color : Globals.MODECOLOR
@export var ship_color : Color = Color(1,1,1,1)
@export var mode_name : String = "Default Mode"

@export_category("SFX")
@export var swap_in_sfx : AudioStream
#contains "prototype" functions for state-called actions

var player : Player	#set by mode manager
var can_shoot : bool = true
var is_special_activated : bool = false

func _ready() -> void:
	shot_timer.timeout.connect(on_shot_timer_timeout)

#boilerplate funcs
func swap_in() -> void:
	#print("Swapped in ", mode_name)
	player.player_sprite.sprite_frames = ship_sprites
	SoundManager.play(swap_in_sfx, 0.7)
	var swap_parts : ParticleAnimation = player.swap_particles_scene.instantiate()
	add_child(swap_parts)
	swap_parts.set_color(ship_color)
	swap_parts.play()
	player.mode_changed.emit(get_mode_color())
	pass
func swap_out() -> void:
	#print("Swapped out ", mode_name)
	pass
func process_frame(_delta:float) -> void:
	pass
func process_physics(_delta:float) -> void:
	player.move_and_slide()

func get_mode_color() -> Globals.MODECOLOR:
	return mode_color
func on_shot_timer_timeout() -> void:
	can_shoot = true

#action funcs
func idle(_delta:float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, decceleration)
	player.velocity.y = move_toward(player.velocity.y, 0, decceleration)
func move(_direction:Vector2, _delta:float) -> void:
	player.velocity.x = move_toward(player.velocity.x, max_movement_speed*_direction.x, acceleration)
	player.velocity.y = move_toward(player.velocity.y, max_movement_speed*_direction.y, acceleration)
func shoot(_direction:Vector2, _mouse_location:Vector2) -> void:
	if !can_shoot: return
	#handle timer logic
	can_shoot = false
	shot_timer.start()
	#spawn bullet
	var bullet : BaseBullet = bullet_scene.instantiate()
	player.get_parent().add_child(bullet)
	bullet.spawn(player.global_position+(_mouse_location.normalized()*bullet_spawn_distance), _mouse_location)
func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
func end_special_action() -> void:
	pass
