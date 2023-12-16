extends BlueEnemy

@export var turn_speed : float = 0.03

func look_and_fire() -> void:
	if player_ref:
		rotation += turn_speed
		if (player_ref.global_position-global_position).length() <= fire_distance_threshold:
			sight_cast.force_raycast_update()
			if sight_cast.is_colliding() and sight_cast.get_collider() is Player:
				if shot_timer.is_stopped(): #probably icky, but w/e
					shoot(player_ref.global_position-global_position)
		if missile_timer.is_stopped():
			fire_missile()
		set_movement_target(player_ref.global_position)
