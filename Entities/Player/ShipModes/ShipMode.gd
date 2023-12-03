class_name ShipMode
extends Node

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
	print("IDLE!")
	player.velocity.x = move_toward(player.velocity.x, 0, player.decceleration)
	player.velocity.y = move_toward(player.velocity.y, 0, player.decceleration)
func move(_direction:Vector2, _delta:float, player:Player) -> void:
	player.velocity.x = move_toward(player.velocity.x, player.max_movement_speed*_direction.x, player.acceleration)
	player.velocity.y = move_toward(player.velocity.y, player.max_movement_speed*_direction.y, player.acceleration)
func action1(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
func action2(_direction:Vector2, _mouse_location:Vector2) -> void:
	pass
