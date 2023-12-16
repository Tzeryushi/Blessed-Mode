extends GreenEnemy

@onready var sight_cast := $SightCast

func look_and_fire() -> void:
	if player_ref:
		if !is_firing_laser:
			rotation = move_toward(rotation, rotation+get_angle_to(player_ref.global_position), laser_turn_speed*2.0)
		#if (player_ref.global_position-global_position).length() <= fire_distance_threshold:
			#if shot_timer.is_stopped(): #probably icky, but w/e
				#shoot(player_ref.global_position-global_position)
		if !is_firing_laser and (player_ref.global_position-global_position).length() <= fire_distance_threshold and sight_cast.get_collider() is Player:
			set_movement_target(global_position)
			if shot_timer.is_stopped():
				laser_timer.start() 
				set_firing(true)
		elif is_firing_laser:
			if !laser_timer.is_stopped():
				if player_ref.get_mode_color() == Globals.MODECOLOR.BLUE:
					look_at(player_ref.global_position)
				else:
					rotation = move_toward(rotation, rotation+get_angle_to(player_ref.global_position), laser_turn_speed)
				#rotation = rotation-get_angle_to(player_ref.global_position)
				laser_sights.clear_points()
				laser_sights.add_point(Vector2(bullet_spawn_distance,0))
				laser_sights.add_point(Vector2(2000.0, 0.0))
			else:
				laser_sights.clear_points()
				shoot(Vector2(1,0).rotated(rotation))
				set_firing(false)
		else:
			set_movement_target(player_ref.global_position)
