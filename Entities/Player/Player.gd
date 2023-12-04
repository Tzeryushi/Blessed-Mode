class_name Player
extends Node2D

#TODO:
#Establish movement (states!)
#Create modes and mode shifts
#Create distinct mode behaviour
#Flashy stuff and animations

#states will govern movement systems and things like invincibility
#the way these states are interpreted will be defined by the modes being passed to the player


@export var state_manager : PlayerStateManager
@export var mode_manager : ModeManager

#deprecated, phase out
@export var health : int = 1: get = get_health, set = set_health
@export var acceleration : float = 30.0
@export var decceleration : float = 10.0
@export var max_movement_speed : float = 600.0

#onreadies, pay attention to pathing
@onready var sprite = $PlayerSprite


var current_ship_mode : ShipMode

#flags
var is_shooting : bool = false

signal health_changed(value:int)

func _ready() -> void:
	current_ship_mode = mode_manager.get_ship_mode()
	state_manager.init_state(self)
	
func _unhandled_input(_event) -> void:
	if _event is InputEventMouseMotion:
		look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"):
		print(MainPort.main_subviewport.get_mouse_position() - get_global_transform_with_canvas().origin, get_global_mouse_position())
	state_manager.process_input(_event)

func _process(_delta) -> void:
	state_manager.process_frame(_delta)
	current_ship_mode.process_frame(_delta)

func _physics_process(_delta) -> void:
	state_manager.process_physics(_delta)
	current_ship_mode.process_physics(_delta, self)

func idle(_delta:float) -> void:
	current_ship_mode.idle(_delta, self)
func move(_direction:Vector2, _delta:float) -> void:
	current_ship_mode.move(_direction, _delta, self)
func shoot(_direction:Vector2) -> void:
	#toggles on shooting status if not already on. Ship modes decide behaviour.
	if !is_shooting:
		is_shooting = true
func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
func shift_mode() -> void:
	current_ship_mode = mode_manager.swap_ship_mode()

func get_health() -> int:
	return health

func set_health(value:int) -> void:
	health = value
	health_changed.emit(health)
