class_name Player
extends Node2D

#TODO:
#Create distinct mode behaviour - Shooting, movement, visual changes. Interactions with enemies later.
#Flashy stuff and animations

#states will govern movement systems and things like invincibility
#the way these states are interpreted will be defined by the modes being passed to the player

@export_category("General References")
@export var state_manager : PlayerStateManager
@export var mode_manager : ModeManager
@export var reticle : PlayerReticle
@export var hit_invincible_timer : Timer

@export_category("Camera Properties")
@export var player_camera : Camera2D
@export_range(0.0, 1.0, 0.05) var cursor_ratio: float = 0.5
@export var max_camera_length : float = 300.0

@export_category("Ship Properties")
@export var max_health : int = 20
@export var hit_invincible_time : float = 0.5

@export_category("VFX Properties")
@export var ghost_scene : PackedScene

#onreadies, pay attention to pathing
@onready var player_sprite = $SpriteGroup/PlayerSprite
@onready var health : int = max_health : get = get_health, set = set_health

var current_ship_mode : ShipMode
var combo_count : int = 2

#flags
var is_shooting : bool = false
var has_killstreak : bool = false
var is_invincible : bool = false
var is_dash_invincible : bool = false
var is_hit_invincible : bool = false

signal health_changed(value:int)

func _ready() -> void:
	current_ship_mode = mode_manager.get_ship_mode()
	state_manager.init_state(self)
	mode_manager.init_modes(self)
	hit_invincible_timer.wait_time = hit_invincible_time
	Shake.set_camera(player_camera)
	
func _unhandled_input(_event) -> void:
	#if _event is InputEventMouseMotion:
	#	look_at(get_global_mouse_position())
	#if Input.is_action_just_pressed("shoot"):
		#print(MainPort.main_subviewport.get_mouse_position() - get_global_transform_with_canvas().origin, get_global_mouse_position())
	state_manager.process_input(_event)

func _process(_delta) -> void:
	state_manager.process_frame(_delta)
	current_ship_mode.process_frame(_delta)
	
	make_single_ghost(0.05*min(combo_count,10))
	
	#camera operations
	reticle.update_reticle_position()
	player_camera.position = (reticle.position*cursor_ratio).limit_length(max_camera_length)

func _physics_process(_delta) -> void:
	#make_single_ghost()
	look_at(get_global_mouse_position())
	state_manager.process_physics(_delta)
	current_ship_mode.process_physics(_delta)

func make_single_ghost(ghost_length:float=0.5) -> void:
	var ghost_instance = ghost_scene.instantiate()
	get_parent().add_child(ghost_instance)
	ghost_instance.position = position
	ghost_instance.flip_h = player_sprite.flip_h
	#ghost_instance.make_ghost(animation.sprite_frames.get_frame_texture(animation.animation, animation.frame), ghost_length)
	ghost_instance.make_ghost(player_sprite, rotation+player_sprite.rotation, ghost_length)

func make_ghost_trail(time:float, number_of_ghosts:int, ghost_length:float=0.5) -> void:
	#inits ghost objects
	#get spriteframes and current frame from animatedsprite, get current frame with get_frame_texture
	var ghost_time : float = time/float(number_of_ghosts)
	for i in int(number_of_ghosts):
		var ghost_instance = ghost_scene.instantiate()
		get_parent().add_child(ghost_instance)
		ghost_instance.position = position
		ghost_instance.flip_h = player_sprite.flip_h
		#ghost_instance.make_ghost(animation.sprite_frames.get_frame_texture(animation.animation, animation.frame), ghost_length)
		ghost_instance.make_ghost(player_sprite, rotation+player_sprite.rotation, ghost_length)
		await get_tree().create_timer(ghost_time).timeout

func idle(_delta:float) -> void:
	current_ship_mode.idle(_delta)
func move(_direction:Vector2, _delta:float) -> void:
	current_ship_mode.move(_direction, _delta)
func shoot(_direction:Vector2) -> void:
	#toggles on shooting status if not already on. Ship modes decide behaviour.
	if !is_shooting:
		is_shooting = true
	current_ship_mode.shoot(_direction, reticle.global_position-global_position)
func special_action(_direction:Vector2) -> void:
	current_ship_mode.special_action(_direction, reticle.global_position-global_position)
func shift_mode() -> void:
	current_ship_mode = mode_manager.swap_ship_mode()
func take_damage(_damage:int=1, _attacking_color:Globals.MODECOLOR=get_mode_color()) -> void:
	if is_invincible:
		return
	health = get_health()-Globals.multiply_by_mode(_damage, _attacking_color, get_mode_color())
	
	Shake.set_camera(player_camera)
	Shake.add_trauma(0.6)
	
	set_hit_invincibility(true)
	hit_invincible_timer.start()

func get_health() -> int:
	return health
func set_health(value:int) -> void:
	health = value
	Events.health_changed.emit(health)
	health_changed.emit(health)
func set_hit_invincibility(value:bool) -> void:
	is_hit_invincible = value
	is_invincible = is_hit_invincible or is_dash_invincible
func set_dash_invincibility(value:bool) -> void:
	is_dash_invincible = value
	is_invincible = is_hit_invincible or is_dash_invincible
func get_mode_color() -> Globals.MODECOLOR:
	return current_ship_mode.mode_color

func _on_hitbox_area_entered(_area) -> void:
	pass # Replace with function body.

func _on_hitbox_body_entered(body) -> void:
	#we manage this from the player class for clarity, don't @ me
	if body.is_in_group("enemy") and body is BaseEnemy:
		take_damage(body.body_damage, body.get_mode_color())
	pass # Replace with function body.

func _on_hit_invincible_timer_timeout():
	set_hit_invincibility(false)
