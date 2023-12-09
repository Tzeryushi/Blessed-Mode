extends BaseBullet


func _physics_process(_delta) -> void:
	pass
	
func spawn(_position:Vector2, _direction:Vector2) -> void:
	life_timer.start()
	global_position = _position
	direction = _direction.normalized()
	rotation = direction.angle()

func _on_body_entered(body) -> void:
	if body is BaseEnemy or body is Player:
		body.take_damage(damage, get_mode_color())
	destroy()
