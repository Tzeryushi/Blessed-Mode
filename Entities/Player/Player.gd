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
@export var first_ship_mode : ShipMode

@export var health : int = 1: get = get_health, set = set_health
@export var acceleration : float = 30.0
@export var decceleration : float = 10.0
@export var max_movement_speed : float = 600.0

var current_ship_mode : ShipMode

signal health_changed(value:int)

func _ready() -> void:
	current_ship_mode = first_ship_mode
	state_manager.init_state(self)
	
func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("shoot"):
		print(get_viewport().get_mouse_position())
	state_manager.process_input(_event)

func _process(_delta) -> void:
	state_manager.process_frame(_delta)

func _physics_process(_delta) -> void:
	state_manager.process_physics(_delta)
	current_ship_mode.process_physics(_delta, self)

func idle(_delta:float) -> void:
	current_ship_mode.idle(_delta, self)
func move(_direction:Vector2, _delta:float) -> void:
	current_ship_mode.move(_direction, _delta, self)
func action1(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
func action2(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass

func get_health() -> int:
	return health

func set_health(value:int) -> void:
	health = value
	health_changed.emit(health)
