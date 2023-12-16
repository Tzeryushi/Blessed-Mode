class_name EnemyRed
extends BaseEnemy

func set_movement_values(_delta:float) -> void:
	if !navigation_agent.is_navigation_finished():
		var new_direction : Vector2 = (navigation_agent.get_next_path_position() - global_position).normalized()
		velocity = velocity.move_toward(max_movement_speed*new_direction, acceleration)
	#var player_direction : Vector2 = (player_ref.global_position-global_position).normalized()
	#velocity = velocity.move_toward(max_movement_speed*player_direction, acceleration)
