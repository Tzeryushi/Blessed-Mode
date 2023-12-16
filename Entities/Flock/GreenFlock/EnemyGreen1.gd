class_name GreenEnemy
extends BaseEnemy

@export var laser_sights : Line2D
@export var laser_timer : Timer
@export var laser_charge_time : float = 4.0
@export var laser_turn_speed : float = 0.007

var is_firing_laser : bool = false : set = set_firing

func _ready() -> void:
	laser_timer.wait_time = laser_charge_time
	super()

func look_and_fire() -> void:
	if player_ref:
		if !is_firing_laser:
			rotation = move_toward(rotation, rotation+get_angle_to(player_ref.global_position), laser_turn_speed*2.0)
		#if (player_ref.global_position-global_position).length() <= fire_distance_threshold:
			#if shot_timer.is_stopped(): #probably icky, but w/e
				#shoot(player_ref.global_position-global_position)
		if !is_firing_laser and (player_ref.global_position-global_position).length() <= fire_distance_threshold:
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

func set_movement_values(_delta:float) -> void:
	#greens should move slowly into range, then begin firing
	if !navigation_agent.is_navigation_finished():
		var new_direction : Vector2 = (navigation_agent.get_next_path_position() - global_position).normalized()
		velocity = velocity.move_toward(max_movement_speed*new_direction, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration)
		velocity.y = move_toward(velocity.y, 0, acceleration)
		
func set_firing(value:bool) -> void:
	if is_firing_laser and !value:
		if player_ref:
			set_movement_target(player_ref.global_position)
	is_firing_laser = value
	


func _on_laser_timer_timeout():
	pass # Replace with function body.
