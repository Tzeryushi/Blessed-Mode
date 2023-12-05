class_name PlayerReticle
extends Node2D
	
func update_reticle_position() -> void:
	global_position = get_global_mouse_position()
	#print(global_position)
