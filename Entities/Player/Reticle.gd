class_name PlayerReticle
extends Node2D

@export var aim_length : float = 800
@export var min_aim_length : float = 100
	
func update_reticle_position_mouse() -> void:
	global_position = get_global_mouse_position()
	global_rotation = 0

func update_reticle_position_controller(global_pos:Vector2, rotation:float) -> void:
	var aim_vector : Vector2 = Vector2(Input.get_axis("aim_left", "aim_right"),Input.get_axis("aim_up", "aim_down"))
	aim_vector = aim_vector*aim_length
	if aim_vector.length() < min_aim_length:
		aim_vector = Vector2.RIGHT.rotated(rotation)*min_aim_length
	global_position = (aim_vector)+global_pos
	global_rotation = 0
