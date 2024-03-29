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
@export var blessed_mode_timer : Timer

@export_category("Camera Properties")
@export var player_camera : Camera2D
@export_range(0.0, 1.0, 0.05) var cursor_ratio: float = 0.5
@export var max_camera_length : float = 300.0

@export_category("Ship Properties")
@export var max_health : int = 20
@export var max_juice : float = 30.0
@export var juice_regen_rate : float = 0.1
@export var hit_invincible_time : float = 0.5
@export var blessed_combo_rate : int = 10
@export var blessed_mode_time : float = 10.0
@export var blessed_regen_rate : float = 4.0

@export_category("VFX Properties")
@export var ghost_scene : PackedScene
@export var swap_particles_scene : PackedScene
@export var death_particles_scene : PackedScene

@export_category("SFX")
#remember that swap sfx is in ship modes!
@export var hurt_sfx : AudioStream = GlobalSfx.player_ship_hit
@export var death_sfx : AudioStream = GlobalSfx.player_ship_destroyed
@export var blessed_mode_sfx : AudioStream = GlobalSfx.player_blessed_mode
@export var blessed_mode_voice : AudioStream

#onreadies, pay attention to pathing
@onready var player_sprite = $SpriteGroup/PlayerSprite
@onready var blessed_particles = $BlessedParticles
@onready var health : int = max_health : get = get_health, set = set_health
@onready var juice : float = max_juice : set = set_juice

var current_ship_mode : ShipMode
var combo_count : int = 0 : set = set_combo

const DEADZONE : float = 0.23

#flags
var is_shooting : bool = false
var has_killstreak : bool = false
var is_invincible : bool = false
var is_dash_invincible : bool = false
var is_hit_invincible : bool = false
var is_death_invincible : bool = false
var can_use_special : bool = true
var is_in_blessed_mode : bool = false
var is_using_controller : bool = false

signal health_changed(value:int, max_health:int)
signal juice_changed(value:float, max_juice:float, is_recharging:bool)
signal mode_changed(mode:Globals.MODECOLOR)
signal combo_changed(value:int)
signal blessed_mode_engaged(value:bool)
signal defeated

func _ready() -> void:
	current_ship_mode = mode_manager.get_ship_mode()
	state_manager.init_state(self)
	mode_manager.init_modes(self)
	hit_invincible_timer.wait_time = hit_invincible_time
	blessed_mode_timer.wait_time = blessed_mode_time
	Shake.set_camera(player_camera)
	Events.combo_up.connect(_on_combo_up)
	InputMap.action_set_deadzone("aim_up", DEADZONE)
	InputMap.action_set_deadzone("aim_down", DEADZONE)
	InputMap.action_set_deadzone("aim_left", DEADZONE)
	InputMap.action_set_deadzone("aim_right", DEADZONE)
	InputMap.action_set_deadzone("move_up", DEADZONE)
	InputMap.action_set_deadzone("move_down", DEADZONE)
	InputMap.action_set_deadzone("move_left", DEADZONE)
	InputMap.action_set_deadzone("move_right", DEADZONE)

func _input(_event) -> void:
	if _event is InputEventMouseMotion:
		is_using_controller = false

func _unhandled_input(_event) -> void:
	if Input.get_axis("aim_up","aim_down") != 0.0 or Input.get_axis("aim_left","aim_right") != 0.0:
		is_using_controller = true 
	#if Input.is_action_just_pressed("shoot"):
		#print(MainPort.main_subviewport.get_mouse_position() - get_global_transform_with_canvas().origin, get_global_mouse_position())
	state_manager.process_input(_event)

func _process(_delta) -> void:
	state_manager.process_frame(_delta)
	current_ship_mode.process_frame(_delta)
	
	make_single_ghost(0.02*min(combo_count,20))
	
	#camera operations
	if is_using_controller:
		reticle.update_reticle_position_controller(global_position, rotation)
	else:
		reticle.update_reticle_position_mouse()
	player_camera.position = (reticle.position*cursor_ratio).limit_length(max_camera_length)
	if is_in_blessed_mode:
		set_juice(juice+blessed_regen_rate)

func _physics_process(_delta) -> void:
	#make_single_ghost()
	if is_using_controller:
		var aim_vector : Vector2 = Vector2(Input.get_axis("aim_left", "aim_right"), Input.get_axis("aim_up", "aim_down")).normalized()
		look_at((aim_vector)+global_position)
	else:
		look_at(get_global_mouse_position())
	state_manager.process_physics(_delta)
	current_ship_mode.process_physics(_delta)

func engage_blessed_mode() -> void:
	blessed_mode_timer.start()
	if is_in_blessed_mode:
		return
	is_in_blessed_mode = true
	blessed_particles.play()
	TextPopper.root_jolt_text("[center][rainbow]BLESSED MODE", global_position, 80.0, 1.0, 1.0, 50, 10, Color(1,1,1,1.0))
	VoiceManager.play(blessed_mode_voice)
	SoundManager.play(blessed_mode_sfx, 0.6)
	set_juice(max_juice)
	blessed_mode_engaged.emit(true)

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
	var altered_damage = Globals.multiply_by_mode(_damage, _attacking_color, get_mode_color())
	health = get_health()-altered_damage
	set_combo(0)
	
	#SFX and Visuals
	SoundManager.play(hurt_sfx)
	Shake.set_camera(player_camera)
	Shake.add_trauma(0.6)
	TextPopper.root_pop_text("[center]-"+str(altered_damage), global_position, 1.0, 1.0, 40, 10, Color(0.1,0.1,0.1,1.0))
	
	#temp invicibility
	set_hit_invincibility(true)
	hit_invincible_timer.start()

func die() -> void:
	set_death_invincibility(true)
	#death animation, particles here
	#stop taking movement and action input
	var death_parts : ParticleAnimation = death_particles_scene.instantiate()
	add_child(death_parts)
	death_parts.play()
	player_sprite.hide()
	SoundManager.play(death_sfx)
	Shake.add_trauma(1,1)
	var timer : SceneTreeTimer = get_tree().create_timer(2.0)
	await timer.timeout
	defeated.emit()

func get_combo_count() -> int:
	return combo_count
func set_combo(value:int) -> void:
	combo_count = value
	combo_changed.emit(combo_count)
	if combo_count != 0 and combo_count%blessed_combo_rate==0:
		engage_blessed_mode()
func set_juice(value:float) -> void:
	juice = clamp(value, 0.0, max_juice)
	if can_use_special and juice <= 0.0:
		TextPopper.root_jolt_text("[center]SPECIAL\ndepleted!", global_position, 80.0, 1.0, 1.0, 50, 10, Color(0.1,0.1,0.1,1.0))
		can_use_special = false
	elif !can_use_special and juice >= max_juice:
		can_use_special = true
	juice_changed.emit(juice, max_juice, !can_use_special)
func get_health() -> int:
	return health
func set_health(value:int) -> void:
	health = clamp(value, 0, max_health)
	health_changed.emit(health, max_health)
	if health == 0:
		die()
func set_hit_invincibility(value:bool) -> void:
	is_hit_invincible = value
	is_invincible = query_is_invincible()
func set_dash_invincibility(value:bool) -> void:
	is_dash_invincible = value
	is_invincible = query_is_invincible()
func set_death_invincibility(value:bool) -> void:
	is_death_invincible = value
	is_invincible = query_is_invincible()
func query_is_invincible() -> bool:
	return is_hit_invincible or is_dash_invincible or is_death_invincible
func get_mode_color() -> Globals.MODECOLOR:
	return current_ship_mode.mode_color

func _on_combo_up() -> void:
	set_combo(combo_count + 1)
func _on_hitbox_area_entered(_area) -> void:
	pass # Replace with function body.
func _on_hitbox_body_entered(body) -> void:
	#we manage this from the player class for clarity, don't @ me
	if body.is_in_group("enemy") and body is BaseEnemy:
		Shake.add_trauma(0.2)
		take_damage(body.body_damage, body.get_mode_color())
	pass # Replace with function body.

func _on_hit_invincible_timer_timeout():
	set_hit_invincibility(false)
func _on_blessed_timer_timeout():
	is_in_blessed_mode = false
	blessed_particles.stop()
	TextPopper.root_jolt_text("[center]UNBLESSED", global_position, 80.0, 1.0, 1.0, 50, 10, Color(0.1,0.1,0.1,1.0))
	blessed_mode_engaged.emit(false)
