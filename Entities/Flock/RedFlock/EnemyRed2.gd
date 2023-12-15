extends EnemyRed

@onready var sight_line := $Sightline
@onready var player_cast := $PlayerCast

func look_and_fire() -> void:
	if player_ref:
		look_at(player_ref.global_position)
		set_sights()
		if (player_ref.global_position-global_position).length() <= fire_distance_threshold:
			if shot_timer.is_stopped(): #probably icky, but w/e
				shoot(player_ref.global_position-global_position)
		set_movement_target(player_ref.global_position)

func set_sights() -> void:
	if player_cast.is_colliding() and player_cast.get_collider() is Player:
		if !sight_line.visible:
			sight_line.show()
		sight_line.clear_points()
		sight_line.add_point(Vector2.ZERO)
		sight_line.add_point(player_ref.global_position-global_position)
		sight_line.global_rotation = 0
	elif sight_line.visible:
		sight_line.hide()
	
