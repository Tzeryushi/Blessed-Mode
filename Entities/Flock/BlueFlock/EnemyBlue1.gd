extends BaseEnemy

@export var missile_scene : PackedScene
@export var missile_timer : Timer
@export var missile_release_time : float

func look_and_fire() -> void:
	if player_ref:
		look_at(player_ref.global_position)
		if (player_ref.global_position-global_position).length() <= fire_distance_threshold:
			if shot_timer.is_stopped(): #probably icky, but w/e
				shoot(player_ref.global_position-global_position)
		if missile_timer.is_stopped():
			fire_missile()
		set_movement_target(player_ref.global_position)

func set_movement_values(_delta:float) -> void:
	if !navigation_agent.is_navigation_finished():
		var new_direction : Vector2 = (navigation_agent.get_next_path_position() - global_position).normalized()
		velocity = velocity.move_toward(max_movement_speed*new_direction, acceleration)

func fire_missile() -> void:
	var bullet : BaseBullet = missile_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.spawn(global_position, Vector2.RIGHT)
	missile_timer.start()
