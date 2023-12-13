extends BaseBullet


# Called when the node enters the scene tree for the first time.
func spawn(_position:Vector2, _direction:Vector2) -> void:
	life_timer.start()
	global_position = _position
	direction = _direction.normalized()
	rotation = direction.angle()
