class_name ShipMode
extends Node

#shipmode attributes
@export var acceleration : float = 30.0
@export var decceleration : float = 10.0
@export var max_movement_speed : float = 600.0
@export var ship_sprites : AnimatedSprite2D

#contains "prototype" functions for state-called actions

#boilerplate funcs
func swap_in() -> void:
	pass
func swap_out() -> void:
	pass
func process_frame(_delta:float) -> void:
	pass
func process_physics(_delta:float, player:Player) -> void:
	player.move_and_slide()

#action funcs
func idle(_delta:float, player:Player) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, decceleration)
	player.velocity.y = move_toward(player.velocity.y, 0, decceleration)
func move(_direction:Vector2, _delta:float, player:Player) -> void:
	player.velocity.x = move_toward(player.velocity.x, max_movement_speed*_direction.x, acceleration)
	player.velocity.y = move_toward(player.velocity.y, max_movement_speed*_direction.y, acceleration)
func shoot(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
func special_action(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
