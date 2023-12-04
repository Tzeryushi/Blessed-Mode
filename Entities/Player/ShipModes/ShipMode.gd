class_name ShipMode
extends Node

#shipmode attributes
@export var acceleration : float = 30.0
@export var decceleration : float = 10.0
@export var max_movement_speed : float = 600.0
@export var shoot_cooldown : float = 0.3
@export var ship_sprites : SpriteFrames

@export var mode_name : String = "Default Mode"
#contains "prototype" functions for state-called actions

var player : Player	#set by mode manager

#boilerplate funcs
func swap_in() -> void:
	#print("Swapped in ", mode_name)
	player.sprite.sprite_frames = ship_sprites
	pass
func swap_out() -> void:
	#print("Swapped out ", mode_name)
	pass
func process_frame(_delta:float) -> void:
	pass
func process_physics(_delta:float) -> void:
	player.move_and_slide()

#action funcs
func idle(_delta:float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, decceleration)
	player.velocity.y = move_toward(player.velocity.y, 0, decceleration)
func move(_direction:Vector2, _delta:float) -> void:
	player.velocity.x = move_toward(player.velocity.x, max_movement_speed*_direction.x, acceleration)
	player.velocity.y = move_toward(player.velocity.y, max_movement_speed*_direction.y, acceleration)
func shoot(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
