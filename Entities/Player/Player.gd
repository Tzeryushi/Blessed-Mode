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

@export_category("Camera Properties")
@export var player_camera : Camera2D
@export_range(0.0, 1.0, 0.05) var cursor_ratio: float = 0.5
@export var max_camera_length : float = 300.0

@export_category("Ship Properties")
@export var health : int = 10: get = get_health, set = set_health

#onreadies, pay attention to pathing
@onready var sprite = $PlayerSprite


var current_ship_mode : ShipMode

#flags
var is_shooting : bool = false

signal health_changed(value:int)

func _ready() -> void:
	current_ship_mode = mode_manager.get_ship_mode()
	state_manager.init_state(self)
	mode_manager.init_modes(self)
	
func _unhandled_input(_event) -> void:
	#if _event is InputEventMouseMotion:
	#	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"):
		print(MainPort.main_subviewport.get_mouse_position() - get_global_transform_with_canvas().origin, get_global_mouse_position())
	state_manager.process_input(_event)

func _process(_delta) -> void:
	state_manager.process_frame(_delta)
	current_ship_mode.process_frame(_delta)
	
	#camera operations
	reticle.update_reticle_position()
	player_camera.position = (reticle.position*cursor_ratio).limit_length(max_camera_length)

func _physics_process(_delta) -> void:
	look_at(get_global_mouse_position())
	state_manager.process_physics(_delta)
	current_ship_mode.process_physics(_delta)

func idle(_delta:float) -> void:
	current_ship_mode.idle(_delta)
func move(_direction:Vector2, _delta:float) -> void:
	current_ship_mode.move(_direction, _delta)
func shoot(_direction:Vector2) -> void:
	#toggles on shooting status if not already on. Ship modes decide behaviour.
	if !is_shooting:
		is_shooting = true
func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
func shift_mode() -> void:
	#print("shift hit")
	current_ship_mode = mode_manager.swap_ship_mode()

func get_health() -> int:
	return health

func set_health(value:int) -> void:
	health = value
	health_changed.emit(health)
