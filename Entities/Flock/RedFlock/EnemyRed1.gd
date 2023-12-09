extends BaseEnemy

func set_movement_values(_delta:float) -> void:
	if !player_ref:
		return
	var player_direction : Vector2 = (player_ref.global_position-global_position).normalized()
	velocity = velocity.move_toward(max_movement_speed*player_direction, acceleration)
