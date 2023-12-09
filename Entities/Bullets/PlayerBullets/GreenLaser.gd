extends BaseBullet

@export var laser_cast : RayCast2D
@export var laser_length : float = 2000

func _ready():
	laser_cast.target_position.x = laser_length
	
	#timer calulates laser fade time in this case
	life_timer.wait_time = lifetime
	#life_timer.start()
	
	
func _process(_delta) -> void:
	#speed = minf(speed + (acceleration), top_speed)
	pass
func _physics_process(_delta) -> void:
	#global_position += direction * speed * _delta
	#rotation = direction.angle()
	pass

func spawn(_position:Vector2, _direction:Vector2) -> void:
	#this gross function handles raycasting and piercing of enemies by cycling them into the exceptions
	#and then firing until it hits nothing, a non-weak enemy, or a wall
	#I'm not planning on refactoring this. Why bother. This is a game jam.
	trail.clear_points()
	global_position = _position
	direction = _direction.normalized()
	rotation = direction.angle()
	
	var collision_exception_array : Array = []
	laser_cast.enabled = true
	laser_cast.force_raycast_update()
	
	#we scan the raycast and add exception to pierce if enemies are weak to the attack
	while laser_cast.is_colliding():
		var body = laser_cast.get_collider()
		if (body is BaseEnemy or body is Player) and Globals.is_mode_color_effective(get_mode_color(), body.get_mode_color()):
			collision_exception_array.append(body)
			laser_cast.add_exception(body)
		else:
			break
		laser_cast.force_raycast_update()
	
	#current collision is the endpoint, though any collisions in the array must be handled as well
	#draw the line to the end
	trail.add_point(Vector2.ZERO)
	if laser_cast.is_colliding():
		trail.add_point(to_local(laser_cast.get_collision_point()))
	else:
		trail.add_point(Vector2.RIGHT*laser_length)
	
	Shake.add_trauma(shake, shake_ceiling)
	
	#handle application of damage
	for enemy in collision_exception_array:
		enemy.take_damage(damage, get_mode_color())
	if laser_cast.get_collider() is BaseEnemy or laser_cast.get_collider() is Player:
		laser_cast.get_collider().take_damage(damage, get_mode_color())
	
	#clean out exceptions - probably unnecessary
	for body in collision_exception_array:
		if body:
			laser_cast.remove_exception(body)
	laser_cast.enabled = false
	
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(visuals_group, "self_modulate:a", 0.0, life_timer.wait_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	destroy()

func destroy() -> void:
	#probably unnecessary to clear points
	#trail.clear_points()
	queue_free()

func update_trail() -> void:
	pass

func _on_body_entered(body) -> void:
	#this is specifically for enemies within the base radius of the initial explosion VFX
	if body.is_in_group("enemy") and body is BaseEnemy:
		if body is BaseEnemy:
			Shake.add_trauma(shake)
		body.take_damage(damage, get_mode_color())
